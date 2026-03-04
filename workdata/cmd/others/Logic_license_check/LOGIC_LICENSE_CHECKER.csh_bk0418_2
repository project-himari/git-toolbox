#!/bin/csh -f
#Logic License Check ver.4 (last update 2024/02/21 created by kazama@Shibaura) 
#====== READ ME =====#
#ホームディレクリ内のcshrcに下記の1行を追加してください(#は外してください)
#alias log_lic 'source /workdata_ap_old/XCSR/others/Logic_license_check/LOGIC_FEAUTURE_ARRAYSENSE_CHECKER.csh'

#logic_license_check.cshは下記2つのファイルで構成されています。
#1:logic_license_check.csh => メインスクリプト
#2:func_menu.sh            => カーソル選択用の補助スクリプト(自動で生成されます)
#====================#

#======================================================#
# User settings
#======================================================#
#Install directory 
#set INST_DIR = /workdata/XCSR/others/LOGIC_license_check
set INST_DIR = /workdata_ap_old/XCSR/others/Logic_license_check
#Display update interval when using the loop option "-l" (Default:300 [sec])
set interval = 300
#License server setting
set SERVER1 = '5280@idcliclxsv'                 ;#Cadence 
set SERVER2 = '56104@idcliclxsv-ex'             ;#Cadence Modus,GENUS 
set SERVER3 = '27000@idclicsv:27020@idcliclxsv' ;#Synopsys

#lmstat -a -c 5280@idcliclxsv
#license token name
set FEAUTURE_ARRAYS = (PrimeTime-SI  nWave     Verdi      nSchema   hdlin_mixed     Genus_Synthesis    Conformal_Ultra Xcelium_Single_Core   VC-LINT-BASE    VC-CDC-BASE )
#license label         ||            ||        ||         ||        ||              ||                 ||              ||                    ||              || (Label name is user custum)
set LABEL_ARRAYS    = (PrimeTime     nWave     Verdi      deb       system_verilog  Genus              Conformal-LEC   Xcelium               Spyglass-Lint   Spyglass-CDC)
#license sever         ||            ||        ||         ||        ||              ||                 ||              ||                    ||              ||
set SERVER_ARRAYS   = ($SERVER3      $SERVER3  $SERVER3   $SERVER3  $SERVER3        $SERVER2           $SERVER2        $SERVER1              $SERVER3        $SERVER3    )

#======================================================#
# Developer settings
#======================================================#
#include file
set subfile_name   = func_menu.sh
set this_file_name = LOGIC_LICENSE_CHECKER.csh
set tmp_file       = $INST_DIR/lms.tmp
set tmptmp_file    = $INST_DIR/lms.tmptmp
set menu_file      = $INST_DIR/menu.tmp
set menu_answer    = $INST_DIR/answer.tmp
set menu_choice    = $INST_DIR/$subfile_name
#set enviroment
set LINE           = "#=============================================#"
set script_mode    = 0
set lic_all_arrays = ($FEAUTURE_ARRAYS)
set lic_use_arrays = ($FEAUTURE_ARRAYS)
#subfile create code (FROM=func_START TO=func_END)
if (!(-f $menu_choice))then
    printf "Message :\nCreated file -> $INST_DIR/\033[32m$subfile_name\033[m\n"
    touch $menu_choice
    cut -c 2- $INST_DIR/$this_file_name | awk "/#func_START/,/#func_END/" | sed -e "1d" | sed -e "/#func_END/d" -e "/#func_START/d"> $menu_choice
    chmod 777 $menu_choice 
endif

#=========================# Don't touch #=========================#
##func_START
##!/bin/bash
#function menu_choice {
#choice=0
#IFS=$'\n'
#menu=($(cat "$1"))
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
#        echo "quit" > $2
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
#        echo ${menu[$choice]} > $2
#        return
#        ;;
#    esac
#done
#}
#menu_choice $1 $2
##func_END
#=========================# Don't touch #=========================#
#=========================# Main Script #=========================#
if ($#argv == 1) then
    set option = $argv[1]
#Command Option "-h" => Help menu_choice view (Users Guide)
    if ("$argv[1]" == "-h" || "$argv[1]" == "--help") then
        cat << EOF
usage : log_lic        -> The current license usage status is displayed.
usage : log_lic -l     -> Keep updating the license display at regular intervals(Loop option)
Display update interval : 300 [sec]
ex. display image 
#=============================================#
#Status of License(Use/Total)
#=============================================#
 0/2	: PrimeTime
 1/9	: nWave
 0/1	: Verdi
 0/8	: deb
 0/1	: system_verilog
 0/1	: Genus
 0/1	: Conformal-LEC
 2/8	: Xcelium

Exit -> Press[Ctrl + C] 
Display update interval : 300 [sec]
============================================
            
usage : log_lic -l N   -> Set the update interval of Display of loop option to an arbitrary time(N=number)
   ex.  log_lic -l 60  -> Display update interval 60 sec
usage : log_lic -rm    -> License remove mode
EOF

        exit(0)
#Command "-rm " : License remove mode
    else if ("$argv[1]" == "-rm") then
        echo "$LABEL_ARRAYS" | sed -e "s/ /\n/g" > $menu_file
        bash $menu_choice $menu_file $menu_answer ;#bash menu_choice view calling
        if ( `cat $menu_answer` == "quit") then
            rm -f $menu_answer $menu_file >& /dev/null
            exit(0)
        endif 

        set i = 1
        while ($i <= $#FEAUTURE_ARRAYS)
            if ( `cat $menu_answer` == "$LABEL_ARRAYS[$i]") then
                set rm_lic = $i
                break
            else
                @ i ++
            endif
        end
        set script_mode = 3
#Loop option Command "-l"
    else if ("$argv[1]" == "-l") then
        set script_mode = 1
    else if ("$argv[1]" == "-a") then
        echo $SERVER_ARRAYS |sed -e "s/ /\n/g" | sort | uniq  > $menu_file
        bash $menu_choice $menu_file $menu_answer ;#bash menu_choice view calling 
        if ( `cat $menu_answer` == "quit") then
            rm -f $menu_answer $menu_file  >& /dev/null
            exit(0)
        endif
        
        lmstat -a -c `cat $menu_answer` \
        | grep -e  "license" -e "start" | grep -v -e "floating" -e "Error" \
        | sed -e "s/Users of /$LINE\n/g" -e "s/ in use)/)\n$LINE/g" -e "s/Total of //g" -e "s/ licenses//g" -e "s/ license//g" -e "s: issued;:/:g" 
        rm -f $menu_answer $menu_file  >& /dev/null
        exit(0)
    else     
        printf "\033[31mError : Unknown option : $argv[1]\n        Please refer to the help (-h)\033[m\n"
        exit(0)

    endif
#Command "-l N" (N=number)
else if ($#argv == 2) then
#Input Number Judge
    set isNumber = `expr $argv[2] + 1 >& /dev/null ; echo $status`
    if ($isNumber >  1) then
#    if (`expr $argv[2] + 1 >& /dev/null && echo $status` == "") then
        printf "\033[31mError : "$argv[2]" is not a number\n        Please refer to the help (-h)\033[m\n"
        exit(0)
    else if ("$argv[1]" == "-l") then
        set script_mode = 1
    endif
    set interval = "$argv[2]"    
else if ($#argv > 2) then
    printf "\033[31mError : Too many argments\n        Please refer to the help (-h)\033[m\n"
    exit(0)
endif

while ($#FEAUTURE_ARRAYS > 0)
    set i = 1   
    printf "" > $tmptmp_file ; printf "" > $tmp_file
    while ($i <= $#FEAUTURE_ARRAYS) 
        lmstat -c $SERVER_ARRAYS[$i] -f $FEAUTURE_ARRAYS[$i]                    >> $tmptmp_file
        set lic_all_arrays[$i] = `grep "$FEAUTURE_ARRAYS[$i]" $tmptmp_file | awk '{ print $6;}'`
        set lic_use_arrays[$i] = `grep "$FEAUTURE_ARRAYS[$i]" $tmptmp_file | awk '{ print $11;}'`
        @ i ++
    end

#Script mode = 0 => default license view 
    set j = 1
    if ($script_mode == 0) then
        while ($j <= $#FEAUTURE_ARRAYS)
            echo "$LINE\n#$LABEL_ARRAYS[$j]\n$LINE"                            >> $tmp_file
            sed -n -e "/Users of $FEAUTURE_ARRAYS[$j]/,/lmstat/p" $tmptmp_file >> $tmp_file
            @ j ++
        end
    else if ($script_mode == 1) then
        clear
    else if ($script_mode == 3) then
        if ("$lic_use_arrays[$rm_lic]" == 0) then
            echo "$LABEL_ARRAYS[$rm_lic] is available"
            echo "$LABEL_ARRAYS[$rm_lic] : $lic_use_arrays[$rm_lic]/$lic_all_arrays[$rm_lic] (Use/Total)"
            exit(0)
        endif

        echo "lmremove $LABEL_ARRAYS[$rm_lic] : $lic_use_arrays[$rm_lic]/$lic_all_arrays[$rm_lic] (Use/Total)"
        sed -n -e "/Users of $FEAUTURE_ARRAYS[$rm_lic]/,/lmstat/p" $tmptmp_file | \
        sed -e '/lmstat/d' -e '/Users of /d' -e '/mgcld/d' -e '/Analog/d' -e '/LOGIC/d' -e '/float/d' -e "s/    //g" -e '/^$/d' -e '/cds/d' > $menu_file
        bash $menu_choice $menu_file $menu_answer ;#bash menu_choice view calling 
        if ( `cat $menu_answer` == "quit") then
            rm -f $menu_answer $menu_file $tmp_file $tmptmp_file >& /dev/null
            exit(0)
        endif

        set remove_account = `grep "" $menu_answer | sed "s/ /,/g" \
            | awk -F, -v  FEAUTURE_ARRAYS="$FEAUTURE_ARRAYS[$rm_lic]" -v SERVER_ARRAYS="$SERVER_ARRAYS[$rm_lic]" \
              '{print "lmremove -c " SERVER_ARRAYS " " FEAUTURE_ARRAYS " " $1 " " $2 " "$3 }'`
        printf "[CHECK]Do you really want to remove this license? [Press:y/n]\n\033[32m=>$remove_account\033[m\n"
        set answer = $<
        if ($answer == "y") then
            $remove_account
            echo "Removed license"
        else if ($answer == "n") then
            echo "Canceled"
        else
            printf "\033[31mDon't understand : $answer\033[m\n"
        endif
        rm -f $menu_answer $menu_file $tmp_file $tmptmp_file >& /dev/null
        exit(0)
    endif

    set k = 1
    if ($script_mode < 3) then
        echo "$LINE\n#Status of License(Use/Total)\n$LINE"                                        >> $tmp_file
        while ($k <= $#FEAUTURE_ARRAYS)
            grep "${FEAUTURE_ARRAYS[$k]}:" $tmptmp_file | awk '{ print " " $11"/"$6"	: ";}' \
                                                        | sed -e "s/: /: $LABEL_ARRAYS[$k]/g"     >> $tmp_file
            sed -n -e "/Users of $FEAUTURE_ARRAYS[$k]/,/lmstat/p" $tmptmp_file | grep $user       >> $tmp_file
            @ k ++
        end
    endif
    
    sed -i "1i$LINE\n#\n#`date`\n#\n$LINE"  $tmp_file 
    sed -i -e "s/   $user/==>$user/g"  -e '/lmstat/d'       \
           -e '/cdslmd/d'              -e '/mgcld/d'        \
           -e '/float/d'               -e '/vendor/d'       \
           -e "s/Users/\nUsers/g"      -e "s/use)/use)\n/g" \
           -e '/^$/d'                       $tmp_file
    grep --color=auto -e "==>$user"  \
                      -e " $lic_all_arrays[1]/$lic_all_arrays[1]	" \
                      -e " $lic_all_arrays[2]/$lic_all_arrays[2]	" \
                      -e " $lic_all_arrays[3]/$lic_all_arrays[3]	" \
                      -e " $lic_all_arrays[4]/$lic_all_arrays[4]	" \
                      -e " $lic_all_arrays[5]/$lic_all_arrays[5]	" \
                      -e " $lic_all_arrays[6]/$lic_all_arrays[6]	" \
                      -e " $lic_all_arrays[7]/$lic_all_arrays[7]	" \
                      -e " $lic_all_arrays[8]/$lic_all_arrays[8]	" \
                      -e '$' $tmp_file

    rm -f $tmptmp_file $tmp_file $menu_answer $menu_file >& /dev/null
    if ($script_mode == 0) then
        break
    else
        echo "\nExit -> Press[Ctrl + C] \nDisplay update interval : $interval [sec]" 
        sleep $interval
    endif
end
