#!/bin/tcsh -f
pandoc $argv[1] \
  -t gfm \
  --wrap=none \
  --extract-media=. \
  -o book.md
