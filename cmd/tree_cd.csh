#!/bin/csh -f
set base_dir = ~/cmd
set menu_choice = $base_dir/func_menu.sh
set menu_answer        = $base_dir/answer.tmp
set menu_file          = $base_dir/menu.tmp
alias func_menu_choice   'bash $menu_choice $menu_file $menu_answer'
cat >  $menu_choice  << 'EOF'
#!/bin/bash
function menu_choice {
choice=0
IFS=$'\n'
menu=($(cat "$1"))
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
        echo "quit" > $2
        exit 0
    fi
    case $answer in
        "B"|"[B"|"C"|"[B")
        if [ $choice -lt $tail ]; then choice=`expr $choice + 1`; fi
        ;;
        "D"|"[A"|"A"|"[A")
        if [ $choice -gt 0 ]; then choice=`expr $choice - 1`; fi
        ;;
        "")
        echo ${menu[$choice]} > $2
        return
        ;;
    esac
done
}
menu_choice $1 $2

'EOF'

cat << EOF
EOF

#login machine check (whether there is a "tree" command)
set command_check = `which tree >& /dev/null ; echo $status`
if ($command_check > 0) then
    printf "\033[31mThe tree command can't be found \033[m\n"
    printf "\033[31mPlease install tree command\033[m\n"
    exit(0)
endif

#no argument => path = current directory, display depth level = 1
if ($#argv == 0) then
    set argv = ( 1 )
endif
#command + "-h" => help option
if ($#argv == 1 && "$argv[1]" == "-h") then
    cat << EOF
    usage : 'Path'           -> The directory tree in the path is displayed. (Display depth level:1)
    usage : 'Level'          -> Max display depth of the directory tree.
    usage : 'Path' + 'Level' -> The directory tree in the path is displayed. (Display depth level:N)
    Example : command cmd(path)  2(level)
                Choose one       [exit:q]
                cmd
                |-- cmd/function
                |-- cmd/mkcir_relation
              > |-- cmd/old
                |   '-- cmd/old/model_make
                '-- cmd/sankou
   
EOF
    exit(0)
#Function call => func_menu.sh
    func_menu_choice
    set enter = `cat $menu_answer | cut -c 13-`
    if ($enter == "") then
        exit(0)
    else
        cd $enter
        printf "\033[35mCurrent directory\033[m : `pwd`\n"
        rm -f $menu_file $menu_answer >& /dev/null
        exit(0)
    endif
endif
#command + path or level
if ($#argv == 1) then
#Number or character determination
    set str_check = `expr $argv[1] + 1 >& /dev/null ; echo $status`
    if ($str_check == 0) then
        set PASS = '.'
        set hi = "$argv[1]"
    else if ("$argv[1]" == "-") then
        #graphical cd loop
        set LOOP =  1
        while  ($LOOP > 0)
            echo "Chose directory"
            tree -dfiL 1 | sed -e '/director/d' -e '/^$/d' -e 's:^.$:../:g' | awk '{ print $1;}'> $menu_file
	    func_menu_choice
	    set enter = `cat $menu_answer`
            if ($enter == "quit") then
                rm -f $base_dir/*.tmp >& /dev/null
                set LOOP = 0
                exit(0)
            endif
            set set composer = `cat $menu_answer`
            cd $composer ; printf "\033[35mPWD\033[m : `pwd`\n"
            rm -f $base_dir/*.tmp >& /dev/null
        end
        exit(0)
        rm -f $base_dir/*.tmp >& /dev/null
##########################################

    else if (-d $argv[1]) then
        set PASS = `echo $argv[1] | sed 's:/$::g'`
        set hi = 1
    else
        printf "\033[31mERROR : Please enter a valid path.\033[m\n"
        exit(0)
    endif
#command + path + level
else if ($#argv == 2 &&  (-d $argv[1]) ) then
#Number or character determination
    set str_check = `expr $argv[2] + 1 >& /dev/null ; echo $status`
    if ($str_check > 1) then
        printf "\033[31mERROR : $argv[2] is not a number\033[m\n"
        exit(0)
    else
        set PASS = `echo $argv[1] | sed 's:/$::g'`
        set hi = $argv[2]
    endif
else
    printf "\033[31mERROR : Please enter a valid path.\033[m\n"
    exit(0)
endif

#tree command to cd command 
tree $PASS -L $hi -d -f | sed -e '/director/d' -e '/^$/d' > $menu_file
#Function call => func_menu.sh
func_menu_choice
set enter = `cat $menu_answer`
#set more  = `cat $base_dir/answer.tmp | grep -o -e "m"` 
if ("$enter" == "") exit(0)
else if ("$enter" == "$PASS") then
    cd $enter ; printf "\033[35mCurrent Directory\033[m : `pwd`\n"
else
    set enter = `cat $menu_answer | sed -e 's/ //g' -e 's/--/@@/g' -e 's/|//g' | cut -c 3- | sed -e 's/|//g'  -e 's/@//g'`
    cd $enter ; printf "\033[35mCurrent Directory\033[m : `pwd`\n"
endif

