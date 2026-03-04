#!/bin/csh -f
#========== User option ==========#
set install_dir    = ~/cmd
set this_file_name = comp.csh
set output_file    = comp_out.csh
#=================================#

#Local variable
set func_num = 1
set function_file_name = ("$argv[1-$#argv]")

if ($#argv == 0) then
    echo "Error : Not enough arguments"
    exit(0)
endif

touch ./$output_file
chmod 777 ./$output_file
echo "Created -> ./$output_file"
sed -n 1p $install_dir/$this_file_name               > ./$output_file
echo "set install_dir        = ."                   >> ./$output_file
echo "set this_file_name     = $output_file"        >> ./$output_file
echo "set function_file_name = ("$argv[1-$#argv]")" >> ./$output_file
cut -c 2- $install_dir/$this_file_name | awk "/#func_START#/,/#func_END#/" | sed -e "1d" | sed -e "/#func_START#/d" -e "/#func_END#/d" >> ./$output_file

#=========================# Don't touch #=========================#
##func_START#
#echo "The following files are concatenated"
#set func_num = 1
#while ($func_num <= $#function_file_name)
#    printf "No.$func_num : \033[32m$function_file_name[$func_num]\033[m\n"
#    @ func_num ++
#end
#echo "Do you want to unzip in this directory?[y/n]"
#set answer = $<
#switch ("$answer")
#    case "y*" :
#    breaksw
#
#    case "n*" :
#        echo "Canceled"
#        exit(0)
#    breaksw
#
#    default :
#        echo "Don't understand : $answer"
#        exit(0)
#    breaksw
#endsw
#echo "Message :"
#set func_num = 1
#while ($func_num <= $#function_file_name)
#    touch $install_dir/$function_file_name[$func_num]
#    cut -c 2- $install_dir/$this_file_name | awk "/#func_START$func_num/,/#func_END$func_num/" | sed -e "1d" | sed -e "/#func_END$func_num/d" > $install_dir/$function_file_name[$func_num]
#    printf "Created file -> $install_dir/\033[32m$function_file_name[$func_num]\033[m\n"
#    @ func_num ++
#end
##func_END#
#=========================# Don't touch #=========================#

echo "The file concatenation was succsessful"
echo "The following files are contenated"
echo "#=========================# Don't touch #=========================#" >> ./$output_file
while ($func_num <= $#argv)
    echo "##func_START$func_num"              >> ./$output_file
    cat "$argv[$func_num]" | sed -e "s/^/#/g" >> ./$output_file
    echo "##func_END$func_num\n"              >> ./$output_file
    printf "No.$func_num : \033[32m$argv[$func_num]\033[m\n"
    @ func_num ++
end
echo "#=========================# Don't touch #=========================#" >> ./$output_file


echo "Do you see the execution result [Press:y/n/cat]"
set answer = $<
switch ("$answer")
    case "y*" :
        vi ./$output_file
        exit(0)
    breaksw

    case "cat" :
        cat ./$output_file
        exit(0)
    breaksw
    
    case "n*" :
        echo "Canceled"
        exit(0)
    breaksw
    
    default :
        echo "Don't understand : $answer"
        exit(0)
    breaksw
endsw
