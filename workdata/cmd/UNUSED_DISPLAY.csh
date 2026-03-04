#!/bin/csh -f
set USE_ALL = `ls /tmp/.X11-unix | sed -e 's/[^0-9]//g'`
set USE = ( )
foreach i ( $USE_ALL ) 
    if ( $i < 1000) then
        set USE = ( $USE $i)
    endif
end

set i = 0
while ( $i <= 100 )
    set USE = ( $USE  $i )
    @ i ++
end
#echo $USE | sed -e "s/ /\n/g" | sort -n | uniq -u
set UNUSED = `echo $USE | sed -e "s/ /\n/g" | sort -n | uniq -u`
echo "There are $#UNUSED unused display numbers"
echo "USE OK DISPLAY NUMBER :\n $USE"
