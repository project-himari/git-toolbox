#!/bin/csh -f
#gid_change.csh  ver.8 (last update 2023/12/04 created by kazama)

#======#READ ME#=====#
#ホームディレクリ内のcshrcに下記の2行を追加してください(#は外してください)
#alias gid 'source TIKAN_DIR/gid_change.csh'
#source TIKAN_DIR/gid_change.csh -b

#sinkankyou you desu
#gid_change.cshは下記2つのファイルで構成されています。
#1:gid_change.csh         => メインスクリプト
#2:gid_gid_func_menu.sh   => カーソル選択用の補助スクリプト(自動で生成されます)
#====================#

if ( $HOSTNAME =~ ap1x10*) then
    set workdata = "/workdata/OEM"
else 
    set workdata = "/workdata"
endif

set gid_dir = /workdata/XCSR/others/gid_change
set this_file_name  = gid_change.csh
set subfile_name    = gid_func_menu.sh
set gid_func        = "$gid_dir/$subfile_name"
set menu            = "$gid_dir/tmp/gid_menu.tmp_$user"
set answer          = "$gid_dir/tmp/gid_answer.tmp_$user"
set re_flag         = "$gid_dir/tmp/gid_newgrp_flag.tmp_$user"
touch $menu $answer
chmod 777 $menu	$answer 
#subfile create code
if (!(-f $gid_dir/$subfile_name))then
    printf "Message :\nCreated file -> $gid_dir/\033[32m$subfile_name\033[m\n"
    touch $gid_dir/$subfile_name
    cut -c 2- $gid_dir/$this_file_name | awk "/#func_START/,/#func_END/" | sed -e "1d" | sed -e "/#func_END/d" > $gid_dir/$subfile_name
    sed -i s:TIKAN_DIR:"$gid_dir":g $subfile_name
    chmod 777 $gid_dir/$subfile_name
endif
#=========================# Don't touch #=========================#
##func_START
##!/bin/bash
#function menu {
#choice=0
#IFS=$'\n'
#menu=($(cat TIKAN_DIR/tmp/gid_menu.tmp_$USER))
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
#        echo "quit" > TIKAN_DIR/tmp/gid_answer.tmp_$USER
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
#        echo ${menu[$choice]} > TIKAN_DIR/tmp/gid_answer.tmp_$USER
#        return
#        ;;
#    esac
#done
#}
#
#menu
##func_END
#=========================# Don't touch #=========================#

#Main code
if ($#argv == 0) then
 echo $#argv
    id | sed -e "s/)/)\n/g" -e "s/id=/id:/g" -e "s/=/\n/g" -e "s/,//g" | sed -e 's/^[ \t]*//g' | grep -v -e "id" -e "groups" -e '^$' | sed -e '1,1d' | sort -r > $menu
    bash $gid_func
    set enter_gid = `awk '{print substr($0, index($0, "("), index($0, ")") -1 )}' $answer | sed -e "s/(//g" -e "s/)//g"`
    if ("$enter_gid" == "") then
        rm -f $gid_dir/tmp/*_$user  >& /dev/null
        exit(0)
    else 
        echo "" > $re_flag
        printf "gid changed : \033[35m$enter_gid\033[m\n"
        newgrp $enter_gid
        exit(0)
    endif
endif

#newgrp after new cshrc
set mode = 0
if ($#argv == 1) then
    if(-f $re_flag && "$argv[1]" == "-b" ) then
        set mode = 1
    else if ("$argv[1]" == "-n" ) then
        set mode = 2
    endif
endif
     
if($mode == 1) then
    rm -f $re_flag >& /dev/null
    set enter_gid = `awk '{print substr($0, index($0, "("), index($0, ")") -1 )}' $answer | sed -e "s/(//g" -e "s/)//g"`
    set ent_dir = `ls -lag --time-style="+" $workdata/ | grep -v -e "root" -e "users" | sed -e "s/  */ /g" | grep -e "$enter_gid" | cut -d " " -f 5 `
    set sel_dir = `ls -lag --time-style="+" $workdata/ | grep -v -e "root" -e "users" | sed -e "s/  */ /g" | grep -e "$enter_gid" | cut -d " " -f 5  | wc -l`

    if ($sel_dir == 0) then
        echo "ERROR:あなたの権限で入れる製品ディレクトリが見つかりませんでした。"
        exit(0)
    else if ($sel_dir == 1) then
        cd $workdata/$ent_dir
        pwd
    else if ($sel_dir > 1) then
        echo "同じgidを持つ製品ディレクトリが2つ以上見つかりました。どちらのディレクトリにはいりますか?"
        ls -lag --time-style="+" $workdata/ | sed -e "s/  */ /g" | grep -e "$enter_gid" | cut -d " " -f 5     > $menu
        chmod 777 $menu

        bash $gid_func
        set enter = `cat $answer`
        if ($enter == "quit") then
            rm -f $gid_dir/tmp/*_$user  >& /dev/null
            exit(0)
        endif
        cd $workdata/$enter
    endif
    
    tree -dfiL 3 | sed -e '/director/d' -e '/^$/d'|grep -e "composer"  > $menu
    chmod 777 $menu
    set composer_count = `cat $menu | wc -l`
    if ($composer_count == 0) then
        echo "Warning:composerディレクトリが見つかりませんでした。"
#graphical cd loop
        set LOOP =  1
        while  ($LOOP > 0)
            echo "どちらのディレクトリに入りますか?" 
            tree -dfiL 1 | sed -e '/director/d' -e '/^$/d' -e 's:^.$:../:g'> $menu
            bash $gid_func ; set enter = `cat $answer`
            if ($enter == "quit") then
                rm -f $gid_dir/tmp/*_$user >& /dev/null
                set LOOP = 0
                exit(1)
            endif
            set composer = `cat $answer`
            echo $composer
            cd $composer ; printf "\033[35mPWD\033[m : `pwd`\n"
            rm -f $gid_dir/tmp/*_$user >& /dev/null
        end
        exit(0)
        rm -f $gid_dir/tmp/*_$user >& /dev/null

    else if ($composer_count == 1) then
        cd `tree -dfiL 3 | sed -e '/director/d' -e '/^$/d'| grep -e "composer" `
        printf "\033[35mPWD\033[m : `pwd`\n"
        set csh_flag = 1
    else if ($composer_count > 1) then
        echo "composerが2つ以上見つかりました。どちらのcomposerに入りますか?"
        bash $gid_func
        set enter = `cat $answer`
        if ($enter == "quit") then
            rm -f $gid_dir/tmp/*_$user >& /dev/null
            exit(0)
        endif
        set composer = `cat $answer`
        cd $composer ; printf "\033[35mPWD\033[m : `pwd`\n"
        set csh_flag = 1
    endif
    if ($csh_flag == 1) then   
        find -maxdepth 1 -name '*cshrc*' > $menu
        echo "読み込むcshrcを選択してください。"
        bash $gid_func
        set enter = `cat $answer`
        if ($enter == "quit") then
            rm -f $gid_dir/tmp/*_$user >& /dev/null
            exit(0)
        else
            source $enter
            rm -f $gid_dir/tmp/*_$user >& /dev/null
        endif
    endif
    exit(0)
endif

if ($mode == 2) then
    id | sed -e "s/)/)\n/g" -e "s/id=/id:/g" -e "s/=/\n/g" -e "s/,//g" | sed -e 's/^[ \t]*//g' | grep -v -e "id" -e "groups" -e '^$' | sed -e '1,1d' | sort -r > $menu
    bash $gid_func
    set enter_gid = `awk '{print substr($0, index($0, "("), index($0, ")") -1 )}' $answer | sed -e "s/(//g" -e "s/)//g"`
    if ("$enter_gid" == "") then
        rm -f $gid_dir/tmp/*_$user  >& /dev/null
        exit(0)
    else
        printf "gid changed : \033[35m$enter_gid\033[m\n"
        newgrp $enter_gid
        exit(0)
    endif
endif
