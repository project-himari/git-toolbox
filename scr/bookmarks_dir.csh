#!/bin/csh -f
#User Options
#Bookmark list save directory(Default:~/cmd)
set base_dir = ~/cmd

#Bookmark_list file name
set bookmarks_list    = $base_dir/bookmarks.list 
set bookmarks_list_bk = $base_dir/bookmarks.list_bk
set cd_history        = $base_dir/cd_history.list
set menu_answer        = $base_dir/answer.tmp
set menu_file          = $base_dir/menu.tmp

#include file
set menu_choice = $base_dir/func_menu.sh
set bmode = "cd"
#set bmode = "vi"
#set bmode = "so"
#Local variable


set MARKER1 = "Bookmarks_$bmode"
set MARKER2 = "${bmode}_"
#=============Function=======================#
alias func_menu_choice   'bash $menu_choice $menu_file $menu_answer'
cat >  $menu_choice  << 'EOF'
#!/bin/bash
function menu_choice {
choice=0
IFS=$'\n'
menu=($(cat "$1"))
tail=`expr ${#menu[@]} - 1`
printf "\e[32mChoose one       [exit:q]\e[m\n"  >&2
for _ in $(seq 0 $tail);do echo ""; done

while true; do
    printf "\e[${#menu[@]}A\e[m" >&2

    for i in $(seq 0 $tail); do
        if [ $choice = $i ]; then
            printf "\e[1;31m>\e[m \e[1;4m" >&2
        else
            printf "  " >&2
        fi
        printf "${menu[$i]}\e[m\n" >&2
    done

    read -sn1 answer
    if [ "$answer" = "^[" ]; then
        read -sn2 answer
    elif [ "$answer" = "q" ]; then
        echo "quit" > $2
        exit 0
    fi
    case $answer in
        "B"|"[B"|"C"|"[B")
        if [ $choice -lt $tail ]; then choice=`expr $choice + 1`; fi
        ;;
        "D"|"[A"|"A"|"[A")
        if [ $choice -gt 0 ]; then choice=`expr $choice - 1`; fi
        ;;
        "")
        echo ${menu[$choice]} > $2
        return
        ;;
    esac
done
}
menu_choice $1 $2

'EOF'

cat << EOF
EOF


#Local variable
set LINE = "#======================#"
if ($#argv == 0) then
    printf "\033[31m[ERROR] : Not enough arguments\033[m\n"
    printf "\033[31mTry 'bcd -h' or 'bcd --help' for more information.\033[m\n"
    exit(0)
endif
#command "-h" : usage
if ($#argv == 1 && ("$argv[1]" == "-h" || "$argv[1]" == "--help" ) ) then 
    cat << EOF
    usage : bcd -l(-la) -> Displayed bookmarks
    usage : bcd -v      -> View & edit bookmarks
    usage : bcd -b XX   -> Add the current path to a bookmarks with the name XX
    usage : bcd -d XX   -> Remove the path registered as XX from the bookmarks
    usage : bcd XX      -> Open XX (XX = bookmark name)
    usage : bcd -log    -> Displaying the latest 100 cd command logs.
    usage : bcd -       -> cd command history is displayed. Please choose a destination from them.
EOF
    exit(0)
    
else if ($#argv == 1 && ("$argv[1]" == "-la" || "$argv[1]" == "-l" || "$argv[1]" == "-v" || "$argv[1]" == "-log") ) then
#If "bookmark.list" does not exist, create "bookmark.list".
    if (!(-f $bookmarks_list)) then
        touch $bookmarks_list
        printf "Message :\nCreated -> \033[32m$bookmarks_list\033[m\n"
    endif
    sort $bookmarks_list -o $bookmarks_list ;#sort "bookmark.list"
    sed -i -e "/Bookmarks_/d" -e "/#/d" -e "/\n/d" $bookmarks_list\
    -e '0,/^cd_/ s/^cd_/'$LINE'\n#Bookmarks_cd    \n'$LINE'\ncd_/' $bookmarks_list\
    -e '0,/^vi_/ s/^vi_/'$LINE'\n#Bookmarks_vi    \n'$LINE'\nvi_/' $bookmarks_list\
    -e '0,/^so_/ s/^so_/'$LINE'\n#Bookmarks_source\n'$LINE'\nso_/' $bookmarks_list

#=======================================================================#
#command "-l" : Displayed bookmarks (Directory only)
#=======================================================================#
    if ($#argv == 1 && "$argv[1]" == "-l") then
        grep -1 -e "$MARKER1"  $bookmarks_list
        grep    -e "^$MARKER2" $bookmarks_list | sed -e "s/$MARKER2//g" -e "s/@/\t-> /g"
#=======================================================================#
#command "-la" : Displayed bookmarks (All)
#=======================================================================#
    else if ($#argv == 1 && "$argv[1]" == "-la") then
        sed -e "s/vi_//g" -e "s/cd_//g" -e "s/so_//g" -e "s/@/\t-> /g" $bookmarks_list
#=======================================================================#
#command "-v" : Edit file bookmarks.list
#=======================================================================#
    else if ($#argv == 1 && "$argv[1]" == "-v") then
        vi $bookmarks_list
#=======================================================================#
#command "-log" : Displaying the latest 100 cd command logs.
#=======================================================================#
    else if ($#argv == 1 && "$argv[1]" == "-log") then
        tac $cd_history_bk
    endif
    exit(0)
endif
#=======================================================================#
#command "-" : cd command history is displayed. Please choose a destination from them.
#=======================================================================#
if ($#argv == 1 && "$argv[1]" == "-" ) then
    if (!(-f $cd_history)) then
        touch $cd_history
        printf "Message:\nCreated -> \033[32m$cd_history\033[m\n"
    endif
    tac $cd_history >  $menu_file
    func_menu_choice
    set enter = `cat $menu_answer | cut -c 18-`
    if ($enter == "")  exit(0)
    cd $enter
    printf "\033[35mPWD\033[m : `pwd`\n"
    rm -f $menu_answer $menu_file >& /dev/null
    exit(0)
#=======================================================================#
#command "XX" : cd XX (XX = bookmark name)
#=======================================================================#
else if ($#argv == 1) then
    set bookmark_name = `grep -o $MARKER2$argv[1]@ $bookmarks_list`
    if ("$MARKER2$argv[1]@" != "$bookmark_name") then
        printf "\033[31m[ERROR] Bookmark not found -> $argv[1]\033[m\n"
        exit(0)
    else
        set enter = `grep "$MARKER2$argv[1]@" $bookmarks_list | sed -e "s/$MARKER2$argv[1]@//g"`
        cd $enter
        printf "\033[35mPWD\033[m : `pwd`\n"
    endif
#=======================================================================#
#command "-b XX" : Add the current path to a bookmarks with the name XX
#=======================================================================#
else if ($#argv == 2 && "$argv[1]" == "-b") then
    set bookmark_name = `grep -o "$MARKER2$argv[2]@" $bookmarks_list`
    sed -i "/$MARKER2$argv[2]@/d" $bookmarks_list
    printf "Added to bookmark : \033[35m$argv[2]\033[m -> \033[32m`pwd`\033[m\n"
    echo "$MARKER2$argv[2]@ `pwd` " >> $bookmarks_list
#=======================================================================#
#command "-d XX" : Remove the path registered as XX from the bookmarks.
#=======================================================================#
else if ($#argv == 2 && "$argv[1]" == "-d") then
    set bookmark_name = `grep -o $MARKER2$argv[2]@ $bookmarks_list`
    if ("$MARKER2$argv[2]@" != "$bookmark_name") then
        printf "\033[31m[ERROR] Bookmark not found -> $argv[2]\033[m\n"
        exit(0)
    else
        set rm_bookmark = `grep "$MARKER2$argv[2]@" $bookmarks_list | sed -e "s/$MARKER2$argv[2]@//g"`
        sed -i "/$MARKER2$argv[2]@/d" $bookmarks_list
        printf "Removed from bookmark: \033[35m$argv[2]\033[m -> \033[32m$rm_bookmark\033[m\n"
    endif
else
    printf "\033[31m[ERROR] Too many arguments\033[m\n"
    exit(0)
endif
