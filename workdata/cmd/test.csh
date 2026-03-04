#!/bin/csh -f
set STATUS = $argv[1]
if ( "$STATUS" == "TEIJI" ) then
    echo "今日よかったら家系ラーメン食べに行きませんか?"
else if ("$STATUS" == "ZANGYO" ) then
    echo "また今度家系ラーメンを食べに行きましょう"
endif

