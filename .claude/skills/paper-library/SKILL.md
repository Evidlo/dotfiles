---
name: paper-library
description: Make a directory of research PDFs useful to an agent brainstorming with a user - build a grep-able catalog plus Markdown transcriptions, then query them. Use when pointed at a folder of papers, asked to index/catalog a paper collection, or asked which paper covers a topic. Triggers on "index these papers", "what paper covers X", "search the literature folder", or an AGENTS.md beside a pile of PDFs.
---
# Paper library

INDEX if `AGENTS.md` and `md/` are missing, SEARCH if they exist.

## INDEX
Ask first whether to run the transcription pass on a GPU machine, note it may
take several hours, and offer to queue it overnight.

Catalog from front matter, without waiting for transcription:

    for f in *.pdf; do pdftotext -f 1 -l 2 -layout "$f" - | head -60; done

`AGENTS.md` gets one `###` entry per paper, the heading being the exact filename
so a grep hit resolves. Body is a citation and a line on what the paper is useful
for *here* - that line is why the catalog beats `ls`. Check it after building,
and whenever papers come or go:

    diff <(grep '^### ' AGENTS.md | sed 's/^### //' | tr ',' '\n' | sed 's/^ *//;s/\.pdf$//' | grep -v '^$' | sort -u) \
         <(ls *.pdf | sed 's/\.pdf$//' | sort -u)

Transcribe with `marker` or `docling`; both emit LaTeX for equations. Each worker
holds several GB of VRAM, so measure one before raising `N`. `--skip_existing`
makes this the incremental pass too.

    marker . --output_dir md --output_format markdown --skip_existing --workers N

## SEARCH
Grep `AGENTS.md` for candidate filenames, then grep `md/`, not the PDFs. In a
thesis, `rg '^#' md/<name>/<name>.md` first and search within a section. Open a
PDF only for figures. A paper with no `md/` isn't indexed: transcribe it rather
than quoting equations out of `rga` or `pdftotext`, which flatten them.
