#!/bin/bash
set -euo pipefail

ROOT="."
OUTDIR=""
SKIP=0
FORCE=0
MAXLEN=120

# ★デフォルト固定（ユーザー要望）
FLAT=1
IMGDIR="image"
SVG2PNG=1
SVG_WIDTH=1600   # svg->png の横幅（必要なら上げる）

usage() {
  cat <<'EOF'
Usage: epub2md.sh [-d ROOT] [-o OUTDIR] [-s] [-f]
  -d ROOT   : search root (default: .)
  -o OUTDIR : output base dir (mirror structure under OUTDIR)
  -s        : skip if output md exists
  -f        : overwrite (ignore -s)

Defaults (always ON / fixed):
  --flat
  --imgdir=image
  --svg2png

What it does:
  - Find *.epub under ROOT
  - Create book dir per epub (sanitized name)
  - Convert epub -> Markdown (pandoc)
  - Force-copy images from epub (unzip) into image/
  - Flatten image/ subdirs and resolve name collisions
  - Convert SVG in image/ to PNG
  - Rewrite md to use image/ paths
  - Replace <svg><image xlink:href=...></svg> blocks with ![](image/FILE)
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -d) ROOT="${2:-}"; shift 2 ;;
    -o) OUTDIR="${2:-}"; shift 2 ;;
    -s) SKIP=1; shift ;;
    -f) FORCE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "ERROR: Unknown option: $1" >&2; usage; exit 2 ;;
  esac
done

command -v pandoc >/dev/null 2>&1 || { echo "ERROR: pandoc not found" >&2; exit 2; }
command -v python3 >/dev/null 2>&1 || { echo "ERROR: python3 not found" >&2; exit 2; }
command -v unzip >/dev/null 2>&1 || { echo "ERROR: unzip not found" >&2; exit 2; }
if [[ "$SVG2PNG" == "1" ]]; then
  command -v rsvg-convert >/dev/null 2>&1 || { echo "ERROR: rsvg-convert not found. Install: sudo apt install -y librsvg2-bin" >&2; exit 2; }
fi
[[ -d "$ROOT" ]] || { echo "ERROR: root not found: $ROOT" >&2; exit 2; }

ROOT_ABS="$(cd "$ROOT" && pwd)"
OUTDIR_ABS=""
if [[ -n "$OUTDIR" ]]; then
  mkdir -p "$OUTDIR"
  OUTDIR_ABS="$(cd "$OUTDIR" && pwd)"
fi

sanitize() {
  local s="$1"
  s="${s// /_}"     # space -> _
  s="${s//\//_}"
  s="${s//:/_}"
  s="${s//&/_}"
  s="${s//$'\t'/_}"
  s="${s%%[ .]}"    # trim trailing space/dot
  if ((${#s} > MAXLEN)); then
    s="${s:0:MAXLEN}"
  fi
  printf '%s' "$s"
}

# EPUBを展開して画像を image/ に強制コピー（衝突は連番）
force_copy_images_from_epub() {
  local epub="$1"
  local imgdir="$2"

  local work
  work="$(mktemp -d)"
  trap 'rm -rf "$work"' RETURN

  unzip -q "$epub" -d "$work"

  local i=0
  while IFS= read -r -d '' f; do
    local base out
    base="$(basename "$f")"
    out="$imgdir/$base"
    if [[ -e "$out" ]]; then
      i=$((i+1))
      out="$imgdir/${i}_$base"
    fi
    cp -f "$f" "$out"
  done < <(find "$work" -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' -o -iname '*.webp' -o -iname '*.svg' \) \
    -print0)
}

# image/配下のサブディレクトリを全部 image/ 直下へ移動（衝突は連番）
flatten_dir() {
  local dir="$1"
  [[ -d "$dir" ]] || return 0

  while IFS= read -r -d '' src; do
    local base dest
    base="$(basename "$src")"
    dest="$dir/$base"
    [[ "$src" == "$dest" ]] && continue

    if [[ ! -e "$dest" ]]; then
      mv "$src" "$dest"
    else
      local stem="${base%.*}"
      local ext=""
      [[ "$base" == *.* ]] && ext=".${base##*.}"
      local n=1
      while [[ -e "$dir/${stem}_${n}${ext}" ]]; do ((n++)); done
      mv "$src" "$dir/${stem}_${n}${ext}"
    fi
  done < <(find "$dir" -mindepth 2 -type f -print0)

  find "$dir" -type d -empty -delete || true
}

# image/内のsvgをpng化（svgは削除）
svg_to_png_in_dir() {
  local dir="$1"
  local width="$2"
  [[ -d "$dir" ]] || return 0

  find "$dir" -type f -iname "*.svg" -print0 |
  while IFS= read -r -d '' svg; do
    local png="${svg%.*}.png"
    if [[ -e "$png" ]]; then
      local stem="${png%.png}"
      local n=1
      while [[ -e "${stem}_${n}.png" ]]; do ((n++)); done
      png="${stem}_${n}.png"
    fi
    rsvg-convert -a -w "$width" "$svg" -o "$png" || { echo "[warn] svg convert failed: $svg"; continue; }
    rm -f "$svg"
  done
}

# MDを書き換え：
# - images/media/../images/../image/ -> image/
# - image/image/... 事故を潰す
# - SVGラッパーを ![](image/FILE) にする（FILEはbasename抽出）
rewrite_md() {
  local md="$1"
  python3 - "$md" <<'PY'
import re, sys, pathlib

p = pathlib.Path(sys.argv[1])
t = p.read_text(encoding="utf-8", errors="ignore")

# 1) パス統一（../images, images, ../media, media, ../image など）
t = re.sub(r'(?i)(\.\./)+images/', 'image/', t)
t = re.sub(r'(?i)(\.\./)+media/',  'image/', t)
t = re.sub(r'(?i)(\.\./)+image/',  'image/', t)
t = re.sub(r'(?i)\bimages/', 'image/', t)
t = re.sub(r'(?i)\bmedia/',  'image/', t)

# image/image/... 事故を潰す（念のため）
t = re.sub(r'(?i)\bimage/(?:image/)+', 'image/', t)

# 2) SVGラッパーをMarkdown画像へ
# <svg ...> ... <image ... xlink:href=".../00002.jpeg" ...> ... </svg>
svg_pat = re.compile(
    r'<svg\b[^>]*>.*?<image\b[^>]*(?:xlink:href|href)\s*=\s*["\']([^"\']+)["\'][^>]*>.*?</svg>',
    re.IGNORECASE | re.DOTALL
)

def repl(m):
    href = m.group(1).strip()
    fname = href.split('/')[-1]
    return f'![](image/{fname})'

t = svg_pat.sub(repl, t)

# 3) HTML img src も念のため
t = re.sub(r'(?i)src\s*=\s*["\'](\.\./)+images/', 'src="image/', t)
t = re.sub(r'(?i)src\s*=\s*["\'](\.\./)+media/',  'src="image/', t)
t = re.sub(r'(?i)src\s*=\s*["\'](\.\./)+image/',  'src="image/', t)

p.write_text(t, encoding="utf-8")
PY
}

echo "[epub2md] ROOT : $ROOT_ABS"
[[ -n "$OUTDIR_ABS" ]] && echo "[epub2md] OUT  : $OUTDIR_ABS"
echo "[epub2md] IMG  : $IMGDIR (fixed)"
echo "[epub2md] FLAT : ON (fixed)"
echo "[epub2md] SVG2PNG : ON (fixed) width=$SVG_WIDTH"

find "$ROOT_ABS" -type f -iname "*.epub" -print0 |
while IFS= read -r -d '' epub; do
  base="$(basename "$epub")"
  name="${base%.[eE][pP][uU][bB]}"
  safe="$(sanitize "$name")"

  rel="${epub#"$ROOT_ABS"/}"
  rel_dir="$(dirname "$rel")"

  if [[ -n "$OUTDIR_ABS" ]]; then
    book_dir="$OUTDIR_ABS/$rel_dir/$safe"
  else
    book_dir="$(dirname "$epub")/$safe"
  fi

  md="$book_dir/$safe.md"
  imgdir="$book_dir/$IMGDIR"

  if [[ -f "$md" && "$FORCE" != "1" && "$SKIP" == "1" ]]; then
    echo "[skip] $md"
    continue
  fi
  if [[ -f "$md" && "$FORCE" != "1" && "$SKIP" == "0" ]]; then
    echo "[exists] $md (use -s to skip or -f to overwrite)"
    continue
  fi

  mkdir -p "$book_dir" "$imgdir"

  echo "[conv] $epub -> $md"

  # 1) pandoc変換（extract-mediaもimage/）
  ( cd "$book_dir" && pandoc "$epub" -t gfm --wrap=none --extract-media="$IMGDIR" -o "$safe.md" )

  # 2) pandocが拾えない画像も含めてEPUBから強制コピー（今回の本質）
  force_copy_images_from_epub "$epub" "$imgdir"

  # 3) image/配下をフラット化
  if [[ "$FLAT" == "1" ]]; then
    flatten_dir "$imgdir"
  fi

  # 4) svg→png（image/内に集まったsvgをpng化）
  if [[ "$SVG2PNG" == "1" ]]; then
    svg_to_png_in_dir "$imgdir" "$SVG_WIDTH"
  fi

  # 5) md内の参照統一 & svgラッパーを ![] に変換
  rewrite_md "$md"

done

echo "Done."