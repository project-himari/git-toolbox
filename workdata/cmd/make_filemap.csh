#!/bin/tcsh -f
#=========User define=========#
set path_before  = rtl_asic/
set path_after   = rtl_fpga


set output_file  = list.txt
set list_before  = list_before.txt
set list_after   = list_after.txt


find $path_before/ -maxdepth 1 -type f -exec basename {} \; | sort > $list_before
find $path_after/  -maxdepth 1 -type f -exec basename {} \; | sort > $list_after
diff -y $list_before $list_after
