# used-caravans Repo — Design Spec

**Date:** 2026-06-08

## Overview

A new public GitHub repository (`cosmin-harangus/used-caravans`) that tells the story of searching for and buying a used caravan in Europe, written from personal experience. It builds to PDF and EPUB in both English and Romanian, using the same toolchain as `caravan-lifestyle`. Content is added progressively as the search unfolds — the book is written as it happens.

## Repo

**Name:** `cosmin-harangus/used-caravans`
**Visibility:** Public
**Approach:** Standalone — copied and adapted build system from caravan-lifestyle, no coupling between the two repos.

## Directory Structure

```
used-caravans/
├── build.sh
├── content/              # English Markdown
│   └── outline.md        # Rough draft outline, not final
├── content-ro/           # Romanian Markdown
│   └── outline.md        # Rough draft outline, not final
├── template/             # Copied from caravan-lifestyle, customised for this book
│   ├── template.html
│   ├── style.css
│   ├── epub.css
│   ├── filters.lua
│   └── [cover assets]
├── dist/                 # Build output (gitignored)
└── .github/
    └── workflows/
        └── release.yml
```

## Build System

Copied from caravan-lifestyle and adapted:

- **`build.sh`** — builds two editions:
  - EN: `dist/used-caravans.pdf` + `dist/used-caravans.epub`
  - RO: `dist/used-caravans-ro.pdf` + `dist/used-caravans-ro.epub`
- **Dependencies:** `pandoc`, `wkhtmltopdf`, `poppler-utils` (same as caravan-lifestyle)
- **`.github/workflows/release.yml`** — identical auto-increment patch release workflow (`v0.0.0 → v0.0.1`), attaches all 4 artifacts to each release, uses triggering commit message as release notes. Since there are no prior tags in this repo, the first release will be `v1.0.0` — rename to `v0.0.1` manually if preferred (as was done for caravan-lifestyle's early releases).

## Content Approach

The book is a continuous narrative — a personal story of searching for a used caravan, told as it happens. It is not a reference guide or a log with dated entries.

**Starting content:** One rough outline file per language (`content/outline.md`, `content-ro/outline.md`). These are clearly marked as drafts — placeholders for where the story will go, not final structure.

**How content grows:** The author adds raw material in any form (notes, bullet points, impressions from viewings, conversations). These are then organised, shaped, and written into the book as narrative chapters. The chapter structure emerges from the content, not from a predetermined plan.

**Rough narrative arc (not final):**
1. Who we are and why we want a caravan
2. What we're looking for — requirements and non-negotiables
3. How we approached the search
4. The search itself — what we saw, what we learned, what shifted our thinking
5. The one we chose — and why
6. First vacation with the new caravan

## Template Customisation

The `template/` directory is copied from caravan-lifestyle as a starting point. Cover assets (PDF cover, EPUB cover image) and book metadata (title, subtitle, author) are updated for this book. CSS may diverge over time as the visual identity of this book develops.

## Non-Goals

- No shared template infrastructure between the two repos — they evolve independently.
- No fixed chapter structure at the start — content drives structure.
- No dated journal entries in the book text.
