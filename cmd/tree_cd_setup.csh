#!/bin/csh -f
cat << EOF
#=======================# Note #=======================#
# Add the alias to cshrc as follows.
#
# alias cd   'cd \!* ;source ~/cmd/cd_history.csh'
#
#======================================================#
EOF

set install_dir        = ~/cmd
set this_file_name     = tree_cd_setup.csh
set function_file_name = (tree_cd.csh func_menu.sh)
echo "Message :"
set func_num = 1
while ($func_num <= $#function_file_name)
    touch $install_dir/$function_file_name[$func_num]
    cut -c 2- $install_dir/$this_file_name | awk "/#func_START$func_num/,/#func_END$func_num/" | sed -e "1d" | sed -e "/#func_END$func_num/d" > $install_dir/$function_file_name[$func_num]
    printf "Created file -> $install_dir/\033[32m$function_file_name[$func_num]\033[m\n"
    @ func_num ++
end
#=========================# Don't touch #=========================#
##func_START1
##!/bin/csh -f
#set install_dir = ~/cmd
#
##login machine check (whether there is a "tree" command)
#set machine = `hostname`
#if ($machine != ap1x013 && $machine != ap1x014 && $machine != ap1x015) then
#    echo "The tree command can't be found in $machine"
#    echo "Prease login to ap1x013 or ap1x014 or ap1x015"
#    exit(0)
#endif
#
##no argument => path = current directory, display depth level = 1
#if ($#argv == 0) then
#    set argv = ( 1 )
#endif
##command + "-h" => help option
#if ($#argv == 1 && "$argv[1]" == "-h") then
#    cat << EOF
#    usage : '-'              -> cd command history is displayed. Please choose a destination from them.
#    usage : 'Path'           -> The directory tree in the path is displayed. (Display depth level:1)
#    usage : 'Level'          -> Max display depth of the directory tree.
#    usage : 'Path' + 'Level' -> The directory tree in the path is displayed. (Display depth level:N)
#    Example : command cmd(path)  2(level)
#                Choose one       [exit:q]
#                cmd
#                |-- cmd/function
#                |-- cmd/mkcir_relation
#              > |-- cmd/old
#                |   '-- cmd/old/model_make
#                '-- cmd/sankou
#   
#EOF
#    exit(0)
##argument check
##command + "-" => cd history option
#else if ($#argv == 1 && "$argv[1]" == "-" ) then
#    if (!(-f $install_dir/cd_history.list)) then
#        touch $install_dir/cd_history.list
#        echo "Message:\nCreated -> $install_dir/cd_history.list"
#    endif
#    cp $install_dir/cd_history.list $install_dir/menu.tmp
##Function call => func_menu.sh
#    bash $install_dir/func_menu.sh
#    set enter = `cat $install_dir/answer.tmp | cut -c 13-`
#    if ($enter == "") then
#        exit(0)
#    else
#        cd $enter
#        echo "Current directory :" `pwd`
#        rm -f $install_dir/menu.tmp $install_dir/answer.tmp >& /dev/null
#        exit(0)
#    endif
#endif
##command + path or level
#if ($#argv == 1) then
##Number or character determination
#    set str_check = `expr $argv[1] + 1 >& /dev/null ; echo $status`
#    if ($str_check == 0) then
#        set PASS = '.'
#        set hi = "$argv[1]"
#    else if (-d $argv[1]) then
#        set PASS = `echo $argv[1] | sed 's:/$::g'`
#        set hi = 1
#    else
#        echo "ERROR : Please enter a valid path."
#        exit(0)
#    endif
##command + path + level
#else if ($#argv == 2 &&  (-d $argv[1]) ) then
##Number or character determination
#    set str_check = `expr $argv[2] + 1 >& /dev/null ; echo $status`
#    if ($str_check > 1) then
#        echo "ERROR : "$argv[2]" is not a number"
#        exit(0)
#    else
#        set PASS = `echo $argv[1] | sed 's:/$::g'`
#        set hi = $argv[2]
#    endif
#else
#    echo "ERROR : Please enter a valid path."
#    exit(0)
#endif
#
##tree command to cd command 
#tree $PASS -L $hi -d -f | sed -e '/director/d' -e '/^$/d' > $install_dir/menu.tmp
##Function call => func_menu.sh
#bash $install_dir/func_menu.sh
#set enter = `cat $install_dir/answer.tmp`
#if ("$enter" == "quit") then
#    exit(0)
#else if ("$enter" == "$PASS") then
#    cd $enter ; echo "Current Directory : `pwd`"
#else
#    set enter = `cat $install_dir/answer.tmp | sed -e 's/ //g' -e 's/--/@@/g' -e 's/|//g' | cut -c 3- | sed -e 's/|//g'  -e 's/@//g'`
#    cd $enter ; echo "Current Directory : `pwd`"
#endif
#
#rm -f $install_dir/menu.tmp $install_dir/answer.tmp >& /dev/null
##func_END1

##func_START2
##!/bin/bash
#function menu {
#choice=0
#IFS=$'\n'
#menu=($(cat ~/cmd/menu.tmp))
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
#        echo "quit" > ~/cmd/answer.tmp
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
#        echo ${menu[$choice]} > ~/cmd/answer.tmp
#        return
#        ;;
#    esac
#done
#}
#
#menu
##func_END2

#=========================# Don't touch #=========================#
