#!/usr/bin/env bash
# Generates the final HTML page for gh-pages

set -euo pipefail

SRC_DIR=".github/pages"
DEST_DIR="gh-pages"

mkdir -p "$DEST_DIR"

# Ensure style.css exists (fallback minimal style if missing)
if [[ -f "$SRC_DIR/style.css" ]]; then
  cp "$SRC_DIR/style.css" "$DEST_DIR/style.css"
else
  cat > "$DEST_DIR/style.css" <<'CSS'
body {
  font-family: system-ui, sans-serif;
  margin: 2rem;
  background: #fdfdfd;
}
h1 {
  color: #0055aa;
}
table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 1.5rem;
}
td, th {
  padding: 0.6rem;
  border: 1px solid #ddd;
}
a {
  color: #0066cc;
}
CSS
fi

# Handle optional template parts
HEADER=$(cat "$SRC_DIR/header.html" 2>/dev/null || echo "<header><h1>Govix OS Downloads</h1></header>")
FOOTER=$(cat "$SRC_DIR/footer.html" 2>/dev/null || echo "<footer><p>© $(date +%Y) Govix Project</p></footer>")
TEMPLATE=$(cat "$SRC_DIR/index.template.html" 2>/dev/null || cat <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Govix OS Downloads</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <!--HEADER-->
  <table>
    <thead><tr><th>Date</th><th>File</th><th>Download</th></tr></thead>
    <tbody>
      <!--TABLE-->
    </tbody>
  </table>
  <!--FOOTER-->
</body>
</html>
HTML
)

# Ensure builds.json exists (fallback empty)
if [[ ! -f "$DEST_DIR/builds.json" ]]; then
  echo "[]" > "$DEST_DIR/builds.json"
fi

# Safely generate rows (if builds.json is valid JSON)
if jq empty "$DEST_DIR/builds.json" 2>/dev/null; then
  ROWS=$(jq -r '.[] | "<tr><td>\(.date)</td><td>\(.file)</td><td><a href=\"\(.link)\" target=\"_blank\">Download</a></td></tr>"' "$DEST_DIR/builds.json")
else
  echo "⚠️ Invalid builds.json — using placeholder table."
  ROWS="<tr><td colspan='3'>No builds available</td></tr>"
fi

# Build final page
echo "$TEMPLATE" \
  | sed "s|<!--HEADER-->|$HEADER|" \
  | sed "s|<!--TABLE-->|$ROWS|" \
  | sed "s|<!--FOOTER-->|$FOOTER|" \
  > "$DEST_DIR/index.html"

echo "✅ Page generated successfully: $DEST_DIR/index.html"
