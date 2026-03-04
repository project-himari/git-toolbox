#!/bin/tcsh
if (`git rev-parse --is-inside-work-tree 2> /dev/null` == "true") then
    echo "OK"
else
    echo "NG"
endif
