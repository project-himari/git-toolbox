#!/bin/csh -f
#Virtuoso License Check ver.6 (last update 2023/03/10 created by kazama) 
#====== READ ME =====#
#ホームディレクリ内のcshrcに下記の1行を追加してください(#は外してください)
#alias vlic 'source /workdata/XCSR/others/Virtuoso_license_check/Virtuoso_license_check.csh'

#Virtuoso_license_check.cshは下記2つのファイルで構成されています。
#1:Virtuoso_license_check.csh    => メインスクリプト
#2:func_menu.sh                  => カーソル選択用の補助スクリプト(自動で生成されます)
#====================#

#============= User options ==============#
#Install directory (Default : ~/cmd)
set install_dir = /workdata/XCSR/others/Virtuoso_license_check
#Display update interval when using the loop option "-l" (Default:300 [sec])
set interval = 300
#License update interval when using the wait option "-w" (Default:30 [sec])
set wait_ade_interval = 30

#License server setting
set CADENSE_LICENSE_SERVER = '5280@idcliclxsv'
set AFS_LICENSE_SERVER     = '1717@10.20.35.208'
set BDA_LICENSE_SERVER     = '27002@tapt47'   #eikyu license 6 token

#====Developer Note====#
#Script mode
#:0 => License view
#:1 => License loop view   "-l"  option
#:2 => License wait mode   "-w"  option
#:3 => License remove mode "-rm" option
#=====================#

#============== Don't touch ==============#
#include file
set subfile_name  = func_menu.sh
set this_file_name = Virtuoso_license_check.csh
#set enviroment
set LINE            = "#=============================================#"
set tmp_file        = $install_dir/lms.tmp
set tmptmp_file     = $install_dir/lms.tmptmp
set menu_file       = $install_dir/menu.tmp 
set answer_file     = $install_dir/answer.tmp 
set sub_func        = $install_dir/$_subfile_name
set script_mode     = 0
set wait_flag_ADE   = 0
#set license token name
set LIC1   = Virtuoso_ADE_Explorer
set LIC2   = Virtuoso_ADE_Assembler
set LIC3   = Virtuoso_Schematic_Editor_L
set LIC4   = Virtuoso_Multi_mode_Simulation
set LIC5   = afslicense
set LIC6   = BDA_TOKEN
set LIC    = ($LIC1 $LIC2 $LIC3 $LIC4 $LIC5 $LIC6)
#set license label
set LIC_L1 = ADE-Explorer
set LIC_L2 = ADE-Assembler
set LIC_L3 = Schematic Editor
set LIC_L4 = MMSIM
set LIC_L5 = AFS
set LIC_L6 = BDA_ASAKA
set LIC_L  = ($LIC_L1 $LIC_L2 $LIC_L3 $LIC_L4 $LIC_L5 $LIC_L6)


#subfile create code
if (!(-f $sub_func))then
    printf "Message :\nCreated file -> $install_dir/\033[32m$subfile_name\033[m\n"
    touch $sub_func
    cut -c 2- $install_dir/$this_file_name | awk "/#func_START/,/#func_END/" | sed -e "1d" | sed -e "/#func_END/d" > $sub_func
    sed -i s:TIKAN_DIR:"$install_dir":g $sub_func
    chmod 777 $sub_func 
endif
#=========================# Don't touch #=========================#
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
##func_END
#=========================# Don't touch #=========================#

if ($#argv == 1) then
    if ("$argv[1]" == "-h") then
        cat << EOF
usage : vlic        -> The current license usage status is displayed.
usage : vlic -l     -> Keep updating the license display at regular intervals(Loop option)
Display update interval : 300 [sec]
            
=============================================
        
2022年  8月 18日 火曜日 15:19:39 JST
            
=============================================
=============================================
Status of License(Use/Total)
=============================================
 ADE-Exploter     : 9/16
 ADE-Assmbler     : 1/1
 Schematic_Editor : 10/12
 MMSIM            : 12/18
 AFS              : 8/32
 BDA_ASAKA        : 0/6
          
            
 Exit -> Press[Ctrl + C]
============================================
            
usage : vlic -l N   -> Set the update interval of Display of loop option to an arbitrary time(N=number)
   ex.  vlic -l 60  -> Display update interval 60 sec
usage : vlic -w N   -> License wait mode(N=number)
                          If any license is available, it will automatically grab the license and start viva.
   ex.  vlic -w     -> Wait ADE mode
usage : vlic -rm    -> License remove mode
            
EOF
        exit(0)


    else if ("$argv[1]" != "-l" && "$argv[1]" != "-h" && "$argv[1]" != "-rm" && "$argv[1]" != "-w") then
        printf "\033[31mError : Unknown option : $argv[1]\n        Please refer 'o the help (-h)\033[m\n"
        exit(0)
#Command "-rm " : License remove mode
#Script Mode = 3 =>licsense remove mode
    else if ("$argv[1]" == "-rm") then
        echo "$LIC_L" | sed -e "s/ /\n/g" > $tmp_file
       #bash menu view yobidasi 
        cp $tmp_file $menu_file ; bash $sub_func ; set enter = `cat $answer_file`
        if ("$enter" == "quit") then
            rm -f $answer_file $menu_file >& /dev/null
            exit(0)
        endif 

        set cnti = 1
        while ($cnti <= $#LIC)
            if ("$enter" == "$LIC_L[$cnti]") then
                set rm_lic = $cnti
                break
            else
                @ cnti ++
            endif
        end
        set script_mode = 3
#Command "-w " : License wait mode (Loop)
    else if ("$argv[1]" == "-w") then
        set vlic_check = `which viva >& /dev/null ; echo $status`
        if ($vlic_check > 0) then
            printf "\033[31mError : Product enviroment file(cshrc****) is not sourced.\033[m\n"
            printf "\033[31mPlease make sure that the enviroment(cshrc****) is set up.\033[m\n"
            exit(0)
        endif
        set wait_flag_ADE = 1
        set script_mode = 2
        set interval  = $wait_ade_interval
    else
#Loop option Command "-l"
        set script_mode = 1
    endif
#Command "-l N" (N=number)
else if ($#argv == 2) then
#Input Number Judge
    set input = "$argv[2]"
    set answer_status = `expr $input + 1 >& /dev/null ; echo $status`
    if ($answer_status >  1) then
        printf "\033[31mError : "$input" is not a number\n        Please refer to the help (-h)\033[m\n"
        exit(0)
    else if ("$argv[1]" == "-l") then
        set interval = "$argv[2]"
    endif
else if ($#argv > 2) then
    printf "\033[31mError : Too many argments\n        Please refer to the help (-h)\033[m\n"
    exit(0)
endif

setenv LOOP  1
while ($LOOP > 0)
    lmstat -c $CADENSE_LICENSE_SERVER -f $LIC1  > $tmptmp_file
    lmstat -c $CADENSE_LICENSE_SERVER -f $LIC2 >> $tmptmp_file
    lmstat -c $CADENSE_LICENSE_SERVER -f $LIC3 >> $tmptmp_file
    lmstat -c $CADENSE_LICENSE_SERVER -f $LIC4 >> $tmptmp_file
    lmstat -c $AFS_LICENSE_SERVER     -f $LIC5 >> $tmptmp_file
    lmstat -c $BDA_LICENSE_SERVER     -f $LIC6 >> $tmptmp_file
   
    set LIC_ALL1 = `grep "$LIC1" $tmptmp_file | awk '{ print $6;}'`
    set LIC_ALL2 = `grep "$LIC2" $tmptmp_file | awk '{ print $6;}'`
    set LIC_ALL3 = `grep "$LIC3" $tmptmp_file | awk '{ print $6;}'`
    set LIC_ALL4 = `grep "$LIC4" $tmptmp_file | awk '{ print $6;}'`
    set LIC_ALL5 = `grep "$LIC5" $tmptmp_file | awk '{ print $6;}'`
    set LIC_ALL6 = `grep "$LIC6" $tmptmp_file | awk '{ print $6;}'`
    set LIC_ALL  = ($LIC_ALL1 $LIC_ALL2 $LIC_ALL3 $LIC_ALL4 $LIC_ALL5 $LIC_ALL6)

    set LIC_USE1 = `grep "$LIC1" $tmptmp_file | awk '{ print $11;}'`
    set LIC_USE2 = `grep "$LIC2" $tmptmp_file | awk '{ print $11;}'`
    set LIC_USE3 = `grep "$LIC3" $tmptmp_file | awk '{ print $11;}'`
    set LIC_USE4 = `grep "$LIC4" $tmptmp_file | awk '{ print $11;}'`
    set LIC_USE5 = `grep "$LIC5" $tmptmp_file | awk '{ print $11;}'`
    set LIC_USE6 = `grep "$LIC6" $tmptmp_file | awk '{ print $11;}'`
    set LIC_USE  = ($LIC_USE1 $LIC_USE2 $LIC_USE3 $LIC_USE4 $LIC_USE5 $LIC_USE6)
#Script mode = 0 => default license view 
    if ($script_mode == 0) then
        echo "$LINE\n#\n#`date`\n#\n$LINE\n"                           > $tmp_file
        set cnti = 1
        while ($cnti <= $#LIC)
            echo "$LINE\n#$LIC_L[$cnti]\n$LINE"                       >> $tmp_file
            sed -n -e "/Users of $LIC[$cnti]/,/lmstat/p" $tmptmp_file >> $tmp_file
            @ cnti ++
        end

    else if ($script_mode == 1 || $script_mode == 2) then
        echo "Display update interval : $interval [sec]"               > $tmp_file
        echo "$LINE\n#\n#`date`\n#\n$LINE\n"                          >> $tmp_file
        
        if ($script_mode == 2) then
            if ($LIC_ALL[1] > $LIC_USE[1] || $LIC_ALL[2] > $LIC_USE[2]) then
                viva -64 &
                break
            endif
        endif
    else if ($script_mode == 3) then
        echo "lmremove $LIC_L[$rm_lic] : $LIC_USE[$rm_lic]/$LIC_ALL[$rm_lic] (Use/Total)"
        sed -n -e "/Users of $LIC[$rm_lic]/,/lmstat/p" $tmptmp_file  > $tmp_file
        sed -i -e '/lmstat/d' -e '/Users of /d' -e '/mgcld/d' -e '/Analog/d' -e '/Virtuoso/d' -e '/float/d' -e "s/    //g" -e '/^$/d' $tmp_file
       #bash menu view yobidasi 
        cp $tmp_file $menu_file ; bash $sub_func ; set enter = `cat $answer_file`
        if ("$enter" == "quit") then
            rm -f $answer_file $menu_file >& /dev/null
            exit(0)
        endif
        #license server judge 
        if ("$rm_lic" == 5) then
            set SEL_LICENSE_SERVER = $AFS_LICENSE_SERVER
        else if ("$rm_lic" == 6) then
            set SEL_LICENSE_SERVER = $BDA_LICENSE_SERVER
        else
            set SEL_LICENSE_SERVER = $CADENSE_LICENSE_SERVER
        endif

        set lm_account = `grep "" $answer_file | sed "s/ /,/g" | \
        awk -F, -v SEL_LICENSE_SERVER="$SEL_LICENSE_SERVER" -v LIC="$LIC[$rm_lic]" \
        '{print "lmremove -c " SEL_LICENSE_SERVER " " LIC " " $1 " " $2 " "$3 }'`
        printf  "[CHECK]Do you really want to remove this license? [Press:y/n/Enter]\n\033[32m=>$lm_account\033[m\n"
        set answer = $<
        if ($answer == "y" || $answer == "") then
            $lm_account
            echo "Removed license"
        else if ($answer == "n") then
            echo "Canceled"
        else
            printf "\033[31mDon't understand : $answer\033[m\n"
        endif
        rm -f $answer_file $menu_file >& /dev/null
        exit(0)
    endif

    if ($script_mode < 3) then
        set cnti = 1
        echo "$LINE\n#Status of License(Use/Total)\n$LINE"                                                      >> $tmp_file
        while ($cnti <= $#LIC)
            grep "${LIC[$cnti]}:" $tmptmp_file | awk '{ print " : "$11"/"$6;}' | sed -e "s/^/ $LIC_L[$cnti]/g"  >> $tmp_file
            sed -n -e "/Users of $LIC[$cnti]/,/lmstat/p" $tmptmp_file | grep $user                              >> $tmp_file
            @ cnti ++
        end
    endif
    
    if ($script_mode == 1 || $script_mode == 2) then
        clear
    endif
    
    if ($script_mode == 2) then
        echo "Waiting for lisences : _E$wait_flag_ADE,  _A$wait_flag_ADE" | \
        sed -e "s/_E1/$LIC_L[1]/g"  -e "s/_A1/$LIC_L[2]/g" -e "s/_E0, //g" -e "s/_A0//g"
    endif

    sed -i -e "s/   $user/==>$user/g"  -e '/lmstat/d' -e '/cdslmd/d' -e '/mgcld/d' -e '/floating/d' -e "s/Users/\nUsers/g" -e "s/use)/use)\n/g" -e '/^$/d' $tmp_file
    
    grep --color=auto \
    -e "==>$user" \
    -e " $LIC_ALL[1]/$LIC_ALL[1] " \
    -e " $LIC_ALL[2]/$LIC_ALL[2] " \
    -e " $LIC_ALL[3]/$LIC_ALL[3] " \
    -e " $LIC_ALL[4]/$LIC_ALL[4] " \
    -e " $LIC_ALL[5]/$LIC_ALL[5] " \
    -e " $LIC_ALL[6]/$LIC_ALL[6] " \
    -e '$' $tmp_file
    
    rm -f $tmptmp_file >& /dev/null
    if ($script_mode == 0) then
        break
    else
        echo "\n\n\nExit -> Press[Ctrl + C]"
        sleep $interval
    endif
end
