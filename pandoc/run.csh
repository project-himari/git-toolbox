#!/bin/csh -f
set EPUB =  EPUB
set AFTER_EPUB =  epub_fetch_data
mkdir $AFTER_EPUB MD
mv */*/*/*.epub $AFTER_EPUB
bash ./epub2md.sh -d $AFTER_EPUB  -o MD 
