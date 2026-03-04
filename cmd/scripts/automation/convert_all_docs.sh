#!/bin/bash

#=============================================================#
# One-pass converter script for DOCX and XLSX files
# Results stored under logs/word2md/ and logs/excel2csv/
# Unified logging under logs/convert_all.log
#=============================================================#

set -e  # Stop on error
ROOT_DIR="../"
LOG_DIR="${ROOT_DIR}/logs"
LOG_FILE="${LOG_DIR}/convert_all.log"
SCRIPT_PATH="../scripts"

command -v pandoc >/dev/null || {
  echo "Error: pandoc is not installed."
  exit 1
}

command -v xlsx2csv >/dev/null || {
  echo "Error: pandoc is not installed."
  exit 1
}

mkdir -p "$LOG_DIR"
> "$LOG_FILE"

echo "[INFO] Starting document conversion under: $ROOT_DIR" | tee -a "$LOG_FILE"

# Convert DOCX files
find "$ROOT_DIR" -type f -name "*.docx" | while read -r docx; do
  $SCRIPT_PATH/word2md.sh "$docx"  | tee -a "$LOG_FILE"
done

# Convert XLSX files
find "$ROOT_DIR" -type f -name "*.xlsx" | while read -r xlsx; do
  $SCRIPT_PATH/excel2csv.sh "$xlsx"  | tee -a "$LOG_FILE"
done
echo "[INFO] All conversions complete. Log saved to: $LOG_FILE"
