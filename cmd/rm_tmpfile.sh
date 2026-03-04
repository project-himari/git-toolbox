#!/bin/bash
#==============================================================================================#
# Search for files named 'identifier' recursively from the current directory.
# These files are often unintentionally created when transferring files from Windows to WSL.
# Removing them prevents clutter in the repository and avoids committing irrelevant files.
#==============================================================================================#
find ./ -name '*.Identifier' | xargs rm -rf
