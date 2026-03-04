#func_START
#!/bin/bash
function menu {
choice=0
IFS=$'\n'
menu=($(cat /workdata/XCSR/others/Virtuoso_license_check/menu.tmp))
tail=`expr ${#menu[@]} - 1`
printf "\e[32mChoose one       [exit:q]\e[m\n"  >&2
for _ in $(seq 0 $tail);do echo ""; done

while true; do
    printf "\e[${#menu[@]}A\e[m" >&2

    for i in $(seq 0 $tail); do
        if [ $choice = $i ]; then
            printf "\e[1;31m>\e[m \e[1;4m" >&2
        else
            printf "  " >&2
        fi
        printf "${menu[$i]}\e[m\n" >&2
    done

    read -sn1 answer
    if [ "$answer" = "^[" ]; then
        read -sn2 answer
    elif [ "$answer" = "q" ]; then
        echo "quit" > /workdata/XCSR/others/Virtuoso_license_check/answer.tmp
        exit 0
    fi
    case $answer in
        "B"|"[B")
        if [ $choice -lt $tail ]; then choice=`expr $choice + 1`; fi
        ;;
        "C"|"[B")
        if [ $choice -lt $tail ]; then choice=`expr $choice + 1`; fi
        ;;
        "D"|"[A")
        if [ $choice -gt 0 ]; then choice=`expr $choice - 1`; fi
        ;;
        "A"|"[A")
        if [ $choice -gt 0 ]; then choice=`expr $choice - 1`; fi
        ;;
        "")
        echo ${menu[$choice]} > /workdata/XCSR/others/Virtuoso_license_check/answer.tmp
        return
        ;;
    esac
done
}
menu
