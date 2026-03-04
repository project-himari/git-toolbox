#!/bin/csh -f
set install_dir = ~/cmd
set function_file_name = $install_dir/func_menu.sh
set tmp_file           = $install_dir/lms.tmp
set new_env_user = c9kazama

#menu
#AP
echo ap1x005 >  $tmp_file
echo ap1x006 >> $tmp_file
echo ap1x008 >> $tmp_file
echo ap1x009 >> $tmp_file
echo ap1x010 >> $tmp_file
echo ap1x011 >> $tmp_file
echo ap1x012 >> $tmp_file
echo ap1x013 >> $tmp_file
echo ap1x014 >> $tmp_file
echo ap1x015 >> $tmp_file
#FO
echo 10.91.29.83 >> $tmp_file
#HO
echo 10.81.33.73 >> $tmp_file

cp $tmp_file $install_dir/menu.tmp
bash $function_file_name

set enter = `cat $install_dir/answer.tmp`
if ("$enter" == "quit") then
    rm -f $install_dir/answer.tmp $install_dir/menu.tmp >& /dev/null
    exit(0)
endif

if ($#argv == 0) then
    ssh $enter
else if ("$argv[1]" == "-l") then
    ssh $enter -l $new_env_user
else if ("$argv[1]" == "-r") then
    if ($enter == "ap1x005") then
        echo "linsystem_2013"
    else if ($enter == "ap1x006") then
        echo "linsystem_2013"
    else if ($enter == "ap1x008") then
        echo "redsystem_2013"
    else if ($enter == "ap1x009") then
        echo "redsystem_2014"
    else if ($enter == "ap1x010") then
        echo "admin010_2015"
    else if ($enter == "ap1x011") then
        echo "admin011_2015"
    else if ($enter == "ap1x012") then
        echo "admin012_2015"
    else if ($enter == "ap1x013") then
        echo "admin013_2017"
    else if ($enter == "ap1x014") then
        echo "admin014_2017"
    else if ($enter == "ap1x015") then
        echo "password_2019"
    else if ($enter == "tapwsfs01") then
        echo "password_2016"
    else if ($enter == "tfoauth02v") then
        echo "1-5-1taito"
    endif
    
    ssh $enter -l root
    
    
else
    echo "Error"
    exit(0)
endif
