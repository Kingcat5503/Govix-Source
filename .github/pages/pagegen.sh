#!/usr/bin/env bash
set -e

SRC_DIR=".github/pages"
DEST_DIR="gh-pages"

mkdir -p "$DEST_DIR"

HEADER=$(cat "$SRC_DIR/header.html")
FOOTER=$(cat "$SRC_DIR/footer.html")

# Load latest GitHub release metadata (already downloaded into latest.json)
LATEST_JSON="latest.json"

LATEST_TAG=$(jq -r '.tag_name' "$LATEST_JSON")
LATEST_ASSET=$(jq -r '.assets[] | select(.name | contains("iso")) | .browser_download_url' "$LATEST_JSON")
LATEST_SIZE=$(jq -r '.assets[] | select(.name | contains("iso")) | .size' "$LATEST_JSON")
LATEST_PUBLISHED=$(jq -r '.published_at' "$LATEST_JSON")

# Format size (human readable)
LATEST_SIZE_HR=$(numfmt --to=iec <<< "$LATEST_SIZE")

# Generate table row for latest
LATEST_ROW="<tr>
<td><strong>${LATEST_TAG}</strong></td>
<td>${LATEST_PUBLISHED}</td>
<td>${LATEST_SIZE_HR}</td>
<td><a href=\"${LATEST_ASSET}\">Download ISO</a></td>
</tr>"

############################################
# Generate full table from all releases
############################################

ALL_RELEASES=$(
  curl -s "https://api.github.com/repos/${GITHUB_REPOSITORY}/releases?per_page=20"
)

ROWS=""

echo "$ALL_RELEASES" | jq -c '.[]' | while read -r RELEASE; do
  TAG=$(echo "$RELEASE" | jq -r '.tag_name')
  DATE=$(echo "$RELEASE" | jq -r '.published_at')
  ASSET_URL=$(echo "$RELEASE" | jq -r '.assets[] | select(.name | contains("iso")) | .browser_download_url')
  SIZE_BYTES=$(echo "$RELEASE" | jq -r '.assets[] | select(.name | contains("iso")) | .size')
  SIZE_HR=$(numfmt --to=iec <<< "$SIZE_BYTES")

  ROWS+="<tr>
  <td>${TAG}</td>
  <td>${DATE}</td>
  <td>${SIZE_HR}</td>
  <td><a href=\"${ASSET_URL}\">Download ISO</a></td>
  </tr>"
done

############################################
# Build final HTML
############################################

cat > "$DEST_DIR/index.html" <<EOF
${HEADER}

<h2>Latest Release</h2>

<table>
<thead>
<tr>
  <th>Version</th>
  <th>Date</th>
  <th>Size</th>
  <th>Download</th>
</tr>
</thead>
<tbody>
${LATEST_ROW}
</tbody>
</table>

<h2>All Releases</h2>

<table>
<thead>
<tr>
  <th>Version</th>
  <th>Date</th>
  <th>Size</th>
  <th>Download</th>
</tr>
</thead>
<tbody>
${ROWS}
</tbody>
</table>

${FOOTER}
EOF
