#!/bin/csh -f
#Created by kazama
cat << EOF
#=======================# Note #=======================#
# Add the alias to cshrc as follows.
#
# alias cd   'cd \!* ;source ~/cmd/cd_history.csh'
# alias bcd  'source ~/cmd/bookmarks_dir.csh'
# alias bvi  'source ~/cmd/bookmarks_file.csh'
# alias bso  'source ~/cmd/bookmarks_source.csh'
#
#======================================================#
EOF

set install_dir        = ~/cmd
set this_file_name     = bookmarks_setup.csh
set function_file_name = (bookmarks_dir.csh bookmarks_file.csh bookmarks_source.csh cd_history.csh func_menu.sh)
set sub_func = $install_dir/func_menu.sh

echo "The following files are concatenated"
set func_num = 1

while ($func_num <= $#function_file_name)
    printf "No.$func_num : \033[32m$function_file_name[$func_num]\033[m\n"
    @ func_num ++
end
echo "Do you want to unzip in this directory?[y/n]"
set answer = $<
switch ("$answer")
    case "y*" :
    breaksw

    case "n*" :
        echo "Canceled"
        exit(0)
    breaksw

    default :
        echo "Don't understand : $answer"
        exit(0)
    breaksw
endsw
echo "Message :"
set func_num = 1
while ($func_num <= $#function_file_name)
    touch $install_dir/$function_file_name[$func_num]
    chmod 777 $install_dir/$function_file_name[$func_num]
    cut -c 2- $install_dir/$this_file_name | awk "/#func_START$func_num/,/#func_END$func_num/" | sed -e "1d" | sed -e "/#func_END$func_num/d" > $install_dir/$function_file_name[$func_num]
    sed -i s:TIKAN_DIR:"$install_dir":g  $install_dir/$function_file_name[$func_num]
    printf "Created file -> $install_dir/\033[32m$function_file_name[$func_num]\033[m\n"
    @ func_num ++
end

#=========================# Don't touch #=========================#
##func_START1
##!/bin/csh -f
##User Options
##Bookmark list save directory(Default:TIKAN_DIR)
#set install_dir = TIKAN_DIR
#
##include file
#set function_file_name = $install_dir/func_menu.sh
#
##Local variable
#set env1 = _Dir
#set env2 = dir_
#
##if ($#argv == 0 ) then
#if ($#argv == 0) then
#    printf "\033[31mError : Not enough arguments\033[m\n"
#    printf "\033[31mTry 'bcd -h' for more information.\033[m\n"
#    exit(0)
#endif
##command "-h" : usage
#if ($#argv == 1 && "$argv[1]" == "-h") then
#    cat << EOF
#    usage : bcd -l(-la) -> Displayed bookmarks
#    usage : bcd -v      -> View & edit bookmarks
#    usage : bcd -b XX   -> Add the current path to a bookmarks with the name XX
#    usage : bcd -d XX   -> Remove the path registered as XX from the bookmarks
#    usage : bcd XX      -> Open XX (XX = bookmark name)
#    usage : bcd -       -> cd command history is displayed. Please choose a destination from them.
#EOF
#    exit(0)
#    
#else if ($#argv == 1 && "$argv[1]" == "-la" || $#argv == 1 && "$argv[1]" == "-l" || $#argv == 1 && "$argv[1]" == "-v") then
##If "bookmark.list" does not exist, create "bookmark.list".
#    if (!(-f $install_dir/bookmarks.list)) then
#        touch $install_dir/bookmarks.list
#        printf "Message :\nCreated -> \033[32m$install_dir/bookmarks.list\033[m\n"
#    endif
##sort "bookmark.list"
#    set LINE = "#======================#"
#    sort $install_dir/bookmarks.list -o $install_dir/bookmarks.list
#    sed -i -e "/Bookmarks_/d" -e "/#/d" -e "/\n/d" $install_dir/bookmarks.list\
#    -e '0,/dir_/ s/dir_/'$LINE'\n#Bookmarks_Directory\n'$LINE'\ndir_/' $install_dir/bookmarks.list\
#    -e '0,/file_/ s/file_/'$LINE'\n#Bookmarks_File\n'$LINE'\nfile_/' $install_dir/bookmarks.list\
#    -e '0,/source_/ s/source_/'$LINE'\n#Bookmarks_Source File\n'$LINE'\nsource_/' $install_dir/bookmarks.list
##command "-l" : Displayed bookmarks (Directory only)
#    if ($#argv == 1 && "$argv[1]" == "-l") then
#        cat $install_dir/bookmarks.list | grep -1 -e "$env1"
#        cat $install_dir/bookmarks.list | grep -e "$env2" | sed -e "s/file_//g" -e "s/dir_//g" -e "s/source_//g" -e "s/@/\t-> /g"
##command "-la" : Displayed bookmarks (All)
#    else if ($#argv == 1 && "$argv[1]" == "-la") then
#        cat $install_dir/bookmarks.list | sed -e "s/file_//g" -e "s/dir_//g" -e "s/source_//g" -e "s/@/\t-> /g"
##command "-v" : View & edit bookmarks
#    else if ($#argv == 1 && "$argv[1]" == "-v") then
#        vi $install_dir/bookmarks.list
#    endif
#    exit(0)
#endif
##command "-" : cd command history is displayed. Please choose a destination from them.
#if ($#argv == 1 && "$argv[1]" == "-" ) then
#    if (!(-f $install_dir/cd_history.list)) then
#        touch $install_dir/cd_history.list
#        printf "Message:\nCreated -> \033[32m$install_dir/cd_history.list\033[m\n"
#    endif
#   #cp $install_dir/cd_history.list $install_dir/menu.tmp
#    tac $install_dir/cd_history.list >  $install_dir/menu.tmp
#    bash $function_file_name
#    set enter = `cat $install_dir/answer.tmp | cut -c 18-`
#    if ($enter == "") then
#        exit(0)
#    endif
#    cd $enter
#    printf "\033[35mPWD\033[m : `pwd`\n"
#    rm -f $install_dir/answer.tmp $install_dir/menu.tmp >& /dev/null
#    exit(0)
##command "XX" : cd XX (XX = bookmark name)
#else if ($#argv == 1) then
#    set bookmark_name = `grep -o $env2$argv[1]@ $install_dir/bookmarks.list`
#    if ("$env2$argv[1]@" != "$bookmark_name") then
#        printf "\033[31mError : Undifind bookmark -> $argv[1]\033[m\n"
##Add : Fuzzy search
#        printf "\033[32mFussy search...\033[m\n"
#        set cnti = 1
#        set cntN = `echo $argv[1] | wc -c`
#        set in_chr = `echo $argv[1] | awk -v FS='' '{ for (i = 1; i <= NF; i++) print $i; }'`
##set list = `grep dir_ $install_dir/bookmarks.list | cut -d " " -f 1`
#        grep dir_ $install_dir/bookmarks.list | sed -e "s/file_//g" -e "s/dir_//g" -e "s/source_//g" -e "s/@//g" | cut -d " " -f 1 > $install_dir/bookmarks.tmp
#        printf "" >  $install_dir/bookmarks.tmptmp
#        printf "" >  $install_dir/bookmarks.tmptmptmp
#        while ($cnti < $cntN)
#            grep -e "$in_chr[$cnti]" $install_dir/bookmarks.tmp >> $install_dir/bookmarks.tmptmp
#            @ cnti ++
#        end
#        cat $install_dir/bookmarks.tmptmp | sort |  uniq -d >  $install_dir/bookmarks.tmptmp1
##second while
#        set cnti = 1
#        set cntN = `cat $install_dir/bookmarks.tmptmp1 | wc -l`
#        set in_chr =  `cat $install_dir/bookmarks.tmptmp1`
#        while ($cnti <= $cntN)
#            grep  "dir_$in_chr[$cnti]" $install_dir/bookmarks.list >> $install_dir/bookmarks.tmptmptmp
#            @ cnti ++
#        end
#        cat $install_dir/bookmarks.tmptmptmp | sort | uniq -c | cut -c 9- | sed -e "s/file_//g" -e "s/dir_//g" -e "s/source_//g" -e "s/@/\t-> /g"
#        rm -f $install_dir/bookmarks.tmp*  >& /dev/null
#        exit(0)
#    else
#        set enter = `cat $install_dir/bookmarks.list | grep $env2$argv[1]@ | sed -e "s/$env2$argv[1]@//g"`
#        cd $enter
#        printf "\033[35mPWD\033[m : `pwd`\n"
#    endif
##command "-b XX" : Add the current path to a bookmarks with the name XX
#else if ($#argv == 2 && "$argv[1]" == "-b") then
#    set bookmark_name = `grep -o $env2$argv[2]@ $install_dir/bookmarks.list`
#    sed -i "/$env2$argv[2]@/d" $install_dir/bookmarks.list
#    set add_bookmark = `pwd`
#    printf "Added to bookmark : \033[35m$argv[2]\033[m -> \033[32m$add_bookmark\033[m\n"
#    echo "$env2$argv[2]@ $add_bookmark" >> $install_dir/bookmarks.list
##command "-d XX" : Remove the path registered as XX from the bookmarks.
#else if ($#argv == 2 && "$argv[1]" == "-d") then
#    set bookmark_name = `grep -o $env2$argv[2]@ $install_dir/bookmarks.list`
#    if ("$env2$argv[2]@" != "$bookmark_name") then
#        printf "\033[31mError : Undifind directory -> $argv[2]\033[m\n"
#        exit(0)
#    else
#        set rm_bookmark = `cat $install_dir/bookmarks.list | grep $env2$argv[2]@ | sed -e "s/$env2$argv[2]@//g"`
#        sed -i "/$env2$argv[2]@/d" $install_dir/bookmarks.list
#        printf "Removed from bookmark: \033[35m$argv[2]\033[m -> \033[32m$rm_bookmark\033[m\n"
#    endif
#else
#    printf "\033[31mError : Too many arguments\033[m\n"
#    exit(0)
#endif
##func_END1

##func_START2
##!/bin/csh -f
##User Options
##Bookmark list save directory(Default:TIKAN_DIR)
#set install_dir = TIKAN_DIR
##"1":Check before "vi"command(Default), "0":Don't ask before "vi"command
#set check_option = 1
#
##Local variable
#set env1 = _File
#set env2 = file_
#
#if ($#argv == 0) then
#    echo "Error : Not enough arguments"
#    echo "Try 'bvi -h' for more information."
#    exit(0)
#endif
##command "-h" : usage
#if ($#argv == 1 && "$argv[1]" == "-h") then
#    cat << EOF
#    usage : bvi -l(-la)         -> Show bookmarks
#    usage : bvi -v              -> View & edit bookmarks
#    usage : bvi -b file_name XX -> Add XX to bookmark
#    usage : bvi -d XX           -> Remove XX from bookmarks
#    usage : bvi XX              -> vi bookmarks
#EOF
#    exit(0)
#    
#else if ($#argv == 1 && "$argv[1]" == "-la" || $#argv == 1 && "$argv[1]" == "-l" || $#argv == 1 && "$argv[1]" == "-v") then
##If "bookmark.list" does not exist, create "bookmark.list".
#    if (!(-f $install_dir/bookmarks.list)) then
#        touch $install_dir/bookmarks.list
#        echo "Message :\nCreated -> $install_dir/bookmarks.list"
#    endif
##sort "bookmark.list"
#    set LINE = "#======================#"
#    sort $install_dir/bookmarks.list -o $install_dir/bookmarks.list
#    sed -i -e "/Bookmarks_/d" -e "/#/d" -e "/\n/d" $install_dir/bookmarks.list\
#           -e '0,/dir_/ s/dir_/'$LINE'\n#Bookmarks_Directory\n'$LINE'\ndir_/' $install_dir/bookmarks.list\
#           -e '0,/file_/ s/file_/'$LINE'\n#Bookmarks_File\n'$LINE'\nfile_/' $install_dir/bookmarks.list\
#           -e '0,/source_/ s/source_/'$LINE'\n#Bookmarks_Source File\n'$LINE'\nsource_/' $install_dir/bookmarks.list
##command "-l" : Displayed bookmarks (Directory only)
#    if ($#argv == 1 && "$argv[1]" == "-l") then
#        cat $install_dir/bookmarks.list | grep -1 -e "$env1"
#        cat $install_dir/bookmarks.list | grep -e "$env2" | sed -e "s/file_//g" -e "s/dir_//g" -e "s/source_//g" -e "s/@/\t-> /g"
##command "-la" : Displayed bookmarks (All)
#    else if ($#argv == 1 && "$argv[1]" == "-la") then
#        cat $install_dir/bookmarks.list | sed -e "s/file_//g" -e "s/dir_//g" -e "s/source_//g" -e "s/@/\t-> /g"
##command "-v" : View & edit bookmarks
#    else if ($#argv == 1 && "$argv[1]" == "-v") then
#        vi $install_dir/bookmarks.list
#    endif
#    exit(0)
#endif
##command "XX" : vi XX (XX = bookmark name)
#if ($#argv == 1) then
#    set bookmark_name = `grep -o $env2$argv[1]@ $install_dir/bookmarks.list`
#    set edit_file = `cat $install_dir/bookmarks.list | grep $env2$argv[1]@ | sed -e "s/$env2$argv[1]@//g"`
#    if ("$env2$argv[1]@" != "$bookmark_name") then
#        echo "Error : Undifind file -> $argv[1]"
#        exit(0)
#    else if ($check_option != 0) then
#        echo "vi : $edit_file"
#        echo "Open the file [Press:y/n/Enter]"
#        set answer = $<
#        if ($answer ==  "y" || $answer == "") then
#            vi $edit_file
#        else if ($answer ==  "n") then
#            echo "Canceled"
#        else
#            echo "Don't understand : $answer"
#        endif
#    else
#        echo "vi : $edit_file"
#        vi $edit_file
#        exit(0)
#    endif
##command "-d XX" : Remove the path registered as XX from the bookmarks.
#else if ($#argv == 2 && "$argv[1]" == "-d") then
#    set bookmark_name = `grep -o $env2$argv[2]@ $install_dir/bookmarks.list`
#    if ("$env2$argv[2]@" != "$bookmark_name") then
#        echo "Error : Undifind file -> $argv[2]"
#        exit(0)
#    else
#        set edit_file = `cat $install_dir/bookmarks.list | grep $env2$argv[2]@ | sed -e "s/$env2$argv[2]@//g"`
#        sed -i "/$env2$argv[2]@/d" $install_dir/bookmarks.list
#        echo "Removed from bookmark : $argv[2] -> $edit_file "
#        exit(0)
#    endif
##command "-b XX" : Add the current path to a bookmarks with the name XX
#else if ($#argv == 2 && "$argv[1]" == "-b") then
#    echo "Error : Not enough arguments"
#    exit(0)
#else if ($#argv == 3 && "$argv[1]" == "-b") then
#    if (!(-f $argv[2])) then
#        echo "Error : Undifind file -> $argv[2]"
#        exit(0)
#    else
#        sed -i "/$env2$argv[3]@/d" $install_dir/bookmarks.list
#        set add_bookmark = `pwd`"/$argv[2]"
#        echo "Added to bookmark : $argv[3] -> $add_bookmark"
#        echo "$env2$argv[3]@ $add_bookmark" >> $install_dir/bookmarks.list
#        exit(0)
#    endif    
#else
#    echo "Error : Too many arguments"
#    exit(0)
#endif
##func_END2

##func_START3
##!/bin/csh -f
##User Options
##Bookmark list save directory(Default:/cmd)
#set install_dir = TIKAN_DIR
##"1":Check before "source"command(Default), "0":Don't ask before "source"command
#set check_option = 1
#
##Local variable
#set env1 = _Source
#set env2 = source_
#set hikisu = "$argv[2-$#argv]"
#
#if ($#argv == 0) then
#    echo "Error : Not enough arguments"
#    echo "Try 'bso -h' for more information."
#    exit(0)
#endif
#
#if ($#argv == 1 && "$argv[1]" == "-h") then
#    cat << EOF
#    usage : bso -l(-la)         -> Show bookmarks.
#    usage : bso -v              -> View & edit bookmarks
#    usage : bso -s file_name XX -> Add XX to bookmark
#    usage : bso -d XX           -> Remove XX from bookmarks
#    usage : bso XX              -> Source bookmarks
#EOF
#    exit(0)
#    
#else if ($#argv == 1 && "$argv[1]" == "-la" || $#argv == 1 && "$argv[1]" == "-l" || $#argv == 1 && "$argv[1]" == "-v") then
##If "bookmark.list" does not exist, create "bookmark.list".
#    if (!(-f $install_dir/bookmarks.list)) then
#        touch $install_dir/bookmarks.list
#        echo "Message :\nCreated -> $install_dir/bookmarks.list"
#    endif
##sort "bookmark.list"
#    set LINE = "#======================#"
#    sort $install_dir/bookmarks.list -o $install_dir/bookmarks.list
#    sed -i -e "/Bookmarks_/d" -e "/#/d" -e "/\n/d" $install_dir/bookmarks.list\
#    -e '0,/dir_/ s/dir_/'$LINE'\n#Bookmarks_Directory\n'$LINE'\ndir_/' $install_dir/bookmarks.list\
#    -e '0,/file_/ s/file_/'$LINE'\n#Bookmarks_File\n'$LINE'\nfile_/' $install_dir/bookmarks.list\
#    -e '0,/source_/ s/source_/'$LINE'\n#Bookmarks_Source File\n'$LINE'\nsource_/' $install_dir/bookmarks.list
##command "-l" : Displayed bookmarks (Directory only)
#    if ($#argv == 1 && "$argv[1]" == "-l") then
#        cat $install_dir/bookmarks.list | grep -1 -e "$env1"
#        cat $install_dir/bookmarks.list | grep -e "$env2" | sed -e "s/file_//g" -e "s/dir_//g" -e "s/source_//g" -e "s/@/\t-> /g"
##command "-la" : Displayed bookmarks (All)
#    else if ($#argv == 1 && "$argv[1]" == "-la") then
#        cat $install_dir/bookmarks.list | sed -e "s/file_//g" -e "s/dir_//g" -e "s/source_//g" -e "s/@/\t-> /g"
##command "-v" : View & edit bookmarks
#    else if ($#argv == 1 && "$argv[1]" == "-v") then
#        vi $install_dir/bookmarks.list
#    endif
#    exit(0)
#endif
##command "-d XX" : Remove the path registered as XX from the bookmarks.
#if ($#argv == 2 && "$argv[1]" == "-d") then
#    set bookmark_name = `grep -o $env2$argv[2]@ $install_dir/bookmarks.list`
#    if ("$env2$argv[2]@" != "$bookmark_name") then
#        echo "Error : Undifind file -> $argv[2]"
#        exit(0)
#    else
#        set file = `cat $install_dir/bookmarks.list | grep $env2$argv[2]@ | sed -e "s/$env2$argv[2]@//g"`
#        sed -i "/$env2$argv[2]@/d" $install_dir/bookmarks.list
#        echo "Removed from bookmark : $argv[2] -> $file "
#        exit(0)
#    endif
##command "-b XX" : Add the current path to a bookmarks with the name XX
#else if ($#argv == 2 && "$argv[1]" == "-b") then
#    echo "Error : Not enough arguments"
#    exit(0)
#else if ($#argv == 3 && "$argv[1]" == "-b") then
#    if (!(-f $argv[2])) then
#        echo "Error : Undifind file -> $argv[2]"
#        exit(0)
#    else
#        sed -i "/$env2$argv[3]@/d" $install_dir/bookmarks.list
#        set add_bookmark = `pwd`"/$argv[2]"
#        echo "Added to bookmark : $argv[3] -> $add_bookmark"
#        echo "$env2$argv[3]@ $add_bookmark" >> $install_dir/bookmarks.list
#        exit (0)
#    endif
#endif
#
#set source_file = `cat $install_dir/bookmarks.list | grep $env2$argv[1]@ | sed -e "s/$env2$argv[1]@//g"`
#set search_file = `grep -o $env2$argv[1]@ $install_dir/bookmarks.list`
#if ("$env2$argv[1]@" != "$search_file") then
#    echo "Error : Undifind file -> $argv[1]"
#    exit(0)
#else if ($check_option != 0) then
#    echo "Source : $source_file"
#    echo "Source the file [Press:y/n/Enter]"
#    set answer = $<
#    if ($answer == "y" || $answer == "") then
#        shift
#        echo "It was sourced -> $source_file"
#        source $source_file $hikisu
#    else if ($answer == "n") then
#        echo "Canceled"
#    else
#        echo "Don't understand : $answer"
#    endif
#else
#    echo "source : $source_file"
#    echo "It was sourced -> $source_file"
#    shift
#    source $source_file $hikisu
#endif
##func_END3

##func_START4
##!/bin/csh -f
##cd command log save directory (Default:TIKAN_DIR)
#set install_dir = TIKAN_DIR
##max_log(default:10)
#set max_log = 15
#
#if ( !(-f $install_dir/cd_history.list) ) then
#    touch $install_dir/cd_history.list
#    echo "Message :\nCreated -> $install_dir/cd_history.list"
#endif
#
##Time stamp & cd history
#echo `date "+%Y %m/%d %H:%M"`" "`pwd`  >> $install_dir/cd_history.list
##If there is the same history, those histories are stacked.
#sort -r -k 4,4 -t " " $install_dir/cd_history.list | uniq -f 3 -c | cut -c 9- | sort -n -o $install_dir/cd_history.list
#set count_log = `wc -l $install_dir/cd_history.list | sed -e s:$install_dir/cd_history.list::g`
##If the number of "log_count" is greater than "max_log", delete "log_count" until "log_count" = "max_log"
#if ($count_log > $max_log) then
#    setenv LOOP 1
#    while ($LOOP > 0)
#        set count_log = `wc -l $install_dir/cd_history.list | sed -e s:$install_dir/cd_history.list::g`
#        if ($count_log == $max_log) then
#            break
#        else
#            sed -i -e "1d" $install_dir/cd_history.list
#        endif
#    end
#endif
##func_END4

##func_START5
##func_START
##!/bin/bash
#function menu {
#choice=0
#IFS=$'\n'
#menu=($(cat TIKAN_DIR/menu.tmp))
#tail=`expr ${#menu[@]} - 1`
#printf "\e[32mChoose one       [exit:q]\e[m\n"  >&2
#for _ in $(seq 0 $tail);do echo ""; done
#
#while true; do
#    printf "\e[${#menu[@]}A\e[m" >&2
#
#    for i in $(seq 0 $tail); do
#        if [ $choice = $i ]; then
#            printf "\e[1;31m>\e[m \e[1;4m" >&2
#        else
#            printf "  " >&2
#        fi
#        printf "${menu[$i]}\e[m\n" >&2
#    done
#
#    read -sn1 answer
#    if [ "$answer" = "^[" ]; then
#        read -sn2 answer
#    elif [ "$answer" = "q" ]; then
#        echo "quit" > TIKAN_DIR/answer.tmp
#        exit 0
#    fi
#    case $answer in
#        "B"|"[B")
#        if [ $choice -lt $tail ]; then choice=`expr $choice + 1`; fi
#        ;;
#        "C"|"[B")
#        if [ $choice -lt $tail ]; then choice=`expr $choice + 1`; fi
#        ;;
#        "D"|"[A")
#        if [ $choice -gt 0 ]; then choice=`expr $choice - 1`; fi
#        ;;
#        "A"|"[A")
#        if [ $choice -gt 0 ]; then choice=`expr $choice - 1`; fi
#        ;;
#        "")
#        echo ${menu[$choice]} > TIKAN_DIR/answer.tmp
#        return
#        ;;
#    esac
#done
#}
#
#menu
##func_END5

#=========================# Don't touch #=========================#
