#!/bin/csh -f
#gid_change.csh  ver.2 (last update 2023/02/08 created by kazama)

#======#READ ME#=====#
#ホームディレクリ内のcshrcに下記の2行を追加してください(#は外してください)
#alias gid 'source /workdata/XCSR/others/gid_change/gid_change.csh'
#source /workdata/XCSR/others/gid_change/gid_change.csh -b

#sinkankyou you desu
#gid_change.cshは下記2つのファイルで構成されています。
#1:gid_change.csh         => メインスクリプト
#2:gid_gid_func_menu.sh   => カーソル選択用の補助スクリプト(自動で生成されます)
#====================#

set gid_install_dir = /workdata/XCSR/others/gid_change
set this_file_name = gid_change.csh
set subfile_name = gid_func_menu.sh

#subfile create code
if (!(-f $gid_install_dir/$subfile_name))then
    printf "Message :\nCreated file -> $gid_install_dir/\033[32m$subfile_name\033[m\n"
    touch $gid_install_dir/$subfile_name
    cut -c 2- $gid_install_dir/$this_file_name | awk "/#func_START/,/#func_END/" | sed -e "1d" | sed -e "/#func_END/d" > $gid_install_dir/$subfile_name
endif
#=========================# Don't touch #=========================#
##func_START
##!/bin/bash
#function menu {
#choice=0
#IFS=$'\n'
#menu=($(cat /workdata/XCSR/others/gid_change/tmp/gid_menu.tmp))
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
#        echo "quit" > /workdata/XCSR/others/gid_change/tmp/gid_answer.tmp
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
#        echo ${menu[$choice]} > /workdata/XCSR/others/gid_change/tmp/gid_answer.tmp
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
    id | sed -e "s/)/)\n/g" -e "s/id=/id:/g" -e "s/=/\n/g" -e "s/,//g" | sed -e 's/^[ \t]*//g' | grep -1 -e "gid"
    id | sed -e "s/)/)\n/g" -e "s/id=/id:/g" -e "s/=/\n/g" -e "s/,//g" | sed -e 's/^[ \t]*//g' | grep -v -e "id" -e "groups" -e "所属グループ" -e '^$' | sort -r > $gid_install_dir/tmp/gid_menu.tmp
    
    bash $gid_install_dir/gid_func_menu.sh
    set enter_gid = `cat $gid_install_dir/tmp/gid_answer.tmp | awk '{print substr($0, index($0, "("), index($0, ")") -1 )}' | sed -e "s/(//g" -e "s/)//g"`
    if ("$enter_gid" == "") then
        rm -f $gid_install_dir/tmp/gid_menu.tmp $gid_install_dir/tmp/gid_answer.tmp >& /dev/null
        exit(0)
    endif
    
    rm -f $gid_install_dir/tmp/gid_menu.tmp $gid_install_dir/tmp/gid_answer.tmp >& /dev/null
    set sel_dir = `ls -la /workdata/ | grep -v -e "root root" -e "users" | sed -e "s/    / /g" -e "s/   / /g" -e "s/  / /g"  | grep -e "$enter_gid" | cut -d " " -f 10  | wc -l`
    set ent_dir = `ls -la /workdata/ | grep -v -e "root root" -e "users" | sed -e "s/    / /g" -e "s/   / /g" -e "s/  / /g"  | grep -e "$enter_gid" | cut -d " " -f 10 `
    if ($sel_dir == 0) then
        echo "ERROR:あなたの権限で入れる製品ディレクトリが見つかりませんでした。"
    else if ($sel_dir == 1) then
        echo $ent_dir
        cd /workdata/$ent_dir
        pwd
    else if ($sel_dir > 1) then
        echo "同じgidを持つ製品ディレクトリが2つ以上見つかりました。どちらのディレクトリにはいりますか?"
        ls -la /workdata/ | grep -v -e "root root" -e "users" | sed -e "s/    / /g" -e "s/   / /g" -e "s/  / /g"  | grep -e "$enter_gid" | cut -d " " -f 10 >  $gid_install_dir/tmp/gid_menu.tmp
        
        bash $gid_install_dir/gid_func_menu.sh
        set enter = `cat $gid_install_dir/tmp/gid_answer.tmp`
        if ($enter == "quit") then
            rm -f $gid_install_dir/tmp/gid_menu.tmp $gid_install_dir/tmp/gid_answer.tmp >& /dev/null
            exit(0)
        endif
        cd /workdata/$enter
    endif
    
    tree -L 3 -d -f | sed -e '/director/d' -e '/^$/d'|grep -e "composer" | sed -e 's/ //g' -e 's/--/@@/g' -e 's/|//g' | cut -c 3- | sed -e 's/|//g'  -e 's/@//g'  > $gid_install_dir/tmp/gid_menu.tmp
    set composer_count = `cat $gid_install_dir/tmp/gid_menu.tmp|wc -l`
    if ($composer_count == 0) then
        echo "ERROR:composerディレクトリが見つかりませんでした。"
        exit(0)
    else if ($composer_count == 1) then
        cd `tree -L 3 -d -f | sed -e '/director/d' -e '/^$/d'|grep -e "composer" | sed -e 's/ //g' -e 's/--/@@/g' -e 's/|//g' | cut -c 3- | sed -e 's/|//g'  -e 's/@//g' `
        printf "\033[35mCurrent Directory\033[m : `pwd`\n"
    else if ($composer_count > 1) then
        echo "composerが2つ以上見つかりました。どちらのcomposerに入りますか?"
        bash $gid_install_dir/gid_func_menu.sh
        set enter = `cat $gid_install_dir/tmp/gid_answer.tmp`
        if ($enter == "quit") then
            rm -f $gid_install_dir/tmp/gid_menu.tmp $gid_install_dir/tmp/gid_answer.tmp >& /dev/null
            exit(0)
        endif
        set composer = `cat $gid_install_dir/tmp/gid_answer.tmp`
        cd $composer ; printf "\033[35mCurrent Directory\033[m : `pwd`\n"
    endif
    printf "\033[33mgid changed\033[m : \033[35m$enter_gid\033[m\n"
    echo "1" > $gid_install_dir/tmp/gid_newgrp_flag.tmp
    newgrp $enter_gid
endif


#newgrp after new cshrc
if($#argv == 1) then
    if(-f $gid_install_dir/tmp/gid_newgrp_flag.tmp && "$argv[1]" == "-b") then
        if (`cat $gid_install_dir/tmp/gid_newgrp_flag.tmp` == 1) then
            rm  -f $gid_install_dir/tmp/gid_newgrp_flag.tmp >& /dev/null
            find -maxdepth 1 -name '*cshrc*' > $gid_install_dir/tmp/gid_menu.tmp
            echo "読み込むcshrcを選択してください。"
            bash $gid_install_dir/gid_func_menu.sh
            set enter = `cat $gid_install_dir/tmp/gid_answer.tmp`
            if ($enter == "quit") then
                rm -f $gid_install_dir/tmp/gid_menu.tmp $gid_install_dir/tmp/gid_answer.tmp >& /dev/null
                exit(0)
            else
                set cshrc_select = `cat $gid_install_dir/tmp/gid_answer.tmp`
                source $cshrc_select
                rm -f $gid_install_dir/tmp/gid_menu.tmp $gid_install_dir/tmp/gid_answer.tmp >& /dev/null
            endif
        endif
        exit(0)
    endif
endif

