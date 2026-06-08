# used-caravans — Claude Context

## What This Project Is

A living book about our family's search for a used caravan in Europe. Written in first person as a continuous narrative (not a log or reference guide). Builds to PDF and EPUB in both English and Romanian.

The book grows as the search happens — we add raw content (notes, impressions, visit summaries) and shape it into chapters. The structure is not fixed. See `docs/superpowers/specs/2026-06-08-used-caravans-repo-design.md` for the full design.

## Build System

Same toolchain as `caravan-lifestyle` (sibling repo at `../caravan-lifestyle`):
- `pandoc` — Markdown → HTML and EPUB
- `wkhtmltopdf` — HTML → PDF
- `pdfunite` (poppler-utils) — merges cover PDF + body PDF

Run: `bash build.sh`

Outputs to `dist/` (gitignored):
- `used-caravans.pdf` + `used-caravans.epub` (English)
- `used-caravans-ro.pdf` + `used-caravans-ro.epub` (Romanian)

## Content Structure

```
content/          # English Markdown files
content-ro/       # Romanian Markdown files (mirrors English structure)
template/         # pandoc HTML template, CSS, Lua filter, cover assets
build.sh          # build script — edit CONTENT_FILES array to add new files
```

**To add new content:**
1. Create a new `.md` file in `content/` and the matching file in `content-ro/`
2. Add the filename to the `CONTENT_FILES` array in `build.sh` (both editions share the same list)

## Cover Assets

Cover assets live in `template/`. Expected filenames:
- `used-caravans-cover.pdf` — EN cover PDF (prepended to body PDF)
- `used-caravans-cover.png` — EN EPUB cover image
- `used-caravans-cover-ro.pdf` — RO cover PDF
- `used-caravans-cover-ro.png` — RO EPUB cover image

If cover files are missing, the build skips the cover merge/EPUB cover and produces coverless output (no error).

## Releases

GitHub Actions (`.github/workflows/release.yml`) runs on every push to `main`:
- Auto-increments patch version tag (`v1.0.0 → v1.0.1`)
- Attaches all 4 artifacts to a GitHub release
- Uses the triggering commit message as release notes

## Rough Narrative Arc

1. Who we are — family of four in Romania, why we want a caravan
2. What we're looking for — requirements and non-negotiables
3. How we approached the search
4. The search — what we saw, learned, and how our thinking evolved
5. The one we chose — and why
6. First vacation — July trip in Europe

Content is currently in `content/outline.md` and `content-ro/outline.md` as rough drafts. Chapters emerge as the author adds material.

## Working Style

- The author adds raw notes/impressions in any form
- We organise and write them into the appropriate part of the narrative
- Do not invent or fabricate content — everything comes from the author's actual experience
- When editing content, preserve the author's voice
