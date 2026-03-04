#!/bin/bash
#=========================================================================================#
# Convert Excel (.xlsx) into CSV files
# Default: logs/excel2csv/<relative path>/<file name>/
# Option -s: Save to same directory as source file
# Usage: ./excel2csv.sh [-s] <xlsx_file>
#=========================================================================================#

#set -e  # Stop script if any command fails

show_help() {
  echo "Usage: ./excel2csv.sh [-s] <xlsx_file>"
  echo "Description: Convert Excel file (.xlsx) into CSV files per sheet"
  echo "Output:"
  echo "  Default:"
  echo "    logs/excel2csv/<relative path>/<filename>/ with CSV files"
  echo "  Option -s:"
  echo "    Saves CSV files to same directory as input .xlsx"
  echo
  echo "Example:"
  echo "  Input:"
  echo "    Project/Design/spec.xlsx"
  echo "    Project/Data/Models/chart.xlsx"
  echo
  echo "  Output (default):"
  echo "    Project/"
  echo "      └─ logs/"
  echo "           └─ excel2csv/"
  echo "                ├─ Design/spec/"
  echo "                │     ├─ 01_summary.csv"
  echo "                │     └─ 02_io.csv"
  echo "                └─ Data/Models/chart/"
  echo "                      ├─ 01_main.csv"
  echo "                      └─ 02_backup.csv"
  echo
  echo "  Output (-s):"
  echo "    Project/Design/spec/01_summary.csv"
  echo "    Project/Data/Models/chart/01_main.csv"
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

# Absolute path of input
XLSX_PATH="$(realpath "$1")"
XLSX_FILE="$(basename "$XLSX_PATH" )"
XLSX_NAME="$(basename "$XLSX_PATH" .xlsx)"
XLSX_DIR="$(dirname "$XLSX_PATH")"

# Determine output location
if $SAVE_LOCAL; then
  OUT_DIR="${XLSX_DIR}/${XLSX_NAME}"
else
  ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")"
  REL_PATH="$(realpath --relative-to="$ROOT_DIR" "$XLSX_DIR")"
  OUT_DIR="${ROOT_DIR}/logs/excel2csv/${REL_PATH}/${XLSX_NAME}"
fi

mkdir -p "$OUT_DIR"
echo "[XLSX2CSV] $XLSX_PATH => $OUT_DIR"

# Convert sheets using xlsx2csv
PYTHONWARNINGS="ignore" xlsx2csv --all "$XLSX_PATH" "$OUT_DIR" 2>/dev/null

# Remove old indexed files
find "$OUT_DIR" -type f -name "[0-9][0-9]_*.csv" -delete

# Rename CSV files with index and sanitized names
pushd "$OUT_DIR" >/dev/null

index=1
for file in *.csv; do
  [[ -f "$file" ]] || continue

  if [[ "$file" =~ ^[0-9][0-9]_ ]]; then
    continue
  fi

  # Replace spaces in filename
  sanitized="$(echo "$file" |  sed -e 's/ /_/g' -e 's/>/_/g' -e 's/</_/g')"
  prefix=$(printf "%02d" "$index")
  new_file="${prefix}_${sanitized}"

  mv -- "$file" "$new_file"
  echo " └─ $new_file"

  index=$((index + 1))
done

popd >/dev/null
