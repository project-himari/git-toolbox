#!/bin/csh -f
#cd command log save directory (Default:~/cmd)
set install_dir = ~/cmd
set cd_history  = $install_dir/cd_history.list
set cd_history_bk  = $install_dir/cd_history_bk.list
#max_log(default:10)
set max_log = 15
set max_log_bk = 50
if ( !(-f $cd_history) ) then
    touch $cd_history
    touch $cd_history_bk
    echo "Message :\nCreated -> $cd_history"
endif

#Time stamp & cd history
echo `date "+%Y %m/%d %H:%M"`" "`pwd`  >> $cd_history
#If there is the same history, those histories are stacked.
sort -r -k 4,4 -t " " $cd_history | uniq -f 3 -c | cut -c 9- | sort -n -o $cd_history
set count_log = `wc -l $cd_history | sed -e s:${cd_history}::g`
#If the number of "log_count" is greater than "max_log", delete "log_count" until "log_count" = "max_log"
if ($count_log > $max_log) then
    setenv CD_LOOP 1
    while ($CD_LOOP > 0)
        set count_log = `wc -l  $cd_history | sed -e s:${cd_history}::g`
        if ($count_log == $max_log) then
            break
        else
            sed -i -e "1d" $cd_history
        endif
    end
endif


#ADD
echo `date "+%Y %m/%d %H:%M"`" "`pwd`  >> $cd_history_bk
set count_log_bk = `wc -l $cd_history_bk | sed -e s:${cd_history_bk}::g`
if ($count_log_bk > $max_log_bk) then
    setenv CD_LOOP 1
    while ($CD_LOOP > 0)
        set count_log_bk = `wc -l  $cd_history_bk | sed -e s:${cd_history_bk}::g`
        if ($count_log_bk == $max_log_bk) then
            break
        else
            sed -i -e "1d" $cd_history_bk
        endif
    end
endif

