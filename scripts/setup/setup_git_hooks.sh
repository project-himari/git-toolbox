#!/bin/sh -f


PROJECT_ROOT="$(git rev-parse --show-toplevel)"


cp $PROJECT_ROOT/scripts/git_files_backup/hooks/*  $PROJECT_ROOT/.git/hooks/
chmod +x ../.git/hooks/*

