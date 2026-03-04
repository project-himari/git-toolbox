$lm_account
0/1   : ADE-Assembler
0/4   : OASIS
0/6   : BDA_ASAKA
10/18 : MMSIM
12/16 : ADE-Explorer
20/32 : AFS
2022Ç¯  8·î 18Æü ²ÐÍËÆü 15:19:39 JST
7/12  : Schematic_Editor
@ i ++
@ i ++
@ j ++
@ k ++
Display update interval : 300 [sec]
EOF
Exit -> Press[Ctrl + C]
If any license is available, it will automatically grab the license and start viva.
Status of License(Use/Total)
break
break
break
cat << EOF
chmod 777 $sub_func 
clear
cp $tmp_file $menu_file ; bash $sub_func ; set enter = `cat $answer_file`
cp $tmp_file $menu_file ; bash $sub_func ; set enter = `cat $answer_file`
cut -c 2- $install_dir/$this_file_name | awk "/#func_START/,/#func_END/" | sed -e "1d" | sed -e "/#func_END/d" > $sub_func
echo "$LIC_L" | sed -e "s/ /\n/g" > $tmp_file
echo "$LINE\n#$LIC_L[$j]\n$LINE"                       >> $tmp_file
echo "$LINE\n#Status of License(Use/Total)\n$LINE"                                                            >> $tmp_file
echo "$LINE\n#\n#`date`\n#\n$LINE"                           
echo "Canceled"
echo "Removed license"
echo "Waiting for lisences : $LIC_L[1] $LIC_L[2]"
echo "\n\n\nExit -> Press[Ctrl + C] \nDisplay update interval : $interval [sec]"           
echo "lmremove $LIC_L[$rm_lic] : $LIC_USE[$rm_lic]/$LIC_ALL[$rm_lic] (Use/Total)"
else
else
else
else
else if ("$argv[1]" != "-l" && "$argv[1]" != "-h" && "$argv[1]" != "-rm" && "$argv[1]" != "-w") then
else if ("$argv[1]" == "-l") then
else if ("$argv[1]" == "-rm") then
else if ("$argv[1]" == "-w") then
else if ($#argv == 2) then
else if ($#argv > 2) then
else if ($answer == "n") then
else if ($script_mode == 1 || $script_mode == 2) then
else if ($script_mode == 3) then
end
end
end
end
end
endif
endif
endif
endif
endif
endif
endif
endif
endif
endif
endif
endif
endif
endif 
ex.  vlic -l 60  -> Display update interval 60 sec
exit(0)
exit(0)
exit(0)
exit(0)
exit(0)
exit(0)
exit(0)
exit(0)
grep "${LIC[$k]}:" $tmptmp_file | awk '{ print " " $11"/"$6"	: ";}' | sed -e "s/: /: $LIC_L[$k]/g" >> $tmp_file
grep --color=auto -e "==>$user"  -e " $LIC_ALL[1]/$LIC_ALL[1] " -e " $LIC_ALL[2]/$LIC_ALL[2] " -e " $LIC_ALL[3]/$LIC_ALL[3] " -e " $LIC_ALL[4]/$LIC_ALL[4] " -e " $LIC_ALL[5]/$LIC_ALL[5] " -e " $LIC_ALL[6]/$LIC_ALL[6] " -e '$' $tmp_file
if (!(-f $sub_func))then
if ("$argv[1]" == "-h") then
if ("$enter" == "$LIC_L[$i]") then
if ("$enter" == "quit") then
if ("$enter" == "quit") then
if ($#argv == 1) then
if ($LIC_ALL[1] > $LIC_USE[1] || $LIC_ALL[2] > $LIC_USE[2]) then
if ($answer == "y") then
if ($answer_status >  1) then
if ($script_mode < 3) then
if ($script_mode == 0) then
if ($script_mode == 0) then
if ($script_mode == 2) then
if ($vlic_check > 0) then
lmstat -c $LIC_S[$i] -f $LIC[$i]  >> $tmptmp_file
printf  "[CHECK]Do you really want to remove this license? [Press:y/n]\n\033[32m=>$lm_account\033[m\n"
printf "" > $tmptmp_file ; printf "" > $tmp_file
printf "Message :\nCreated file -> $install_dir/\033[32m$subfile_name\033[m\n"
printf "\033[31mDon't understand : $answer\033[m\n"
printf "\033[31mError : "$argv[2]" is not a number\n        Please refer to the help (-h)\033[m\n"
printf "\033[31mError : Product enviroment file(cshrc****) is not sourced.\033[m\n"
printf "\033[31mError : Too many argments\n        Please refer to the help (-h)\033[m\n"
printf "\033[31mError : Unknown option : $argv[1]\n        Please refer to the help (-h)\033[m\n"
printf "\033[31mPlease make sure that the enviroment(cshrc****) is set up.\033[m\n"
rm -f $answer_file $menu_file $tmp_file $tmptmp_file >& /dev/null
rm -f $answer_file $menu_file $tmp_file $tmptmp_file >& /dev/null
rm -f $answer_file $menu_file >& /dev/null
rm -f $tmptmp_file $tmp_file $answer_file $menu_file >& /dev/null
sed -i -e "s/   $user/==>$user/g"  -e '/lmstat/d' -e '/cdslmd/d' -e '/mgcld/d' -e '/float/d' -e "s/Users/\nUsers/g" -e "s/use)/use)\n/g" -e '/^$/d' $tmp_file
sed -i -e '/lmstat/d' -e '/Users of /d' -e '/mgcld/d' -e '/Analog/d' -e '/Virtuoso/d' -e '/float/d' -e "s/    //g" -e '/^$/d' $tmp_file
sed -i s:TIKAN_DIR:"$install_dir":g $sub_func
sed -n -e "/Users of $LIC[$j]/,/lmstat/p" $tmptmp_file >> $tmp_file
sed -n -e "/Users of $LIC[$k]/,/lmstat/p" $tmptmp_file | grep $user                                       >> $tmp_file
sed -n -e "/Users of $LIC[$rm_lic]/,/lmstat/p" $tmptmp_file  > $tmp_file
set LIC      = (Virtuoso_ADE_Explorer Virtuoso_ADE_Assembler Virtuoso_Schematic_Editor_L Virtuoso_Multi_mode_Simulation afslicense BDA_TOKEN	OASIS_Simulation_Interface )
set LIC_ALL = ($LIC)
set LIC_ALL[$i] = `grep "$LIC[$i]" $tmptmp_file | awk '{ print $6;}'`
set LIC_L    = (ADE-Explorer          ADE-Assembler          Schematic_Editor            MMSIM                          AFS        BDA_ASAKA 	OASIS			   )	  
set LIC_S    = ($LIC_S1               $LIC_S1                $LIC_S1                     $LIC_S1                        $LIC_S2    $LIC_S3  	$LIC_S1			   )
set LIC_S1 = '5280@idcliclxsv'
set LIC_S2 = '1717@10.20.35.208'
set LIC_S3 = '27002@tapt47'
set LIC_USE = ($LIC)
set LIC_USE[$i] = `grep "$LIC[$i]" $tmptmp_file | awk '{ print $11;}'`
set LINE           = "#=============================================#"
set answer = $<
set answer_file    = $install_dir/answer.tmp
set answer_status = `expr $argv[2] + 1 >& /dev/null ; echo $status`
set i = 1
set i = 1 ; set j = 1 ; set k = 1  
set install_dir = /workdata/XCSR/others/Virtuoso_license_check
set interval  = $wait_ade_interval
set interval = "$argv[2]"    
set interval = 300
set lm_account = `grep "" $answer_file | sed "s/ /,/g" | awk -F, -v  LIC="$LIC[$rm_lic]" -v LIC_S="$LIC_S[$rm_lic]" '{print "lmremove -c " LIC_S " " LIC " " $1 " " $2 " "$3 }'`
set menu_file      = $install_dir/menu.tmp
set rm_lic = $i
set script_mode    = 0
set script_mode = 1
set script_mode = 1
set script_mode = 2
set script_mode = 3
set sub_func       = $install_dir/$subfile_name
set subfile_name   = func_menu.sh
set this_file_name = Virtuoso_license_check.csh
set tmp_file       = $install_dir/lms.tmp
set tmptmp_file    = $install_dir/lms.tmptmp
set vlic_check = `which viva >& /dev/null ; echo $status`
set wait_ade_interval = 15
sleep $interval
touch $sub_func
usage : vlic        -> The current license usage status is displayed.
usage : vlic -l     -> Keep updating the license display at regular intervals(Loop option)
usage : vlic -l N   -> Set the update interval of Display of loop option to an arbitrary time(N=number)
usage : vlic -rm    -> License remove mode
usage : vlic -w     -> License wait mode
viva -64 &
while ($#LIC > 0)
while ($i <= $#LIC)
while ($i <= $#LIC) 
while ($j <= $#LIC)
while ($k <= $#LIC)
