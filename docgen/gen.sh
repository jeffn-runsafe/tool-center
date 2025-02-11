#!/bin/bash
set -eu

# Description
DESC="Generate HTML Schema navigator for CycloneDX Tool Center"

# Paths (adjust if needed)
THIS_PATH="$(realpath "$(dirname "$0")")"
SCHEMA_PATH="$(realpath "$THIS_PATH/..")"
DOCS_PATH="$THIS_PATH/docs"
TEMPLATES_PATH="$THIS_PATH/templates"

prepare () {
  # Check if generate-schema-doc is installed
  if ! command -v generate-schema-doc > /dev/null 2>&1; then
    # Install dependencies from local requirements.txt
    python -m pip install -r "$THIS_PATH/requirements.txt"
  fi
}

generate () {
  local title="CycloneDX Tool Center JSON Reference"
  echo "Generating: $title"

  local SCHEMA_FILE="$SCHEMA_PATH/tools.schema.json"
  echo "SCHEMA_FILE: $SCHEMA_FILE"

  local OUT_FILE="$DOCS_PATH/index.html"
  local OUT_DIR
  OUT_DIR="$(dirname "$OUT_FILE")"
  rm -rf "$OUT_DIR"
  mkdir -p "$OUT_DIR"

  # Generate HTML documentation from the JSON schema
  generate-schema-doc \
    --config no_link_to_reused_ref \
    --config no_show_breadcrumbs \
    --config no_collapse_long_descriptions \
    --deprecated-from-description \
    --config title="$title" \
    --config custom_template_path="$TEMPLATES_PATH/cyclonedx/base.html" \
    --minify \
    "$SCHEMA_FILE" \
    "$OUT_FILE"

  # Update placeholders in the generated HTML
  sed -i -e "s/\${quotedTitle}/\"$title\"/g" "$OUT_FILE"
  sed -i -e "s/\${title}/$title/g" "$OUT_FILE"
}

# Main
prepare
generate

exit 0
