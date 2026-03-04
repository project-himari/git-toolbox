#!/bin/csh -f
set now_lang = `setenv | grep LANG`
printf "Now language : \033[35m$now_lang\033[m\n" 
printf "\033[32mChoose language\033[m\n"
cat << EOF
==============Select================
1 : English  (LANG="C")
2 : Japanese (LANG="ja_JP.eucJP")
3 : Japanese (LANG="ja_JP.UTF8")
4 : English  (LANG="en_US.UTF-8")
q : quit
====================================
EOF

echo 'read -sn1 input ; echo $input' > read.tmp
set read = `bash read.tmp ; rm -f read.tmp >& /dev/null`

switch ("$read")
    case "1" :
        setenv LANG "C"
        printf "Language settings changed : \033[35mEnglish\033[m\n"
        exit(0)
    breaksw

    case "2" :
        setenv LANG "ja_JP.eucJP"
        #printf "ÀßÄê¸À¸ì¤¬ÊÑ¹¹¤µ¤ì¤Þ¤·¤¿: \033[35mÆüËÜ¸ì\033[m\n"
        #Unicode
        printf "\u8A00\u8A9E\u8A2D\u5B9A\u304C\u5909\u66F4\u3055\u308C\u307E\u3057\u305F : \033[35m\u65E5\u672C\u8A9E\033[m\n"
   exit(0)
   case "3" :
        setenv LANG "ja_JP.UTF-8"
        #printf "ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ì¤¬ï¿½Ñ¹ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Þ¤ï¿½ï¿½ï¿½: \033[35mï¿½ï¿½ï¿½Ü¸ï¿½\033[m\n"
        #Unicode
        printf "\u8A00\u8A9E\u8A2D\u5B9A\u304C\u5909\u66F4\u3055\u308C\u307E\u3057\u305F : \033[35m\u65E5\u672C\u8A9E\033[m\n"
   exit(0)
      case "4" :
        setenv LANG "en_US.UTF-8"
        #Unicode
        printf "Language settings changed : \033[35mEnglish\033[m\n"
   exit(0)

    breaksw

    default :
        echo "quit"
        exit(0)
    breaksw
endsw
