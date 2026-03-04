#!/bin/csh
echo "Current directory : `pwd`"
echo "Do you want to delete these files?[y/n]"
set list = `find ./ -name 'psf*' | wc -m`
find ./ -name 'psf*'
if ($list == "0" ) then
    echo "Message : psf was not found. Check the directory path."
    exit(0)
endif
set answer = $<
if ($answer ==  "y") then
    find ./ -name 'psf*' | xargs rm -rf
    echo "Message : The files has been deleted."
    exit(0)
else if ($answer ==  "n") then
    echo "Canceled"
else
    echo "Don't understand : $answer"
endif
