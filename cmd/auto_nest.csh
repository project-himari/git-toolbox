#!/bin/csh -f
#last update 2020/12/10 ver2.0 (kazama)
#========== User Option ==========#
#Output file name
set output_file = "nest_out.csh"
set nest_plus_word = ( if case default switch while for )
set nest_minus_word = ( breaksw end fi esac done )
set nest_keep_word = ( else elif )
set one_line_end_word  = ( fi$ endif$ done$ end$ esac$ breaksw$ )
#=================================#
set input_file = "$argv[1]"
if ($#argv == 0) then
    echo "Error : Not enough arguments"
    exit(0)
#Overwrite option "-i"
else if ("$argv[1]" == "-i" && $#argv == 2) then
    cp $argv[2] $argv[2]_org
    set output_file = $argv[2]
    set input_file = $argv[2]
endif

sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' -e 's/ /__SPACE__/g' -e 's/\\/__SLASH__/g' -e 's/{/curly_braces1/g' -e 's/}/curly_braces2/g'  $input_file > ./check.tmp
printf "" > $output_file
set FILE = "check.tmp"
set nest_count = 0
set rate_dis = 0 
set locali = 1
set localN = `wc -l $FILE | awk '{print $1}'`
@ rate_par = $localN / 10 
@ rate_flag = $rate_par

while ($locali <= $localN)
    set line = `head -n $locali $FILE | tail -n 1`
    set nest_flag = `echo "$line" | grep -o -e "^if" -e "^case" -e "^default" -e "^switch" -e "^while" -e "^done" -e "^for" -e "^breaksw" -e "^end" -e "^fi"  -e "^es" -e "^el" -e "^#" -e "^EOF" | wc -c`
    if ($locali == $rate_flag && $rate_dis != 100) then
        @ rate_dis  = $rate_dis + 10
        @ rate_flag = $rate_flag + $rate_par
        echo "Progress rate : $rate_dis [%]"
    endif

    if ("$nest_flag" > 1) then
#Keywords that lower nesting : case/if/default/switch/while/for/else 
       #set nest_plus  = `echo "$line" | grep -o -e "^if" -e "^case" -e "^default" -e "^switch" -e "^while"  -e "^for" | wc -c`
        set nest_plus  = `echo "$line" | grep -o -e "^" -e "^case" -e "^default" -e "^switch" -e "^while"  -e "^for" | wc -c`
        if ("$nest_plus" > 1) then
#Keywords for one line : if~;fi if~;endif while do;~;done etc.
            set one_line_end_flag = `echo "$line" | grep -o -e 'fi$' -e 'endif$' -e 'done$' -e 'end$' -e 'esac$' -e 'breaksw$' | wc -c`
            set nest_repeat = `repeat $nest_count printf "__NEST__"`
            echo "$nest_repeat$line" >> $output_file
            if ($one_line_end_flag < 2) then
                @ nest_count ++
            endif
        else
#Keywords that raise nesting : breaksw/end/fi/esac/done
            set nest_minus = `echo "$line" | grep -o -e "^breaksw" -e "^end" -e"^fi" -e "^esac" -e "^done" | wc -c`
            if ("$nest_minus" > 1) then
                if ($nest_count != 0) then
                    @ nest_count --
                endif
                set nest_repeat = `repeat $nest_count printf "__NEST__"`
                echo "$nest_repeat$line" >> $output_file
            else
#Keywords that keep nesting : el* (else/elif)
                set nest_else  = `echo "$line" | grep -o -e "^el" | wc -c`
                if ("$nest_else" > 1) then
                    @ else_count = $nest_count - 1
                    set nest_repeat = `repeat $else_count printf "__NEST__"`
                    echo "$nest_repeat$line" >> $output_file
                else
#Keywords not insert the nest : EOF/#(comment out)
                    echo "$line" >> $output_file
                endif
            endif
        endif
    else
        set nest_repeat = `repeat $nest_count printf "__NEST__"`
        echo "$nest_repeat$line" >> $output_file
    endif
    @ locali ++
end

rm -f $FILE >& /dev/null
sed -i -e 's/__SLASH__/\\/g'\
       -e 's/__SPACE__/ /g'\
       -e 's/__NEST__/    /g'\
       -e 's/curly_braces1/{/g'\
       -e 's/curly_braces2/}/g'\
       $output_file

echo "The conversion is complete."
echo "Do you want to confirm the execution result? [Press:y/n/Enter]"
set answer = $<
if ($answer == "y" || $answer == "") then
    vi $output_file
else if ($answer == "n") then
    echo "Canceled"
else
    echo "Don't understand : $answer"
endif

unset output_file
unset input_file
unset FILE
unset nest_count
unset rate_dis
unset locali
unset localN
unset line
unset nest_flag
unset nest_plus
unset one_line_end_flag
unset nest_repeat
unset nest_minus
unset nest_else

