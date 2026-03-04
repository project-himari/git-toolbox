#!/bin/tcsh
#=========User define=========#
set path_before  = ./Version2/Design/rtl/hwm
set path_after   = ./SCU_TDC_8th_OOI_20250516/RTL/hwm
set output_file  = ./diff_log.txt
set filemap      = ./filemap.txt
#=============================#

set LINE = '#==============================#'
@ count_same     = 0
@ count_diff     = 0
@ count_add      = 0
@ count_remove   = 0
@ count_missing  = 0
set list_same    = ()
set list_diff    = ()
set list_add     = ()
set list_remove  = ()
set list_missing = ()

if (-f $output_file) rm $output_file
touch $output_file

echo "before_path : $path_before" >> $output_file
echo "after_path  : $path_after"  >> $output_file
echo "before file <-> after_file" >> $output_file
foreach line ("`cat $filemap`")
    set file_before = `echo $line | awk '{print $1}'`
    set file_after  = `echo $line | awk '{print $2}'`

    echo "\n$LINE\n$file_before <-> $file_after\n$LINE" >> $output_file

    if ("$file_before" == "-" && "$file_after" != "-") then
        echo "[add_file] $file_after" >> $output_file
        @ count_add++
        set list_add = ($list_add $file_after)
    else if ("$file_before" != "-" && "$file_after" == "-") then
        echo "[remove_file] $file_before" >> $output_file
        @ count_remove++
        set list_remove = ($list_remove $file_before)
    else if (-f "$path_before/$file_before" && -f "$path_after/$file_after") then
        diff -q "$path_before/$file_before" "$path_after/$file_after" > /dev/null
        if ($status == 0) then
            echo "[no difference]" >> $output_file
            @ count_same++
            set list_same = ($list_same $file_before)
        else
            diff "$path_before/$file_before" "$path_after/$file_after" >> $output_file
            @ count_diff++
            set list_diff = ($list_diff "${file_before}<--->${file_after}")
        endif
    else
        echo "[missing] $file_before or $file_after not found" >> $output_file
        @ count_missing++
        set list_missing = ($list_missing "$file_before <-> $file_after")
    endif
end

  #Summary desplay
  echo "\n\n//--------Summary--------//"                    | tee -a $output_file
  echo "\n$LINE\n#Same files       : $count_same\n$LINE"    | tee -a $output_file
  echo "$list_same"    | sed 's/ /\n/g'                     | tee -a $output_file
  echo "\n$LINE\n#Different files  : $count_diff\n$LINE"    | tee -a $output_file
  echo "#before file <-> after_file"                        | tee -a $output_file
  echo "$list_diff"    | sed 's/ /\n/g'                     | tee -a $output_file
  echo "\n$LINE\n#Added files      : $count_add\n$LINE"     | tee -a $output_file
  echo "$list_add"     | sed 's/ /\n/g'                     | tee -a $output_file
  echo "\n$LINE\n#Removed files    : $count_remove\n$LINE"  | tee -a $output_file
  echo "$list_remove"  | sed 's/ /\n/g'                     | tee -a $output_file
  echo "\n$LINE\n#Missing files    : $count_missing\n$LINE" | tee -a $output_file
  echo "$list_missing" | sed 's/ /\n/g'                     | tee -a $output_file
  
  echo "[Message] For more details, please refer to ${output_file} . "
