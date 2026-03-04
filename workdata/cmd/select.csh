#!/bin/csh

if ( $#argv != 1 ) then
  echo "Error"
  exit 1
endif

set input = $argv[1]


if ( "$input" !~ '^[0-9]+$' ) then
  echo "Input is Number"
else
  echo "Input isn't Number"
endif
