#!/bin/csh -f
set install_dir = ~/cmd
set function_file_name = $install_dir/func_menu.sh
set tmp_file           = $install_dir/lms.tmp
set new_env_user = c9kazama

#========menu==========#
#AP
#echo ap1x005      >  $tmp_file
#echo ap1x006     >> $tmp_file
echo ap1x008     > $tmp_file
echo ap1x009     >> $tmp_file
echo ap1x010     >> $tmp_file
echo ap1x011     >> $tmp_file
echo ap1x012     >> $tmp_file
echo ap1x013     >> $tmp_file
echo ap1x014     >> $tmp_file
echo ap1x015     >> $tmp_file
#FO
echo 10.91.29.83 >> $tmp_file
#HO
echo 10.81.33.73 >> $tmp_file
#OTHER
echo tapwsfs01   >> $tmp_file
echo tfoauth02v  >> $tmp_file
#NEW_SERVER
echo ap1x100     >> $tmp_file
echo ap1x101     >> $tmp_file
echo ap1x102     >> $tmp_file
echo ap1x103     >> $tmp_file
echo tkosv500     >> $tmp_file
echo tkosv501     >> $tmp_file

#========menu==========#


cp $tmp_file $install_dir/menu.tmp
bash $function_file_name $install_dir/menu.tmp $install_dir/answer.tmp

set enter = `cat $install_dir/answer.tmp`
if ("$enter" == "quit") then
    rm -f $install_dir/*.tmp >& /dev/null
    exit(0)
endif

#OLD_ENV LOGIN
if ($#argv == 0) then
    ssh $enter
#NEW_ENV LOGIN
else if ("$argv[1]" == "-l") then
    ssh $enter -l $new_env_user
#ROOT_ENV LOGIN
else if ("$argv[1]" == "-r") then
    if ($enter == "ap1x005") then
        echo "linsm_2013"
    else if ($enter == "ap1x006") then
        echo "linsm_2013"
    else if ($enter == "ap1x008") then
        echo "redsm_2013"
    else if ($enter == "ap1x009") then
        echo "redsm_2014"
    else if ($enter == "ap1x010") then
        echo "a010_2015"
    else if ($enter == "ap1x011") then
        echo "a011_2015"
    else if ($enter == "ap1x012") then
        echo "a012_2015"
    else if ($enter == "ap1x013") then
        echo "a013_2017"
    else if ($enter == "ap1x014") then
        echo "a014_2017"
    else if ($enter == "ap1x015") then
        echo "p_2019"
    else if ($enter == "tapwsfs01") then
        echo "p_2016"
    else if ($enter == "tfoauth02v") then
        echo "1-5-1t"
    endif
    ssh $enter -l root
else
    echo "Error"
    exit(0)
endif
#Tdc_linux_2_5
