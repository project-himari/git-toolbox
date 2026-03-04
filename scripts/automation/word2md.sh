#!/bin/bash

#============================================================#
# Convert DOCX into Markdown (.md)
# Default: logs/word2md/<relative path>/<filename>.md
# Optional: -s → Save .md next to original .docx
#============================================================#
#set -e  # Stop on error
show_help() {
  echo "Usage: ./word2md.sh [-s] <docx_file>"
  echo "Description: Convert Word (.docx) file into Markdown (.md)"
  echo
  echo "Options:"
  echo "  -s     Save .md file in the same directory as the input .docx"
  echo
  echo "Output (default):"
  echo "  logs/word2md/<relative path>/<filename>.md"
  echo
  echo "Example:"
  echo "  Input:"
  echo "    Project/Document/AAA/sample.docx"
  echo
  echo "  Output (default):"
  echo "    Project/logs/word2md/Document/AAA/sample.md"
  echo
  echo "  Output (-s):"
  echo "    Project/Document/AAA/sample.md"
  exit 0
}

# Parse options
SAVE_LOCAL=false

while [[ "$1" == -* ]]; do
  case "$1" in
    -s)
      SAVE_LOCAL=true
      shift
      ;;
    --help|-h)
      show_help
      ;;
    *)
      echo "Unknown option: $1"
      show_help
      ;;
  esac
done

if [ $# -lt 1 ]; then
  show_help
fi

DOCX_PATH="$(realpath "$1")"
DOCX_NAME="$(basename "$DOCX_PATH" .docx)"
DOCX_DIR="$(dirname "$DOCX_PATH")"

if $SAVE_LOCAL; then
  OUT_PATH="${DOCX_DIR}/${DOCX_NAME}.md"
else
  ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")"
  REL_PATH="$(realpath --relative-to="$ROOT_DIR" "$DOCX_DIR")"
  OUT_DIR="${ROOT_DIR}/logs/word2md/${REL_PATH}"
  mkdir -p "$OUT_DIR"
  OUT_PATH="${OUT_DIR}/${DOCX_NAME}.md"
fi

# Convert using pandoc
pandoc "$DOCX_PATH" -f docx -t gfm --wrap=none --columns=1000 \
  | grep -v "img src" > "$OUT_PATH"

echo "[WORD2MD] $DOCX_PATH => $OUT_PATH"
