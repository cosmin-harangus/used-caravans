# used-caravans Repo Setup — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bootstrap the `used-caravans` repository with the full build system, initial content outlines, GitHub Actions release workflow, and push it to a new public GitHub repo.

**Architecture:** Standalone repo cloned from the caravan-lifestyle pattern — same pandoc/wkhtmltopdf/pdfunite toolchain, same dual-language (EN + RO) build, same auto-release CI. Content starts as rough outlines that grow over time.

**Tech Stack:** Bash, Pandoc, wkhtmltopdf, poppler-utils (pdfunite), GitHub Actions (`softprops/action-gh-release@v2`), `gh` CLI.

---

### Task 1: Commit existing docs and create .gitignore

The design spec and this plan are already on disk but not yet staged.

**Files:**
- Modify: `.gitignore` (create)

- [ ] **Step 1: Stage existing docs**

```bash
cd /Users/cosmin/go/src/github.com/cosmin-harangus/used-caravans
git add docs/
git commit -m "docs: add design spec and implementation plan"
```

- [ ] **Step 2: Create `.gitignore`**

```
dist/
```

- [ ] **Step 3: Stage and commit**

```bash
git add .gitignore
git commit -m "chore: add .gitignore"
```

---

### Task 3: Copy and adapt the template directory

The `template/` directory from caravan-lifestyle is copied wholesale. All files are reused as-is — the visual identity starts identical and diverges later as cover assets are created.

**Files:**
- Create: `template/template.html`
- Create: `template/style.css`
- Create: `template/epub.css`
- Create: `template/filters.lua`

- [ ] **Step 1: Copy template files**

```bash
cp -r /Users/cosmin/go/src/github.com/cosmin-harangus/caravan-lifestyle/template/template.html \
      /Users/cosmin/go/src/github.com/cosmin-harangus/caravan-lifestyle/template/style.css \
      /Users/cosmin/go/src/github.com/cosmin-harangus/caravan-lifestyle/template/epub.css \
      /Users/cosmin/go/src/github.com/cosmin-harangus/caravan-lifestyle/template/filters.lua \
      /Users/cosmin/go/src/github.com/cosmin-harangus/used-caravans/template/
```

- [ ] **Step 2: Verify files exist**

```bash
ls /Users/cosmin/go/src/github.com/cosmin-harangus/used-caravans/template/
```

Expected output: `epub.css  filters.lua  style.css  template.html`

- [ ] **Step 3: Commit**

```bash
cd /Users/cosmin/go/src/github.com/cosmin-harangus/used-caravans
git add template/
git commit -m "chore: copy template from caravan-lifestyle"
```

---

### Task 3: Write build.sh

**Files:**
- Create: `build.sh`

The build script is structurally identical to caravan-lifestyle's but with:
- Different `CONTENT_FILES` list (starts with just `outline.md`)
- Different output base names (`used-caravans` and `used-caravans-ro`)
- Different book titles and metadata
- Placeholder cover paths (cover assets don't exist yet — the script will fail on build until covers are added, which is expected)

- [ ] **Step 1: Create `build.sh`**

```bash
cat > /Users/cosmin/go/src/github.com/cosmin-harangus/used-caravans/build.sh << 'BUILDSCRIPT'
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CSS_PATH="$SCRIPT_DIR/template/style.css"

mkdir -p dist

# List of content files in order (same structure for both languages)
# Add new files here as content grows
CONTENT_FILES=(
  outline.md
)

# Build one language edition
# Usage: build_edition <content_dir> <cover_pdf> <epub_cover> <title> <subtitle> <edition> <output_base> [<lang>]
build_edition() {
  local content_dir="$1"
  local cover_pdf="$2"
  local epub_cover="$3"
  local title="$4"
  local subtitle="$5"
  local edition="$6"
  local output_base="$7"
  local lang="${8:-en}"

  local combined="dist/${output_base}-combined.md"
  local combined_html="dist/${output_base}-combined.html"
  local body_pdf="dist/${output_base}-body.pdf"
  local output_pdf="dist/${output_base}.pdf"
  local output_epub="dist/${output_base}.epub"

  echo "--- Building: $title ($lang) ---"

  > "$combined"
  for f in "${CONTENT_FILES[@]}"; do
    cat "$content_dir/$f" >> "$combined"
    printf '\n\n' >> "$combined"
  done

  pandoc "$combined" \
    --from=markdown \
    --to=html5 \
    --lua-filter=template/filters.lua \
    --template=template/template.html \
    --css="$CSS_PATH" \
    --table-of-contents \
    --toc-depth=2 \
    --metadata title="$title" \
    --metadata subtitle="$subtitle" \
    --metadata edition="$edition" \
    --metadata lang="$lang" \
    --standalone \
    -o "$combined_html"

  wkhtmltopdf \
    --enable-local-file-access \
    --page-size A4 \
    --margin-top    20mm \
    --margin-bottom 20mm \
    --margin-left   20mm \
    --margin-right  20mm \
    --footer-center "[page]" \
    --footer-font-size 9 \
    --footer-spacing 5 \
    "$combined_html" \
    "$body_pdf"

  pdfunite "$cover_pdf" "$body_pdf" "$output_pdf"

  pandoc "$combined" \
    --from=markdown \
    --to=epub3 \
    --epub-cover-image="$epub_cover" \
    --lua-filter=template/filters.lua \
    --css="$SCRIPT_DIR/template/epub.css" \
    --table-of-contents \
    --toc-depth=2 \
    --metadata title="$title" \
    --metadata subtitle="$subtitle" \
    --metadata author="Cosmin Harangus" \
    --metadata lang="$lang" \
    -o "$output_epub"

  echo "✓ Built: $output_pdf"
  echo "✓ Built: $output_epub"
  wc -l "$combined" | awk '{print "  Lines: "$1}'
}

# ── English edition ──
build_edition \
  "content" \
  "$SCRIPT_DIR/template/used-caravans-cover.pdf" \
  "$SCRIPT_DIR/template/used-caravans-cover.png" \
  "Finding Our Caravan" \
  "A Family's Search for the Right Used Caravan in Europe" \
  "Romania & Europe · 2026" \
  "used-caravans" \
  "en"

# ── Romanian edition ──
build_edition \
  "content-ro" \
  "$SCRIPT_DIR/template/used-caravans-cover-ro.pdf" \
  "$SCRIPT_DIR/template/used-caravans-cover-ro.png" \
  "În Căutarea Caravanei Noastre" \
  "Căutarea unei Caravane Second-Hand în Europa" \
  "România & Europa · 2026" \
  "used-caravans-ro" \
  "ro"
BUILDSCRIPT
chmod +x /Users/cosmin/go/src/github.com/cosmin-harangus/used-caravans/build.sh
```

- [ ] **Step 2: Commit**

```bash
cd /Users/cosmin/go/src/github.com/cosmin-harangus/used-caravans
git add build.sh
git commit -m "chore: add build.sh for EN and RO editions"
```

---

### Task 4: Create initial content outlines

**Files:**
- Create: `content/outline.md`
- Create: `content-ro/outline.md`

- [ ] **Step 1: Create `content/outline.md`**

```bash
mkdir -p /Users/cosmin/go/src/github.com/cosmin-harangus/used-caravans/content
```

Write the following to `content/outline.md`:

```markdown
# Finding Our Caravan — Rough Outline

> This is a working draft. Structure and chapter names will evolve as the story unfolds.

## Part 1: Who We Are

Who this is about — a family of four, life in Romania, wanting weekends off-grid and a summer vacation somewhere beautiful. What caravanning means to us and why we started this search.

## Part 2: What We're Looking For

Our requirements and non-negotiables. Budget, size, age, condition. What we will and won't compromise on. How we defined "good enough" before we'd seen anything.

## Part 3: How We Approached the Search

Where we looked — Romanian marketplaces, Facebook groups, dealers, word of mouth. What the market looks like. First impressions before we'd seen a single caravan in person.

## Part 4: The Search

What we saw, who we talked to, what we learned along the way. Each experience that changed how we thought about what we wanted.

## Part 5: The One

The caravan we chose. What it was, what made it right, what the purchase looked like.

## Part 6: First Vacation

The July trip. Where we went, how the caravan performed, what we'd do differently next time.
```

- [ ] **Step 2: Create `content-ro/outline.md`**

```bash
mkdir -p /Users/cosmin/go/src/github.com/cosmin-harangus/used-caravans/content-ro
```

Write the following to `content-ro/outline.md`:

```markdown
# În Căutarea Caravanei Noastre — Schiță de Lucru

> Aceasta este o schiță de lucru. Structura și titlurile capitolelor vor evolua pe măsură ce povestea se desfășoară.

## Partea 1: Cine Suntem

Despre cine este vorba — o familie de patru, viața în România, dorința de weekenduri off-grid și o vacanță de vară undeva frumos. Ce înseamnă viața cu caravana pentru noi și de ce am început această căutare.

## Partea 2: Ce Căutăm

Cerințele și lucrurile negociabile. Buget, dimensiuni, vechime, stare. La ce suntem și nu suntem dispuși să facem compromisuri. Cum am definit „suficient de bun" înainte să fi văzut ceva.

## Partea 3: Cum Am Abordat Căutarea

Unde am căutat — piețe online din România, grupuri de Facebook, dealeri, gură la gură. Cum arată piața. Primele impresii înainte să fi văzut vreo caravană în persoană.

## Partea 4: Căutarea

Ce am văzut, cu cine am vorbit, ce am învățat pe parcurs. Fiecare experiență care ne-a schimbat perspectiva asupra a ceea ce ne dorim.

## Partea 5: Cea Aleasă

Caravana pe care am ales-o. Ce era, ce o făcea potrivită, cum a decurs achiziția.

## Partea 6: Prima Vacanță

Excursia din iulie. Unde am mers, cum s-a comportat caravana, ce am face diferit data viitoare.
```

- [ ] **Step 3: Commit**

```bash
cd /Users/cosmin/go/src/github.com/cosmin-harangus/used-caravans
git add content/ content-ro/
git commit -m "docs: add initial EN and RO content outlines"
```

---

### Task 5: Create GitHub Actions release workflow

**Files:**
- Create: `.github/workflows/release.yml`

Identical to caravan-lifestyle's workflow but with the 4 artifact names updated.

- [ ] **Step 1: Create workflow directory and file**

```bash
mkdir -p /Users/cosmin/go/src/github.com/cosmin-harangus/used-caravans/.github/workflows
```

Write the following to `.github/workflows/release.yml`:

```yaml
name: Build and Release

on:
  push:
    branches: [main]

permissions:
  contents: write

jobs:
  build-and-release:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Compute next version
        run: |
          LATEST=$(git tag --sort=-v:refname | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | head -n1)
          if [ -z "$LATEST" ]; then
            NEW_TAG="v1.0.0"
          else
            PATCH=$(echo "$LATEST" | awk -F. '{print $3}')
            BASE=$(echo "$LATEST" | awk -F. '{print $1"."$2"."}')
            NEW_TAG="${BASE}$((PATCH + 1))"
          fi
          echo "NEW_TAG=$NEW_TAG" >> "$GITHUB_ENV"
          echo "Next release: $NEW_TAG"

      - name: Install build dependencies
        run: |
          sudo apt-get update -qq
          sudo apt-get install -y pandoc wkhtmltopdf poppler-utils

      - name: Build
        run: bash build.sh

      - name: Push tag
        run: |
          git tag "$NEW_TAG"
          git push origin "$NEW_TAG"

      - name: Create GitHub release
        uses: softprops/action-gh-release@v2
        with:
          tag_name: ${{ env.NEW_TAG }}
          name: Release ${{ env.NEW_TAG }}
          body: ${{ github.event.head_commit.message }}
          files: |
            dist/used-caravans.pdf
            dist/used-caravans.epub
            dist/used-caravans-ro.pdf
            dist/used-caravans-ro.epub
```

- [ ] **Step 2: Commit**

```bash
cd /Users/cosmin/go/src/github.com/cosmin-harangus/used-caravans
git add .github/workflows/release.yml
git commit -m "chore: add GitHub Actions build and release workflow"
```

---

### Task 6: Create GitHub repo and push

- [ ] **Step 1: Create the public GitHub repo**

```bash
gh repo create cosmin-harangus/used-caravans --public --description "Finding Our Caravan — A family's search for the right used caravan in Europe"
```

- [ ] **Step 2: Add remote and push**

```bash
cd /Users/cosmin/go/src/github.com/cosmin-harangus/used-caravans
git remote add origin git@github.com:cosmin-harangus/used-caravans.git
git push -u origin main
```

- [ ] **Step 3: Verify on GitHub**

```bash
gh repo view cosmin-harangus/used-caravans --web
```

Expected: browser opens to the new repo with all files visible.
