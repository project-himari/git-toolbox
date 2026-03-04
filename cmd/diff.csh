#!/bin/csh -f
set rtl = "/workdata/2024/RICHO_CHI_ST4_202407/02_WORK_PARTNER/23_LOGIC/c9kazama/Ghidorah/00_rtl/RTL_250206_A1_comm"
diff $argv[1] $rtl/$argv[1]

echo "Do you read vimdiff?  [y/n]"
echo 'read -sn1 input ; echo $input' > read.tmp
set read = `bash read.tmp ; rm -f read.tmp >& /dev/null`

switch ("$read")
    case "y" :
        vimdiff $argv[1] $rtl/$argv[1]
        exit(0)
    breaksw

    default :
        echo "quit"
        exit(0)
    breaksw
endsw

