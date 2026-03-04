#!/bin/csh -f
#Virtuoso License Check ver.5 (last update 2023/02/22 created by kazama) 
#============= User options ==============#
#Install directory
set install_dir = /workdata/XCSR/others/Virtuoso_license_check
#Display update interval when using the loop option "-l" (Default:300 [sec])
set interval = 300
#License update interval when using the wait option "-w" (Default:30 [sec])
set wait_ade_interval = 30

set CADENSE_LICENCE_SERVER = '5280@idcliclxsv'
set AFS_LICENCE_SERVER     = '1717@10.20.35.208'

#============== Don't touch ==============#
#include file
set subfile_name = func_menu.sh
set this_file_name = Virtuoso_license_check.csh

#set enviroment
set LINE                    = "#=============================================#"
set tmp_file                = $install_dir/tmp/lms.tmp
set tmptmp_file             = $install_dir/tmp/lms.tmptmp
set script_mode             = 0
set wait_flag_ADE_Explorer  = 0
set wait_flag_ADE_Assembler = 0

#subfile create code
if (!(-f $install_dir/$subfile_name))then
    printf "Message :\nCreated file -> $install_dir/\033[32m$subfile_name\033[m\n"
    touch $install_dir/$subfile_name
    cut -c 2- $install_dir/$this_file_name | awk "/#func_START/,/#func_END/" | sed -e "1d" | sed -e "/#func_END/d" > $install_dir/$subfile_name
endif
#=========================# Don't touch #=========================#
##func_START
##!/bin/bash
#function menu {
#choice=0
#IFS=$'\n'
#menu=($(cat /workdata/XCSR/others/Virtuoso_license_check/tmp/menu.tmp))
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
#        echo "quit" > /workdata/XCSR/others/Virtuoso_license_check/tmp/answer.tmp
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
#        echo ${menu[$choice]} > /workdata/XCSR/others/Virtuoso_license_check/tmp/answer.tmp
#        return
#        ;;
#    esac
#done
#}
#
#menu
##func_END
#=========================# Don't touch #=========================#




if ($#argv > 0) then
#Loop option Command "-l"
    set script_mode = 1
    if ($#argv == 1) then
        if ("$argv[1]" == "-h") then
            cat << EOF
usage : command        -> The current license usage status is displayed.
usage : command -l     -> Keep updating the license display at regular intervals(Loop option)
Display update interval : 300 [sec]
            
=============================================
        
2022Ç¯  8·î 18Æü ²ÐÍËÆü 15:19:39 JST
            
=============================================
=============================================
Status of License(Use/Total)
=============================================
 ADE-Exploter     : 9/16
 ADE-Assmbler     : 1/1
 Schematic_Editor : 10/12
 MMSIM            : 12/18
 AFS              : 8/32
          
            
 Exit -> Press[Ctrl + C]
============================================
            
usage : command -l N   -> Set the update interval of Display of loop option to an arbitrary time(N=number)
   ex.  command -l 60  -> Display update interval 60 sec
usage : command -w N   -> License wait mode(N=number)
                          If any license is available, it will automatically grab the license and start viva.
   ex.  command -w 1   -> Wait ADE_Explorer
        command -w 2   -> Wait ADE_Assembler
        command -w 12  -> Wait ADE_Explorer, ADE_Assembler
                -w 12  : ok
                -w 21  : ok
                -w 121 : error
usage : command -rm N  -> License remove mode(N=number)
   ex.  command -rm 1  -> Remove license : ADE_Explorer
        command -rm 2  -> Remove license : ADE_Assembler
        command -rm 3  -> Remove license : Schematic_Editer
                -rm 12 : error
            
EOF
            
            exit(0)

        else if ("$argv[1]" == "-w") then
            printf "\033[31mError : Not enough argments. Please refer to the help (-h)\033[m\n"
            exit(0)

        else if ("$argv[1]" != "-l" && "$argv[1]" != "-h" && "$argv[1]" != "-rm" && "$argv[1]" != "-w") then
            printf "\033[31mError : Unknown option : $argv[1]\n        Please refer to the help (-h)\033[m\n"
            exit(0)
        else if ("$argv[1]" == "-rm") then
            echo "ADE_Explorer"      > $tmp_file
            echo "ADE_Assembler"    >> $tmp_file
            echo "Schematic_Editer" >> $tmp_file
            cp $tmp_file $install_dir/tmp/menu.tmp
            bash $install_dir/$subfile_name
            set enter = `cat $install_dir/tmp/answer.tmp`
            if ("$enter" == "quit") then
                rm -f $install_dir/tmp/answer.tmp $install_dir/tmp/menu.tmp >& /dev/null
                exit(0)
            else if ("$enter" == "ADE_Explorer") then
                set rm_lic = 1
            else if ("$enter" == "ADE_Assembler") then
                set rm_lic = 2
            else if ("$enter" == "Schematic_Editer") then
                set rm_lic = 3
            endif
            set script_mode = 3
        endif

#Command "-l N" (N=number)
    else if ($#argv == 2) then
        set input = "$argv[2]"
        set answer_status = `expr $input + 1 >& /dev/null ; echo $status`
        if ($answer_status >  1) then
            printf "\033[31mError : "$input" is not a number\n        Please refer to the help (-h)\033[m\n"
            exit(0)
        else if ("$argv[1]" == "-l") then
            set interval = "$argv[2]"
#Command "-w N" (N=number) : License wait mode (Loop)
        else if ("$argv[1]" == "-w") then
            set command_check = `which viva >& /dev/null ; echo $status`
            if ($command_check > 0) then
                printf "\033[31mError : Product enviroment file(cshrc****) is not sourced.\033[m\n"
                printf "\033[31mPlease make sure that the enviroment(cshrc****) is set up.\033[m\n"
                exit(0)
            endif
            set in_check = `echo $input |  grep -o -e "0" -e "3" -e "4" -e "5" -e "6" -e "7" -e "8" -e "9" | wc -l`
            if ($in_check > 0) then
                printf "\033[31mError : There is an error in the input : $input\n        Please refer to the help (-h)\033[m\n"
                exit(0)
            endif
            set script_mode = 2
            set in_check_ADE_Explorer   = `echo $input | grep -o 1 | wc -l`
            set in_check_ADE_Assembler  = `echo $input | grep -o 2 | wc -l`
            if ($in_check_ADE_Explorer == 1) then
                set wait_flag_ADE_Explorer = 1
            endif
            if ($in_check_ADE_Assembler == 1) then
                set wait_flag_ADE_Assembler = 1
            endif
            if ($in_check_ADE_Explorer > 1 || $in_check_ADE_Assembler > 1) then
                printf "\033[31mError : There is an error in the input : $input\n        Please refer to the help (-h)\033[m\n"
                exit(0)
            endif
            set interval  = $wait_ade_interval
#Command "-rm N" (N=number) : License remove mode
#Script Mode = 3 =>licsense remove mode
        else if ("$argv[1]" == "-rm") then
            if ("$argv[2]" ==  0 || "$argv[2]" > 3) then
                printf "\033[31mError : There is an error in the input : $input\n        Please refer to the help (-h)\033[m\n"
                exit(0)
            else
                set rm_lic = "$argv[2]"
            endif
            set script_mode = 3
        endif
    else if ($#argv > 2) then
        printf "\033[31mError : Too many argments\n        Please refer to the help (-h)\033[m\n"
        exit(0)
    endif
endif

setenv LOOP  1
while ($LOOP > 0)
    lmstat -c $CADENSE_LICENCE_SERVER -f Virtuoso_ADE_Explorer           > $tmptmp_file
    lmstat -c $CADENSE_LICENCE_SERVER -f Virtuoso_ADE_Assembler         >> $tmptmp_file
    lmstat -c $CADENSE_LICENCE_SERVER -f Virtuoso_Multi_mode_Simulation >> $tmptmp_file
    lmstat -c $CADENSE_LICENCE_SERVER -f Virtuoso_Schematic_Editor_L    >> $tmptmp_file
    lmstat -a -c $AFS_LICENCE_SERVER                                    >> $tmptmp_file

    set EXPLORER      = `grep "Virtuoso_ADE_Explorer:"          $tmptmp_file | gawk '{ print $6;}'`
    set ASSEMBLER     = `grep "Virtuoso_ADE_Assembler:"         $tmptmp_file | gawk '{ print $6;}'`
    set SCH           = `grep "Virtuoso_Schematic_Editor_L:"    $tmptmp_file | gawk '{ print $6;}'`
    set MMSIM         = `grep "Virtuoso_Multi_mode_Simulation:" $tmptmp_file | gawk '{ print $6;}'`
    set AFS           = `grep "afslicense:"                     $tmptmp_file | gawk '{ print $6;}'`
    set EXPLORER_USE  = `grep "Virtuoso_ADE_Explorer:"          $tmptmp_file | gawk '{ print $11;}'`
    set ASSEMBLER_USE = `grep "Virtuoso_ADE_Assembler:"         $tmptmp_file | gawk '{ print $11;}'`
    set SCH_USE       = `grep "Virtuoso_Schematic_Editor_L:"    $tmptmp_file | gawk '{ print $11;}'`
    
    if ($script_mode == 0) then
        echo "$LINE\n#\n#`date`\n#\n$LINE\n"                                          > $tmp_file
        echo "$LINE\n#ADE Explorer & Assembler\n$LINE"                               >> $tmp_file
        cat $tmptmp_file | awk '/Users of Virtuoso_ADE_Explorer:/,/lmstat/'          >> $tmp_file
        cat $tmptmp_file | awk '/Users of Virtuoso_ADE_Assembler:/,/lmstat/'         >> $tmp_file
        echo "$LINE\n#Schematic Editor\n$LINE"                                       >> $tmp_file
        cat $tmptmp_file | awk '/Users of Virtuoso_Schematic_Editor_L:/,/lmstat/'    >> $tmp_file
        echo "$LINE\n#MMSIM\n$LINE"                                                  >> $tmp_file
        cat $tmptmp_file | awk '/Users of Virtuoso_Multi_mode_Simulation:/,/lmstat/' >> $tmp_file
        echo "$LINE\n#AFS\n$LINE"                                                    >> $tmp_file
        cat $tmptmp_file | awk '/Users of afslicense:/,/afswavecrave:/'              >> $tmp_file
    else if ($script_mode == 1 || $script_mode == 2) then
        echo "Display update interval : $interval [sec]"                              > $tmp_file
        echo "$LINE\n#\n#`date`\n#\n$LINE\n"                                         >> $tmp_file
        
        if ($wait_flag_ADE_Explorer == 1 && $EXPLORER > $EXPLORER_USE || $wait_flag_ADE_Assembler == 1 && $ASSEMBLER > $ASSEMBLER_USE) then
            viva -64 &
            break
        endif
    else if ($script_mode == 3) then
        if ("$rm_lic" == 1) then
            echo "lmremove ADE_Explorer     : $EXPLORER_USE/$EXPLORER (Use/Total)"
            cat  $tmptmp_file | awk '/Users of Virtuoso_ADE_Explorer:/,/lmstat/'        > $tmp_file
        else if ("$rm_lic" == 2) then
            echo "lmremove ADE_Assembler    : $ASSEMBLER_USE/$ASSEMBLER (Use/Total)"
            cat $tmptmp_file | awk '/Users of Virtuoso_ADE_Assembler:/,/lmstat/'        > $tmp_file
        else if ("$rm_lic" == 3) then
            echo "lmremove Schematic_Editor : $SCH_USE/$SCH (Use/Total)"
            cat $tmptmp_file | awk '/Users of Virtuoso_Schematic_Editor_L:/,/lmstat/'   > $tmp_file
        endif
        
        sed -i \
        -e '/lmstat/d' \
        -e '/Analog/d' \
        -e '/Virtuoso/d' \
        -e '/float/d' \
        -e "s/    //g" \
        -e '/^$/d' $tmp_file
        
        cp $tmp_file $install_dir/tmp/menu.tmp
        bash $install_dir/$subfile_name
        set enter = `cat $install_dir/tmp/answer.tmp`
        if ("$enter" == "quit") then
            rm -f $install_dir/tmp/answer.tmp $install_dir/tmp/menu.tmp >& /dev/null
            exit(0)
        endif

        if ("$rm_lic" == 1) then
            set lm_lic = `grep "" $install_dir/tmp/answer.tmp | sed "s/ /,/g" | \
            awk -F, -v CADENSE_LICENCE_SERVER="$CADENSE_LICENCE_SERVER" '{print "lmremove -c " CADENSE_LICENCE_SERVER " Virtuoso_ADE_Explorer " $1 " " $2 " "$3 }'`
        else if ("$rm_lic" == 2) then
            set lm_lic = `grep "" $install_dir/tmp/answer.tmp | sed "s/ /,/g" | \
            awk -F, -v CADENSE_LICENCE_SERVER="$CADENSE_LICENCE_SERVER" '{print "lmremove -c " CADENSE_LICENCE_SERVER " Virtuoso_ADE_Assembler " $1 " " $2 " "$3 }'`
        else if ("$rm_lic" == 3) then
            set lm_lic = `grep "" $install_dir/tmp/answer.tmp |sed "s/ /,/g" | \ 
            awk -F, -v CADENSE_LICENCE_SERVER="$CADENSE_LICENCE_SERVER" '{print "lmremove -c " CADENSE_LICENCE_SERVER " Virtuoso_Schematic_Editor_L " $1 " " $2 " "$3 }'`
        endif
        
        printf  "[CHECK]Do you really want to remove this license? [Press:y/n/Enter]\n\033[32m=>$lm_lic\033[m\n"
        set answer = $<
        if ($answer == "y" || $answer == "") then
            $lm_lic
            echo "Removed license"
        else if ($answer == "n") then
            echo "Canceled"
        else
            printf "\033[31mDon't understand : $answer\033[m\n"
        endif
        rm -f $install_dir/tmp/answer.tmp $install_dir/tmp/menu.tmp >& /dev/null
        exit(0)
    endif
    if ($script_mode < 3) then
        echo "$LINE\n#Status of License(Use/Total)\n$LINE"                                                     >> $tmp_file
        grep "Virtuoso_ADE_Explorer:"           $tmptmp_file | gawk '{ print " ADE-Explorer     : "$11"/"$6;}' >> $tmp_file
        cat $tmptmp_file | awk '/Users of Virtuoso_ADE_Explorer:/,/lmstat/'                 | grep $user >> $tmp_file
        grep "Virtuoso_ADE_Assembler:"          $tmptmp_file | gawk '{ print " ADE-Assmbler     : "$11"/"$6;}' >> $tmp_file
        cat $tmptmp_file | awk '/Users of Virtuoso_ADE_Assembler:/,/lmstat/'                      | grep $user >> $tmp_file
        grep "Virtuoso_Schematic_Editor_L:"     $tmptmp_file | gawk '{ print " Schematic_Editor : "$11"/"$6;}' >> $tmp_file
        cat $tmptmp_file | awk '/Users of Virtuoso_Schematic_Editor_L:/,/lmstat/'                 | grep $user >> $tmp_file
        grep "Virtuoso_Multi_mode_Simulation:"  $tmptmp_file | gawk '{ print " MMSIM            : "$11"/"$6;}' >> $tmp_file
        cat $tmptmp_file | awk '/Users of Virtuoso_Multi_mode_Simulation:/,/lmstat/'              | grep $user >> $tmp_file
        grep "afslicense:"                      $tmptmp_file | gawk '{ print " AFS              : "$11"/"$6;}' >> $tmp_file
        cat $tmptmp_file | awk '/Users of afslicense:/,/afswavecrave:/'                           | grep $user >> $tmp_file
    endif
    
    if ($script_mode == 1 || $script_mode == 2) then
        clear
    endif
    
    if ($script_mode == 2) then
        echo "Waiting for lisences : _E$wait_flag_ADE_Explorer,  _A$wait_flag_ADE_Assembler" | \
        sed -e "s/_E1/ADE_Explorer/g"  -e "s/_A1/ADE_Assembler/g" -e "s/_L0, //g" -e "s/_XL0, //g" -e "s/_A0//g"
    endif

    sed -i -e "s/   $user/==>$user/g" \
    -e '/lmstat/d' \
    -e '/afswavecrave:/d' \
    -e '/BDA_WAVECRAVE:/d' \
    -e '/cdslmd/d' \
    -e '/mgcld/d' \
    -e '/floating/d' \
    -e "s/Users/\nUsers/g"\
    -e "s/use)/use)\n/g"\
    -e '/Users of aesim:/d'\
    -e '/^$/d' $tmp_file
    
    grep --color=auto \
    -e "==>$user" \
    -e "$EXPLORER/$EXPLORER" \
    -e " $ASSEMBLER/$ASSEMBLER" \
    -e "$SCH/$SCH" \
    -e "$MMSIM/$MMSIM" \
    -e "$AFS/$AFS" \
    -e '$' $tmp_file
    
    rm -f $tmptmp_file >& /dev/null
    if ($script_mode == 0) then
        break
    else
        echo "\n\n\nExit -> Press[Ctrl + C]"
        sleep $interval
    endif
end
