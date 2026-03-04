#!/bin/csh -f
set install_dir = /workdata/XCSR/others/Virtuoso_license_check
set interval = 300
set wait_ade_interval = 15
set LIC_S1 = '5280@idcliclxsv'
set LIC_S2 = '1717@10.20.35.208'
set LIC_S3 = '27002@tapt47'

#license token name
set LIC      = (Virtuoso_ADE_Explorer Virtuoso_ADE_Assembler Virtuoso_Schematic_Editor_L Virtuoso_Multi_mode_Simulation afslicense BDA_TOKEN	OASIS_Simulation_Interface )
#license label  ||                    ||                     ||                          ||                             ||         ||           ||                         (Label name is user cuntum)
set LIC_L    = (ADE-Explorer          ADE-Assembler          Schematic_Editor            MMSIM                          AFS        BDA_ASAKA 	OASIS			   )	  
#license sever  ||                    ||                     ||                          ||                             ||         ||		||
set LIC_S    = ($LIC_S1               $LIC_S1                $LIC_S1                     $LIC_S1                        $LIC_S2    $LIC_S3  	$LIC_S1			   )

#============== Don't touch ==============#
#include file
set subfile_name   = func_menu.sh
set this_file_name = Virtuoso_license_check.csh
set tmp_file       = $install_dir/lms.tmp
set tmptmp_file    = $install_dir/lms.tmptmp
set menu_file      = $install_dir/menu.tmp
set answer_file    = $install_dir/answer.tmp
set sub_func       = $install_dir/$subfile_name
#set enviroment
set LINE           = "#=============================================#"
set script_mode    = 0
set LIC_ALL = ($LIC)
set LIC_USE = ($LIC)
#subfile create code (FROM=func_START TO=func_END)
if (!(-f $sub_func))then
    printf "Message :\nCreated file -> $install_dir/\033[32m$subfile_name\033[m\n"
    touch $sub_func
    cut -c 2- $install_dir/$this_file_name | awk "/#func_START/,/#func_END/" | sed -e "1d" | sed -e "/#func_END/d" > $sub_func
    sed -i s:TIKAN_DIR:"$install_dir":g $sub_func
    chmod 777 $sub_func 
endif

if ($#argv == 1) then
#Command Option "-h" => Help menu view (Users Guide)
    if ("$argv[1]" == "-h") then
        cat << EOF
usage : vlic        -> The current license usage status is displayed.
EOF
        exit(0)
#Argument option check (-l or -h or -rm or -w)
    else if ("$argv[1]" != "-l" && "$argv[1]" != "-h" && "$argv[1]" != "-rm" && "$argv[1]" != "-w") then
        printf "\033[31mError : Unknown option : $argv[1]\n        Please refer to the help (-h)\033[m\n"
        exit(0)
#Command "-rm " : License remove mode
    else if ("$argv[1]" == "-rm") then
        echo "$LIC_L" | sed -e "s/ /\n/g" > $tmp_file
       #bash menu view yobidasi 
        cp $tmp_file $menu_file ; bash $sub_func ; set enter = `cat $answer_file`
        if ("$enter" == "quit") then
            rm -f $answer_file $menu_file >& /dev/null
            exit(0)
        endif 

        set i = 1
        while ($i <= $#LIC)
            if ("$enter" == "$LIC_L[$i]") then
                set rm_lic = $i
                break
            else
                @ i ++
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
        set script_mode = 2
        set interval  = $wait_ade_interval
    else
#Loop option Command "-l"
        set script_mode = 1
    endif
#Command "-l N" (N=number)
else if ($#argv == 2) then
#Input Number Judge
    set answer_status = `expr $argv[2] + 1 >& /dev/null ; echo $status`
    if ($answer_status >  1) then
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

while ($#LIC > 0)
    set i = 1 ; set j = 1 ; set k = 1  
    printf "" > $tmptmp_file ; printf "" > $tmp_file
    while ($i <= $#LIC) 
        lmstat -c $LIC_S[$i] -f $LIC[$i]  >> $tmptmp_file
        set LIC_ALL[$i] = `grep "$LIC[$i]" $tmptmp_file | awk '{ print $6;}'`
        set LIC_USE[$i] = `grep "$LIC[$i]" $tmptmp_file | awk '{ print $11;}'`
        @ i ++
    end

#Script mode = 0 => default license view 
    if ($script_mode == 0) then
        while ($j <= $#LIC)
            echo "$LINE\n#$LIC_L[$j]\n$LINE"                       >> $tmp_file
            sed -n -e "/Users of $LIC[$j]/,/lmstat/p" $tmptmp_file >> $tmp_file
            @ j ++
        end

    else if ($script_mode == 1 || $script_mode == 2) then
        clear
        if ($script_mode == 2) then
            echo "Waiting for lisences : $LIC_L[1] $LIC_L[2]"
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
            rm -f $answer_file $menu_file $tmp_file $tmptmp_file >& /dev/null
            exit(0)
        endif

        set lm_account = `grep "" $answer_file | sed "s/ /,/g" | awk -F, -v  LIC="$LIC[$rm_lic]" -v LIC_S="$LIC_S[$rm_lic]" '{print "lmremove -c " LIC_S " " LIC " " $1 " " $2 " "$3 }'`
        printf  "[CHECK]Do you really want to remove this license? [Press:y/n]\n\033[32m=>$lm_account\033[m\n"
        set answer = $<
        if ($answer == "y") then
            $lm_account
            echo "Removed license"
        else if ($answer == "n") then
            echo "Canceled"
        else
            printf "\033[31mDon't understand : $answer\033[m\n"
        endif
        rm -f $answer_file $menu_file $tmp_file $tmptmp_file >& /dev/null
        exit(0)
    endif

    sed -i "1i$LINE\n#\n#`date`\n#\n$LINE" $tmp_file 
    if ($script_mode < 3) then
        echo "$LINE\n#Status of License(Use/Total)\n$LINE"                                                            >> $tmp_file
        while ($k <= $#LIC)
            grep "${LIC[$k]}:" $tmptmp_file | awk '{ print " " $11"/"$6"	: ";}' | sed -e "s/: /: $LIC_L[$k]/g" >> $tmp_file
            sed -n -e "/Users of $LIC[$k]/,/lmstat/p" $tmptmp_file | grep $user                                       >> $tmp_file
            @ k ++
        end
    endif
    
    sed -i -e "s/   $user/==>$user/g"  -e '/lmstat/d' -e '/cdslmd/d' -e '/mgcld/d' -e '/float/d' -e "s/Users/\nUsers/g" -e "s/use)/use)\n/g" -e '/^$/d' $tmp_file
    grep --color=auto -e "==>$user"  -e " $LIC_ALL[1]/$LIC_ALL[1] " -e " $LIC_ALL[2]/$LIC_ALL[2] " -e " $LIC_ALL[3]/$LIC_ALL[3] " -e " $LIC_ALL[4]/$LIC_ALL[4] " -e " $LIC_ALL[5]/$LIC_ALL[5] " -e " $LIC_ALL[6]/$LIC_ALL[6] " -e '$' $tmp_file
    rm -f $tmptmp_file $tmp_file $answer_file $menu_file >& /dev/null
    if ($script_mode == 0) then
        break
    else
        echo "\n\n\nExit -> Press[Ctrl + C] \nDisplay update interval : $interval [sec]"           
        sleep $interval
    endif
end
