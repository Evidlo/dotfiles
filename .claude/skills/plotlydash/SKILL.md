---
name: plotlydash
description: Build fast, responsive Plotly Dash apps. Use when creating or modifying a Dash app — covers server lifecycle, minimizing browser/server data transfer, and efficient rendering patterns.
---

# Plotly Dash Skill

## Goal
Build fast, responsive Dash apps. Assume a slow connection — interactions (clicks, hovers) must feel instant.

## Server startup / restart

Apps run in an atch session. To start or restart:
```bash
echo -n $'\x03' | atch push <session> && sleep 1 && printf 'cd <dir> && python <app>.py\n' | atch push <session>
```
Include this two-liner as a comment near `app.run(...)` so future agents can find it.

## Minimal data on interaction

**Every Input and State is uploaded to the server on each callback fire** — Dash sends all of them regardless of whether you use them. Large arrays in `dcc.Store` mean large uploads on every click.

Rules:
- Never put image/array data in a Store if it will be a State of a click/hover callback.
- Keep Stores to tiny metadata: keys, indices, short lists.
- For large arrays computed once (on dropdown change), use a **server-side cache**:

```python
_cache = {}  # module-level, lives on the server

# write callback (fires on dropdown change, not on click)
def update_store(selection):
    _cache['img'] = compute_large_array(selection)
    return {'ready': True}  # tiny flag in the Store

# click callback — reads cache directly, no large State
def on_click(click_data, meta):  # meta is tiny
    col = click_data['points'][0]['x']
    return _cache['img'][:, col].tolist()
```

This works for single-worker dev servers (the typical localhost case).

## Float16 for heatmaps

Cast before passing to `go.Heatmap` — halves download size with negligible visual difference:
```python
go.Heatmap(z=arr.astype(np.float16), ...)
```

## Patch() for partial layout updates

Use `dash.Patch()` for surgical updates (e.g. crosshair lines on hover) to avoid re-sending the full figure:
```python
from dash import Patch

def on_hover(hover_data):
    patched = Patch()
    patched['layout']['shapes'] = [...]
    return patched
```

## prevent_initial_call

Always set `prevent_initial_call=True` on click/hover callbacks — they have no meaningful state on app load and will error or silently no-op without it:
```python
@app.callback(..., prevent_initial_call=True)
def on_click(click_data, ...):
    ...
```
