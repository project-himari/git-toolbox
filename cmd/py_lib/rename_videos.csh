#!/bin/csh -h

set dir = "$argv[1]"

rename -e "s/ /_/g"  $dir/*
rename -e "s/-/_/g"  $dir/*
rename -e "s/Microsoft//g"  $dir/*
rename -e "s/Edge//g"  $dir/*
rename -e "s/__/_/g"  $dir/*

