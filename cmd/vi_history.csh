#!/bin/csh -f
#vi command log save directory (Default:~/cmd)
set install_dir = ~/cmd
#max_log(default:10)
set max_log = 15

if ( !(-f $install_dir/vi_history.list) ) then
    touch $install_dir/vi_history.list
    echo "Message :\nCreated -> $install_dir/vi_history.list"
endif

#Time stamp & vi history
echo `date "+%Y %m/%d %H:%M"`" "`pwd`  >> $install_dir/vi_history.list
#If there is the same history, those histories are stacked.
sort -r -k 4,4 -t " " $install_dir/vi_history.list | uniq -f 3 -c | cut -c 9- | sort -n -o $install_dir/vi_history.list
set count_log = `wc -l $install_dir/vi_history.list | sed -e s:$install_dir/vi_history.list::g`
#If the number of "log_count" is greater than "max_log", delete "log_count" until "log_count" = "max_log"
if ($count_log > $max_log) then
    setenv LOOP 1
    while ($LOOP > 0)
        set count_log = `wc -l $install_dir/vi_history.list | sed -e s:$install_dir/vi_history.list::g`
        if ($count_log == $max_log) then
            break
        else
            sed -i -e "1d" $install_dir/vi_history.list
        endif
    end
endif
