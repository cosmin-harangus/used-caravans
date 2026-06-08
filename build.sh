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

  if [ -f "$cover_pdf" ]; then
    pdfunite "$cover_pdf" "$body_pdf" "$output_pdf"
  else
    echo "  (no cover PDF found — skipping cover merge)"
    cp "$body_pdf" "$output_pdf"
  fi

  local epub_cover_arg=""
  [ -f "$epub_cover" ] && epub_cover_arg="--epub-cover-image=$epub_cover"

  pandoc "$combined" \
    --from=markdown \
    --to=epub3 \
    ${epub_cover_arg:+"$epub_cover_arg"} \
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
