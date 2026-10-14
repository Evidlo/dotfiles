---
name: styluslabs
description: Read and write Stylus Labs Write handwritten notebooks (.svg) together with the user — see their handwriting and diagrams, answer or grade on the page, add problems, typeset math (Typst) and draw. Use when the user mentions Write, Stylus Labs, a handwritten notebook/notes .svg, or says they're "done writing" in a notebook you are working on.
---

# Working in a Stylus Labs Write notebook

Write saves each notebook as one `.svg`: a stack of `<svg class="write-page">` pages whose ink lives in a
`write-content` group. Every element carries `__timestamp="0x<ms>"`, which is how you tell new ink from old.
Write (desktop and Android) reloads a file that changed on disk within ~5 s **if the user has no unsaved
ink**; otherwise it shows a "Save conflict" dialog.

All operations go through one script with inline dependencies (typst, svgelements, resvg-py, Hershey-Fonts),
installed automatically by `uv` on first run:

```bash
W="uv run -q ~/.claude/skills/styluslabs/scripts/wnote.py"
$W --help            # and $W <command> --help
```

Coordinates are page-local px (origin top-left of the page, y down); `--page` is a 0-based index,
negative from the end, default `-1`. Typical page: 772 × 1302 px with a 20 px grid.
Every command prints one JSON line. Writing commands report the ink `bbox` and `off_page` (sides the
content runs past). **If `off_page` is non-empty, fix it**: roll back (below) and redo with a smaller
`--size`, a `--width` for Typst, shorter or split `text` lines, or a new page.

## Commands

| Command | Purpose |
|---|---|
| `info FILE` | pages (size, element count, `latest_ms`), `mtime_ns`, `now_ms`, Syncthing `sync_conflicts` |
| `render FILE -o out.png [--page N] [--zoom 1.5] [--crop x0,y0,x1,y1] [--since MS]` | PNG of a page; `--since` dims everything older so new ink stands out. View it with Read. |
| `new FILE --since MS` | which pages have elements newer than MS, with a bbox per page |
| `wait FILE --mtime NS [--timeout 180]` | block until the file's mtime differs from NS, has settled, and parses; then prints `info` |
| `text FILE "..." --x --y [--size 20] [--color] [--font futural\|scripts\|cursive\|timesr\|greek]` | single-stroke text as real pen strokes (`\n` for new lines); `--y` is the top of the first line |
| `math FILE 'typst math' --x --y [--size 26] [--width] [--color]` | display-mode Typst math, inserted as one movable group |
| `typeset FILE 'typst markup' --x --y [--size 20] [--width] [--color]` | arbitrary Typst markup (text with inline `$...$` math, lists, tables) as one group; wraps at `--width` px, by default 20 px short of the page's right edge |
| `stroke FILE "x,y x,y ...; x,y ..." [--color] [--width 2.4] [--closed]` | polylines: check marks, underlines, arrows, boxes, diagram lines |
| `add-page FILE` | append a blank page copying the last page's size and ruling; prints the new index |

Every writing command takes `--expect-mtime NS`. **Always pass the `mtime_ns` from your most recent
read**; the script refuses to write if the file changed underneath you (e.g. the user saved, or Syncthing
delivered a new version), and you should re-read rather than retry blindly. Writes are atomic
(temp file + rename) and the previous version is backed up to `~/.cache/wnote/backups/<name>.<mtime_ns>`
(last 20 per file). To undo your own last write, copy the newest backup back over the file — but only
if `info` still shows the `mtime_ns` your write returned (otherwise the user has saved since).

## Workflow

1. **Orient:** `info`, then `render` the relevant page (usually the last) and look at it. Remember
   `mtime_ns` and `now_ms` — the latter is your `--since` marker for the user's next turn.
2. **Write:** place content in empty space you have seen in a render; returned bboxes tell you where it
   landed. Re-render to check the result when layout matters.
3. **Hand over:** tell the user what you added and that they should **save in Write before saying they're
   done** (unsaved ink + an incoming change = conflict dialog).
4. **When the user says they're done:** `wait --mtime <last mtime_ns>` (handles sync delay; if it times
   out, say so — they may not have saved, or sync is slow). Check `sync_conflicts`; if any exist, stop and
   ask which version is right. Then `new --since <marker>` and `render --since <marker>`, cropping with
   `--crop` and `--zoom 2`–`3` around the reported bbox to read handwriting reliably.

## Conventions

- Never modify or delete the user's ink; only add. Use **red** (`#FF0000`) for feedback/corrections, black
  for problems and content.
- Typst math, not LaTeX: `x^2`, `sqrt(pi)/2`, `integral_0^oo`, `sum_(n=0)^oo`, `mat(a, b; c, d)`,
  `vec(x, y)`, `cases(x & "if" x >= 0, -x & "otherwise")`, `f(x) &= ... \ g(x) &= ...` (aligned lines),
  `RR`, `EE`, `dif x`, `arrow.r`, `alpha`. Quote multi-letter words: `"if"`. Group fraction operands
  and separate function arguments from subscripts: `(f^((n))(a))/(n!)`, `R_n (x)` — `f^((n))(a)/(n!)`
  and `R_n(x)` parse differently than intended.
- Use `text` (Hershey strokes) for short handwritten-feeling notes ("Correct!", labels); it erases like
  ink. Use `math`/`typeset` for anything mathematical; the group is selectable and movable as one object
  in Write and deleted whole by the eraser.
- Write stores user moves/rotations as a `transform` on the element — `render` and `new` account for it.
- A handwriting misread is cheap to avoid: zoom in before grading, and quote what you read back to the user.
