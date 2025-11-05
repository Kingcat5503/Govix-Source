#!/usr/bin/env bash
# Generates the final HTML page for gh-pages

set -e
SRC_DIR=".github/pages"
DEST_DIR="gh-pages"

mkdir -p "$DEST_DIR"

cp "$SRC_DIR/style.css" "$DEST_DIR/style.css"

HEADER=$(cat "$SRC_DIR/header.html")
FOOTER=$(cat "$SRC_DIR/footer.html")
TEMPLATE=$(cat "$SRC_DIR/index.template.html")

# Insert generated table rows
ROWS=$(jq -r '.[] | "<tr><td>\(.date)</td><td>\(.file)</td><td><a href=\"\(.link)\" target=\"_blank\">Download</a></td></tr>"' "$DEST_DIR/builds.json")

# Build final page
echo "$TEMPLATE" | \
  sed "s|<!--HEADER-->|$HEADER|" | \
  sed "s|<!--TABLE-->|$ROWS|" | \
  sed "s|<!--FOOTER-->|$FOOTER|" \
  > "$DEST_DIR/index.html"

echo "✅ Page generated successfully: $DEST_DIR/index.html"
