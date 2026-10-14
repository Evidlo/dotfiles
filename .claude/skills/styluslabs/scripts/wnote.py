# /// script
# requires-python = ">=3.10"
# dependencies = ["typst", "svgelements", "resvg-py", "Hershey-Fonts"]
# ///
"""Read and write Stylus Labs Write notebooks (.svg) for an agent working alongside a person.

All coordinates are page-local pixels: origin at the page's top-left corner, y down.
Every command that modifies the file accepts --expect-mtime and prints the new mtime_ns as JSON.
"""
import argparse
import glob
import io
import json
import os
import re
import shutil
import sys
import tempfile
import time
import xml.etree.ElementTree as ET

PAGE_RE = re.compile(r'<svg class="write-page"[^>]*>')
TAG_RE = re.compile(r"<(/?)svg\b[^>]*?(/?)>")
TS_RE = re.compile(r'__timestamp="0x([0-9a-fA-F]+)"')
BACKUP_DIR = os.path.expanduser("~/.cache/wnote/backups")
BACKUPS_KEPT = 20
RIGHT_MARGIN = 20


class Notebook:
    def __init__(self, path):
        self.path = path
        self.mtime_ns = os.stat(path).st_mtime_ns
        self.text = open(path, encoding="utf-8").read()

    def pages(self):
        """List of (start, end) spans of each page's <svg>...</svg>, handling nested <svg>."""
        spans = []
        for m in PAGE_RE.finditer(self.text):
            depth = 0
            for t in TAG_RE.finditer(self.text, m.start()):
                depth += (t.group(1) != "/" and t.group(2) != "/") - (t.group(1) == "/")
                if depth == 0:
                    spans.append((m.start(), t.end()))
                    break
        return spans

    def page(self, n):
        spans = self.pages()
        start, end = spans[n if n >= 0 else len(spans) + n]
        return start, end, self.text[start:end]

    def insert_content(self, n, markup):
        """Append markup as the last child of page n's write-content group."""
        start, end, page = self.page(n)
        at = start + page.rindex("</g>")
        self.text = self.text[:at] + markup + "  " + self.text[at:]

    def save(self, expect_mtime):
        current = os.stat(self.path).st_mtime_ns
        if expect_mtime is not None and current != expect_mtime:
            sys.exit(f"error: {self.path} changed on disk (mtime_ns {current} != {expect_mtime}); "
                     "re-read it before writing")
        os.makedirs(BACKUP_DIR, exist_ok=True)
        base = os.path.basename(self.path)
        shutil.copy2(self.path, os.path.join(BACKUP_DIR, f"{base}.{current}"))
        for old in sorted(glob.glob(os.path.join(BACKUP_DIR, f"{glob.escape(base)}.*")))[:-BACKUPS_KEPT]:
            os.remove(old)
        ET.fromstring(self.text)
        d, b = os.path.split(os.path.abspath(self.path))
        tmp = os.path.join(d, f".{b}.wnote-tmp")
        with open(tmp, "w", encoding="utf-8") as f:
            f.write(self.text)
        shutil.copymode(self.path, tmp)
        os.replace(tmp, self.path)
        self.mtime_ns = os.stat(self.path).st_mtime_ns


def page_attrs(page):
    head = PAGE_RE.match(page).group(0)
    num = lambda k: float(re.search(rf' {k}="([\d.]+)', head).group(1))
    return {"y": num("y"), "width": num("width"), "height": num("height")}


def off_page(nb, n, bb):
    """Sides of the page that bbox [x0, y0, x1, y1] runs past."""
    a = page_attrs(nb.page(n)[2])
    sides = {"left": bb[0] < 0, "top": bb[1] < 0, "right": bb[2] > a["width"], "bottom": bb[3] > a["height"]}
    return [k for k, v in sides.items() if v]


def now_ms():
    return int(time.time() * 1000)


def emit(**kw):
    print(json.dumps(kw))


# ---------- rendering ----------

def standalone_page(page, since_ms=None, crop=None):
    head = PAGE_RE.match(page).group(0)
    a = page_attrs(page)
    x0, y0, x1, y1 = crop or (0, 0, a["width"], a["height"])
    newhead = re.sub(r' (x|y|width|height)="[^"]*"', "", head)
    newhead = newhead.replace("<svg ", f'<svg viewBox="{x0} {y0} {x1 - x0} {y1 - y0}" '
                                       f'width="{x1 - x0}" height="{y1 - y0}" ', 1)
    body = page[len(head):]
    dim = lambda m: (m.group(0) if int(m.group(1), 16) >= since_ms
                     else m.group(0) + ' opacity="0.3"')
    body = TS_RE.sub(dim, body) if since_ms is not None else body
    return newhead + body


def cmd_render(a):
    import resvg_py
    nb = Notebook(a.file)
    _, _, page = nb.page(a.page)
    crop = [float(v) for v in a.crop.split(",")] if a.crop else None
    svg = standalone_page(page, a.since, crop)
    png = bytes(resvg_py.svg_to_bytes(svg_string=svg, zoom=a.zoom, background="white"))
    open(a.out, "wb").write(png)
    emit(out=a.out, page=a.page, mtime_ns=nb.mtime_ns)


# ---------- inspection ----------

def element_bboxes(page_svg):
    """Bounding boxes (page coords) of each content element, keyed by its timestamp."""
    import svgelements as se
    doc = se.SVG.parse(io.StringIO(standalone_page(page_svg)), reify=True)
    out = []
    for el in doc.elements():
        ts = el.values.get("__timestamp") if hasattr(el, "values") else None
        bb = el.bbox() if ts and hasattr(el, "bbox") else None
        out += [(int(ts, 16), bb)] if bb else []
    return out


def cmd_info(a):
    nb = Notebook(a.file)
    pages = []
    for i, (s, e) in enumerate(nb.pages()):
        page = nb.text[s:e]
        ts = [int(t, 16) for t in TS_RE.findall(page)]
        pages.append({"page": i, **{k: v for k, v in page_attrs(page).items() if k != "y"},
                      "elements": len(ts), "latest_ms": max(ts, default=0)})
    base = os.path.splitext(os.path.basename(a.file))[0]
    conflicts = glob.glob(os.path.join(os.path.dirname(os.path.abspath(a.file)),
                                       f"{glob.escape(base)}.sync-conflict-*"))
    emit(file=a.file, mtime_ns=nb.mtime_ns, now_ms=now_ms(), pages=pages, sync_conflicts=conflicts)


def cmd_new(a):
    nb = Notebook(a.file)
    found = []
    for i, (s, e) in enumerate(nb.pages()):
        page = nb.text[s:e]
        newer = [int(t, 16) for t in TS_RE.findall(page) if int(t, 16) >= a.since]
        boxes = [bb for ts, bb in element_bboxes(page) if ts >= a.since] if newer else []
        found += [{"page": i, "elements": len(newer),
                   "bbox": [round(min(b[0] for b in boxes)), round(min(b[1] for b in boxes)),
                            round(max(b[2] for b in boxes)), round(max(b[3] for b in boxes))]}] if boxes else []
    emit(mtime_ns=nb.mtime_ns, since=a.since, pages=found)


def cmd_wait(a):
    deadline = time.time() + a.timeout
    seen = a.mtime
    while time.time() < deadline:
        m = os.stat(a.file).st_mtime_ns
        settled = m != a.mtime and m == seen
        try:
            ok = settled and ET.parse(a.file) is not None
        except ET.ParseError:
            ok = False
        if ok:
            return cmd_info(a)
        seen = m
        time.sleep(a.interval)
    sys.exit(f"timeout: {a.file} unchanged after {a.timeout}s (mtime_ns {os.stat(a.file).st_mtime_ns})")


# ---------- writing ----------

def stroke_markup(pts, color, width, ts):
    comx = sum(p[0] for p in pts) / len(pts)
    comy = sum(p[1] for p in pts) / len(pts)
    rel = " ".join(f"{b[0] - a[0]:.3f} {b[1] - a[1]:.3f}" for a, b in zip(pts, pts[1:]))
    return (f'<path class="write-stroke-pen" fill="none" stroke="{color}" stroke-width="{width:g}" '
            f'stroke-linecap="round" stroke-linejoin="round" __comx="{comx:.3f}" __comy="{comy:.3f}" '
            f'__timestamp="0x{ts:x}" d="M{pts[0][0]:.3f} {pts[0][1]:.3f} l{rel}" />\n    ')


def hershey_strokes(text, x, y, size, font):
    """Polylines for text whose first line's top-left is (x, y); `size` is the line height."""
    from HersheyFonts import HersheyFonts
    hf = HersheyFonts()
    hf.load_default_font(font)
    hf.normalize_rendering(size)
    out = []
    for i, line in enumerate(text.split("\n")):
        top = y + i * size * 1.4
        out += [[(x + px, top + size - py) for px, py in st] for st in hf.strokes_for_text(line)]
    return [st for st in out if len(st) > 1]


def cmd_text(a):
    nb = Notebook(a.file)
    strokes = hershey_strokes(a.text.replace("\\n", "\n"), a.x, a.y, a.size, a.font)
    ts = now_ms()
    width = a.width or max(1.2, a.size / 10)
    nb.insert_content(a.page, "".join(stroke_markup(st, a.color, width, ts + i) for i, st in enumerate(strokes)))
    nb.save(a.expect_mtime)
    xs = [p[0] for st in strokes for p in st]
    ys = [p[1] for st in strokes for p in st]
    bb = [round(min(xs)), round(min(ys)), round(max(xs)), round(max(ys))]
    emit(mtime_ns=nb.mtime_ns, page=a.page, strokes=len(strokes), bbox=bb, off_page=off_page(nb, a.page, bb))


def cmd_stroke(a):
    nb = Notebook(a.file)
    lines = [[tuple(float(v) for v in p.split(",")) for p in seg.split()] for seg in a.points.split(";")]
    lines = [ln + ln[:1] if a.closed else ln for ln in lines if len(ln) > 1]
    ts = now_ms()
    nb.insert_content(a.page, "".join(stroke_markup(ln, a.color, a.width, ts + i) for i, ln in enumerate(lines)))
    nb.save(a.expect_mtime)
    pts = [p for ln in lines for p in ln]
    bb = [min(p[0] for p in pts), min(p[1] for p in pts), max(p[0] for p in pts), max(p[1] for p in pts)]
    emit(mtime_ns=nb.mtime_ns, page=a.page, strokes=len(lines), off_page=off_page(nb, a.page, bb))


def clean_d(path):
    """Absolute M/L/Q/C/Z with no consecutive moves -- Write's parser mangles 'M x y m dx dy'."""
    import svgelements as se
    segs = [c for s in path for c in (s.as_cubic_curves() if isinstance(s, se.Arc) else [s])]
    f = lambda p: f"{p.x:.3f} {p.y:.3f}"
    fmt = {se.Line: lambda s: f"L{f(s.end)}",
           se.QuadraticBezier: lambda s: f"Q{f(s.control)} {f(s.end)}",
           se.CubicBezier: lambda s: f"C{f(s.control1)} {f(s.control2)} {f(s.end)}",
           se.Close: lambda s: "Z"}
    out = [(f"M{f(s.end)}" if not isinstance(nxt, (se.Move, type(None))) else "")
           if isinstance(s, se.Move) else fmt[type(s)](s)
           for s, nxt in zip(segs, segs[1:] + [None])]
    return " ".join(o for o in out if o)


def typst_shapes(markup, size, width):
    import svgelements as se
    import typst
    src = (f"#set page(width: {width}pt, height: auto, margin: 0pt, fill: none)\n"
           f"#set text(size: {size}pt)\n{markup}\n")
    with tempfile.TemporaryDirectory() as d:
        p = os.path.join(d, "in.typ")
        open(p, "w").write(src)
        svg = typst.compile(p, format="svg")
    svg = re.sub(rb'^(<svg[^>]*?) width="[^"]*" height="[^"]*"', rb"\1", svg)
    doc = se.SVG.parse(io.BytesIO(svg), reify=True)
    has = lambda paint: paint is not None and paint.value is not None
    shapes = [el for el in doc.elements() if isinstance(el, se.Shape)]
    return ([("fill", se.Path(el), 0) for el in shapes if has(el.fill)] +
            [("stroke", se.Path(el), float(el.stroke_width or 1)) for el in shapes
             if not has(el.fill) and has(el.stroke)])


def cmd_typst(a):
    import svgelements as se
    nb = Notebook(a.file)
    width = a.width or page_attrs(nb.page(a.page)[2])["width"] - a.x - RIGHT_MARGIN
    markup = f"$ {a.source} $" if a.cmd == "math" else a.source
    shapes = typst_shapes(markup, a.size, width)
    boxes = [p.bbox() for _, p, _ in shapes]
    x0, y0 = min(b[0] for b in boxes), min(b[1] for b in boxes)
    m = se.Matrix(f"translate({a.x},{a.y}) translate({-x0},{-y0})")
    placed = [(kind, p * m, w) for kind, p, w in shapes]
    for _, p, _ in placed:
        p.reify()
    boxes = [p.bbox() for _, p, _ in placed]
    bb = [min(b[0] for b in boxes), min(b[1] for b in boxes), max(b[2] for b in boxes), max(b[3] for b in boxes)]
    body = "".join(f'<path d="{clean_d(p)}" />' if kind == "fill" else
                   f'<path fill="none" stroke="{a.color}" stroke-width="{w:.3g}" d="{clean_d(p)}" />'
                   for kind, p, w in placed)
    nb.insert_content(a.page, f'<g class="write-tex" fill="{a.color}" __comx="{(bb[0] + bb[2]) / 2:.3f}" '
                              f'__comy="{(bb[1] + bb[3]) / 2:.3f}" __timestamp="0x{now_ms():x}">{body}</g>\n    ')
    nb.save(a.expect_mtime)
    emit(mtime_ns=nb.mtime_ns, page=a.page, bbox=[round(v) for v in bb], off_page=off_page(nb, a.page, bb))


def cmd_add_page(a):
    nb = Notebook(a.file)
    spans = nb.pages()
    start, end = spans[-1]
    last = nb.text[start:end]
    head = PAGE_RE.match(last).group(0)
    attrs = page_attrs(last)
    body = last[len(head):]
    ruling = body[:body.index("</g>") + len("</g>")]
    newy = attrs["y"] + attrs["height"] + 20
    newhead = re.sub(r' y="[\d.]+"', f' y="{newy:g}"', head)
    page = f"\n{newhead}{ruling}\n  </g>\n</svg>"
    nb.text = nb.text[:end] + page + nb.text[end:]
    nb.text = re.sub(r"(#write-doc-background \{ width: [\d.]+px;\s+height: )[\d.]+px",
                     lambda m: f"{m.group(1)}{round(newy + attrs['height'] + 10)}px", nb.text)
    nb.save(a.expect_mtime)
    emit(mtime_ns=nb.mtime_ns, page=len(spans), width=attrs["width"], height=attrs["height"])


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)

    def add(name, fn, help, write=False, page=True):
        p = sub.add_parser(name, help=help)
        p.add_argument("file")
        p.set_defaults(fn=fn)
        if page:
            p.add_argument("--page", type=int, default=-1, help="page index, negative counts from end (default -1)")
        if write:
            p.add_argument("--expect-mtime", type=int, help="refuse to write unless file mtime_ns matches")
        return p

    add("info", cmd_info, "pages, sizes, element counts, mtime, sync conflicts", page=False)

    p = add("render", cmd_render, "render a page to PNG")
    p.add_argument("--out", "-o", required=True)
    p.add_argument("--zoom", type=float, default=1.5)
    p.add_argument("--crop", help="x0,y0,x1,y1 in page px")
    p.add_argument("--since", type=int, help="dim elements with timestamp (ms) older than this")

    p = add("new", cmd_new, "pages and bboxes of elements newer than --since (ms)", page=False)
    p.add_argument("--since", type=int, required=True)

    p = add("wait", cmd_wait, "wait until the file changes from --mtime, settles, and parses", page=False)
    p.add_argument("--mtime", type=int, required=True)
    p.add_argument("--timeout", type=float, default=180)
    p.add_argument("--interval", type=float, default=2)

    p = add("text", cmd_text, "write single-stroke (Hershey) text as pen strokes", write=True)
    p.add_argument("text")
    p.add_argument("--x", type=float, required=True)
    p.add_argument("--y", type=float, required=True, help="top of the first line")
    p.add_argument("--size", type=float, default=20, help="line height in px")
    p.add_argument("--color", default="#000000")
    p.add_argument("--width", type=float, help="pen width (default size/10)")
    p.add_argument("--font", default="futural", help="futural, scripts, cursive, timesr, greek, ...")

    p = add("stroke", cmd_stroke, "draw polylines: 'x,y x,y ...; x,y x,y ...'", write=True)
    p.add_argument("points")
    p.add_argument("--color", default="#000000")
    p.add_argument("--width", type=float, default=2.4)
    p.add_argument("--closed", action="store_true")

    for name, size, help in (("math", 26, "typeset Typst math (display mode) as one movable group"),
                             ("typeset", 20, "typeset arbitrary Typst markup as one movable group")):
        p = add(name, cmd_typst, help, write=True)
        p.add_argument("source")
        p.add_argument("--x", type=float, required=True)
        p.add_argument("--y", type=float, required=True, help="top of the ink")
        p.add_argument("--size", type=float, default=size, help=f"font size in px (default {size})")
        p.add_argument("--width", type=float,
                       help="wrap width in px (default: to 20 px from the page's right edge)")
        p.add_argument("--color", default="#000000")

    add("add-page", cmd_add_page, "append a blank page with the last page's size and ruling",
        write=True, page=False)

    a = ap.parse_args()
    a.fn(a)


if __name__ == "__main__":
    main()
