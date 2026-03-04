#!/bin/csh -f
#User Options
#Bookmark list save directory(Default:/userdata/c9kazama/cmd)
set base_dir = ~/cmd
#"1":Check before "vi"command(Default), "0":Don't ask before "vi"command
set check_option = 1

set bmode = "vi"
#Local variable
set bookmarks_list = $base_dir/bookmarks.list


set MARKER1 = "Bookmarks_$bmode"
set MARKER2 = "${bmode}_"
set BAR = "#======================#"
if ($#argv == 0) then
    echo "Error : Not enough arguments"
    echo "Try 'bvi -h' for more information."
    exit(0)
endif
#command "-h" : usage
if ($#argv == 1 && "$argv[1]" == "-h") then
    cat << EOF
    usage : bvi -l(-la)         -> Show bookmarks
    usage : bvi -v              -> View & edit bookmarks
    usage : bvi -b file_name XX -> Add XX to bookmark
    usage : bvi -d XX           -> Remove XX from bookmarks
    usage : bvi XX              -> vi bookmarks
EOF
    exit(0)
    
else if ($#argv == 1 && ("$argv[1]" == "-la" || "$argv[1]" == "-l" || "$argv[1]" == "-v") ) then
#If "bookmark.list" does not exist, create "bookmark.list".
    if (!(-f $bookmarks_list)) then
        touch $bookmarks_list
        printf "Message :\nCreated -> \033[32m$bookmarks_list\033[m\n"
    endif
    sort $bookmarks_list -o $bookmarks_list ;#sort "bookmark.list"
    sed -i -e "/Bookmarks_/d" -e "/#/d" -e "/\n/d" $bookmarks_list\
    -e '0,/^cd_/ s/^cd_/'$BAR'\n#Bookmarks_cd    \n'$BAR'\ncd_/' $bookmarks_list\
    -e '0,/^vi_/ s/^vi_/'$BAR'\n#Bookmarks_vi    \n'$BAR'\nvi_/' $bookmarks_list\
    -e '0,/^so_/ s/^so_/'$BAR'\n#Bookmarks_source\n'$BAR'\nso_/' $bookmarks_list

#command "-l" : Displayed bookmarks (Directory only)
    if ($#argv == 1 && "$argv[1]" == "-l") then
        grep -1 -e "$MARKER1" $bookmarks_list
        grep    -e "$MARKER2" $bookmarks_list | sed -e "s/$MARKER2//g" -e "s/@/\t-> /g"
#command "-la" : Displayed bookmarks (All)
    else if ($#argv == 1 && "$argv[1]" == "-la") then
        sed -e "s/vi_//g" -e "s/cd_//g" -e "s/so_//g" -e "s/@/\t-> /g" $bookmarks_list
#command "-v" : Edit file bookmarks.list
    else if ($#argv == 1 && "$argv[1]" == "-v") then
        vi $bookmarks_list
    endif
    exit(0)
endif
#command "XX" : vi XX (XX = bookmark name)
if ($#argv == 1) then
    set bookmark_name = `grep -o $MARKER2$argv[1]@ $bookmarks_list`
    set edit_file = `grep $MARKER2$argv[1]@ $bookmarks_list | sed -e "s/$MARKER2$argv[1]@//g"`
    if ("$MARKER2$argv[1]@" != "$bookmark_name") then
        echo "Error : Undifind file -> $argv[1]"
        exit(0)
    else if ($check_option != 0) then
        echo "vi : $edit_file"
        echo "Open the file [Press:y/n/Enter]"
        set answer = $<
        if ($answer ==  "y" || $answer == "") then
            vi $edit_file
        else if ($answer ==  "n") then
            echo "Canceled"
        else
            echo "Don't understand : $answer"
        endif
    else
        echo "vi : $edit_file"
        vi $edit_file
        exit(0)
    endif
#command "-d XX" : Remove the path registered as XX from the bookmarks.
else if ($#argv == 2 && "$argv[1]" == "-d") then
    set bookmark_name = `grep -o $MARKER2$argv[2]@ $bookmarks_list`
    if ("$MARKER2$argv[2]@" != "$bookmark_name") then
        echo "Error : Undifind file -> $argv[2]"
        exit(0)
    else
        set edit_file = `grep $MARKER2$argv[2]@ $bookmarks_list | sed -e "s/$MARKER2$argv[2]@//g"`
        sed -i "/$MARKER2$argv[2]@/d" $bookmarks_list
        echo "Removed from bookmark : $argv[2] -> $edit_file "
        exit(0)
    endif
#command "-b XX" : Add the current path to a bookmarks with the name XX
else if ($#argv == 2 && "$argv[1]" == "-b") then
    echo "Error : Not enough arguments"
    exit(0)
else if ($#argv == 3 && "$argv[1]" == "-b") then

    if (!(-f $argv[2])) then
        echo "Error : Undifind file -> $argv[2]"
        exit(0)
    else
#==============ADD=========#
        if (-f ./$argv[2]) then
            set add_bookmark = `pwd`"/$argv[2]"
        else
            set add_bookmark = "$argv[2]"
        endif
#==============ADD=========#
        sed -i "/$MARKER2$argv[3]@/d" $bookmarks_list
        echo "Added to bookmark : $argv[3] -> $add_bookmark"
        echo "$MARKER2$argv[3]@ $add_bookmark" >> $bookmarks_list
        exit(0)
    endif    
else
    echo "Error : Too many arguments "
    exit(0)
endif
