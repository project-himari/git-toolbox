#!/bin/csh
#Usage :
#(1)user full-customize mode
#   command : source tof_exp_maker.csh XX.csv 
#             or
#(2)full_combination mode 
#   command : source foreach_exp.csh 
#========================================================================#    
# User Setting
#========================================================================# 
#[ COMMON_SETTING ]#
set CHECK_DPD = OFF   ;#ON or OFF  (If CHECK_DPD=ON then maximum priority) 
set BINNING   = OFF   ;#ON or OFF
set INVERT    = OFF   ;#ON or OFF  (If INVERT=ON then invert exp 000=>FFF)
#[ ROW_SETTING ]#
set VROI      = FULL  ;#ALL,      FULL,     HALF,       LINE
                       #ROW=1~488,ROW=3~486,ROW=123~366,ROW=223~266
set TAP       = 4     ;#3 or 4
set VTEMP_EN  = ON    ;#ON or OFF (first 4line enable or disable)
#[ COLUMN_SETTING ]#
set OB_EN     = ON    ;#OFF or 5 or 20
set TEMP_EN   = ON    ;#ON or OFF 
set DUMMY_EN  = ON ;#ON or OFF
rm -f $argv[1]_ROW $argv[1]_ROI $argv[1]_tmp >& /dev/null
#set ANALOG_NO = 12
#========================================================================#    
#Developer INPUT_DATA
#========================================================================#    
set INVERT_HEX  = "./Python/INVERT_HEX.py"
set INFO_GX     = "./INFO_GX_LINE.csv" #1~1952 cols
#========================================================================#    
#For full_combination_mode ( Using foreach_exp.csh )
#========================================================================#    
if ($#argv > 1) then
    set ANALOG_NO = $argv[2] ;#1,2,3,4,8,9,10,11,12,13,17,18
    if ($#argv > 2 ) then
        set TAP       = $argv[3]   
        set VTEMP_EN  = $argv[4]   
        set VROI      = $argv[5] 
        set INVERT    = $argv[6] 
    endif
endif

set COL_MODE = ( $BINNING  $CHECK_DPD   $DUMMY_EN   $TEMP_EN  $OB_EN   )
if ($ANALOG_NO == 1) then
                    #BINNING, CHECK_DPD, DUMMY_EN,       TEMP_EN, OB_EN
    set COL_MODE = ( OFF      OFF        OFF             OFF      OFF   )
else if ($ANALOG_NO == 2) then
    set COL_MODE = ( OFF      OFF        OFF             OFF      5     )
else if ($ANALOG_NO == 3) then
    set COL_MODE = ( OFF      OFF        OFF             ON       OFF   )
else if ($ANALOG_NO == 4) then
    set COL_MODE = ( OFF      OFF        OFF             ON       5     )
else if ($ANALOG_NO == 8) then 
    set COL_MODE = ( OFF      OFF        ON              ON       5     )
else if ($ANALOG_NO == 9) then
    set COL_MODE = ( ON       OFF        OFF             OFF      OFF   )
else if ($ANALOG_NO == 10) then
    set COL_MODE = ( ON       OFF        OFF             OFF      5     )
else if ($ANALOG_NO == 11) then
    set COL_MODE = ( ON       OFF        OFF             ON       OFF   )
else if ($ANALOG_NO == 12) then
    set COL_MODE = ( ON       OFF        OFF             ON       5    )
else if ($ANALOG_NO == 13) then
    set COL_MODE = ( OFF      ON         OFF             OFF      OFF   )
else if ($ANALOG_NO == 17) then
    set COL_MODE = ( ON       OFF        OFF             OFF      20    )
else if ($ANALOG_NO == 18) then
    set COL_MODE = ( ON       OFF        OFF             ON       20   )
endif 
set BINNING        = "$COL_MODE[1]"
set CHECK_DPD      = "$COL_MODE[2]"
set DUMMY_EN       = "$COL_MODE[3]"
set TEMP_EN        = "$COL_MODE[4]"
set OB_EN          = "$COL_MODE[5]"

#Measures for impossible setting
if ($DUMMY_EN == "ON") then
    set OB_EN   = 5
    set TEMP_EN = ON
endif
if ($CHECK_DPD == "ON") then
    set VTEMP_EN = OFF
endif

#==========================================#
#SETTING DISPLAY
#==========================================#
echo "\n[ ROW_SETTING ]" 
echo "--------------------------------------------"
echo "BINNING	|DPD	|TAP	|VROI 	 |VTEMP_INFO_EN" 
echo "--------------------------------------------"
echo "$BINNING	|$CHECK_DPD	|$TAP	|$VROI	 |$VTEMP_EN"
echo "--------------------------------------------"
echo "\n[ COLUMN_SETTING ]" 
echo "--------------------------------------------"
echo "BINNING	|DPD	|DUMMY	|TEMP	|OB"
echo "--------------------------------------------"
echo "$BINNING	|$CHECK_DPD	|$DUMMY_EN	|$TEMP_EN	|$OB_EN"
echo "--------------------------------------------"
echo "INVERT_EXP = $INVERT"
#==========================================#
#ROW PROCESSING
#==========================================#
#==========================================#
#1-1. VROI - ROW (In:$argv[1], Out:**_ROI)
#==========================================#
if ("$CHECK_DPD" == "OFF") then
    if      ("$VROI" == "ALL") then
        set PIX_start = 1
        set PIX_end   = 488
    else if ("$VROI" == "FULL") then
        set PIX_start = 3
        set PIX_end   = 486
    else if ("$VROI" == "HALF") then
        set PIX_start = 123
        set PIX_end   = 366
    else if ("$VROI" == "LINE") then
        set PIX_start = 223
        set PIX_end   = 266
    endif
    @ PIX_start_Q = $PIX_start * 4 - 3
    @ PIX_end_Q   = $PIX_end   * 4
    sed -n "$PIX_start_Q","$PIX_end_Q"p $argv[1] > $argv[1]_ROI
#==========================================#
#1-2. DPD_MODE - ROW (In:$argv[1], Out:**_ROI)
#==========================================#
else if ("$CHECK_DPD" == "ON") then 
    set DPD_LINE = ( `seq 358 32 966` `seq 982 32 1590` )
    foreach PICK_LINE ($DPD_LINE)
        sed -n "${PICK_LINE}p" $argv[1] >> $argv[1]_ROI
    end
endif

#==========================================#
#2. BINNING - ROW
#==========================================#
if ($BINNING == "ON") then
    if ($VROI == "ALL" ) then
        set SEL_CNT = 1 
    else
        set SEL_CNT = 3
    endif
    set LINE_CNT   = 0 ;# Initialize line counter
    set INC        = 5 ;# Initial INC
    @ PTN_CNT = ($SEL_CNT - 1) % 5
    foreach OUTPUT_LINE ("`cat $argv[1]_ROI`")
        @ LINE_CNT++
        if ($LINE_CNT == $SEL_CNT) then
            echo $OUTPUT_LINE >> $argv[1]_tmp
            @ PTN_CNT++
            if ($PTN_CNT == 4) then
                @ SEL_CNT += 1
                @ PTN_CNT = 0
            else
                @ SEL_CNT += $INC
            endif
        endif
    end
else
    cp $argv[1]_ROI $argv[1]_tmp
endif
#==========================================#
#3. TAP_SELECT - ROW
#==========================================#
if ($TAP == 3 && $CHECK_DPD == "OFF") then
    if ($VROI == "ALL") then
        set SKIP_CNT = 0
    else if ($BINNING == "ON" && $VROI != "ALL" ) then
        set SKIP_CNT = 2
    else if ($VROI == "FULL" || $VROI == "HALF" || $VROI == "LINE") then
        set SKIP_CNT = 0 
    endif
    
    set LINE_CNT  = 0
    foreach OUTPUT_LINE ("`cat $argv[1]_tmp`")
        @ LINE_CNT++
        @ SKIP_CNT++
        if ($SKIP_CNT == 4) then
            set SKIP_CNT = 0 ;#Reset SKIP_CNT
        else
            echo $OUTPUT_LINE >> $argv[1]_ROW
        endif
    end
else 
    cp $argv[1]_tmp $argv[1]_ROW
endif
cat $argv[1]_ROW |awk -F, 'BEGIN {OFS=FS} {$1=$2=""; sub(",,", ""); print}' > $argv[1]_DEL
#==========================================#
#4. INFO_VTEMP_EN - ROW
#==========================================#
rm $INFO_GX -f
set FLAME_INFO = 0
if ($VTEMP_EN == "ON") then
    set Q1_TEMP_INFO = `repeat 670 printf "XXX,"`
    set Q2_TEMP_INFO = ","
    set Q3_TEMP_INFO = `repeat 670 printf "FFF,"`
    set Q4_TEMP_INFO = `repeat 670 printf "000,"`
    echo "__LINE1__"  > $INFO_GX 
    echo "__LINE2__" >> $INFO_GX 
    echo "__LINE3__" >> $INFO_GX 
    echo "__LINE4__" >> $INFO_GX 
    if ($BINNING == "OFF") then
        if ($TAP == 4) then
            sed -i -e 1i$Q4_TEMP_INFO $argv[1]_DEL
            sed -i -e 1i$Q3_TEMP_INFO $argv[1]_DEL
            sed -i -e 1i$Q2_TEMP_INFO $argv[1]_DEL
            sed -i -e 1i$Q1_TEMP_INFO $argv[1]_DEL
            set FLAME_INFO = 4
        else if ($TAP == 3) then
            sed -i -e 1i$Q3_TEMP_INFO $argv[1]_DEL
            sed -i -e 1i$Q2_TEMP_INFO $argv[1]_DEL
            sed -i -e 1i$Q1_TEMP_INFO $argv[1]_DEL
            sed -i '/__LINE4__/d' $INFO_GX
            set FLAME_INFO = 3
        endif
    else if ($BINNING == "ON") then
            sed -i -e 1i$Q1_TEMP_INFO $argv[1]_DEL
            sed -i '/__LINE4__/d' $INFO_GX
            sed -i '/__LINE3__/d' $INFO_GX
            sed -i '/__LINE2__/d' $INFO_GX
            set FLAME_INFO = 1
    endif 
endif
#==========================================#
#COLUMN PROCESSING
#==========================================#
#5. COLUMN QUEUE CONTROL   
#   => Index for Excel file <KIBUNE_12_gaso syuturyoku narabi_231026.xlsx>
#      Sheet "02.suihei syuturyoku" 
#==========================================#
#CHECK_DPD=ON Analog No.13
if ($CHECK_DPD == "ON") then
    set COL_RANGE      = ( 1 `seq 669 -4 25` )
    set INFO_TOP       = 5
    set INFO_BOTTOM    = 0
    set COL_DEBUG_No   = 13
    set COL_DEBUG_SORT = '[INFO5],[TEMP],[PIX(BIN):2,6, ...,642,646]'
    set COL_DEBUG_MSG  = 'PIX(BIN)'
    set INFO_BOTTOM_COL = `repeat $INFO_BOTTOM printf ',XXX'`
    cat $argv[1]_ROW |awk -F, '{print  "00" $1 "," $2 ",000,000,000" }' >> $INFO_GX


#===BINNING=ON 
else if  ($BINNING == "ON") then
    #Analog No.9 
    if      ($OB_EN == "OFF" && $TEMP_EN == "OFF") then
            set COL_RANGE = ( `seq 669 -4 25` )
            set INFO_TOP       = 6
            set INFO_BOTTOM    = 0
            set COL_DEBUG_No   = 9
            set COL_DEBUG_SORT = '[INFO5],[INFO1],[PIX(BIN):2,6, ...,642,646]'
            set COL_DEBUG_MSG  = 'PIX(BIN)'
            set INFO_BOTTOM_COL = `repeat $INFO_BOTTOM printf ',XXX'`
            cat $argv[1]_ROW |awk -F, '{print  "00" $1 "," $2 ",000,000,000,000" }' >> $INFO_GX
    #Analog No.10
    else if ($OB_EN == "5"     && $TEMP_EN == "OFF") then
            set COL_RANGE = ( `seq 21 -4 5` `seq 669 -4 25` )
            set INFO_TOP       = 1
            set INFO_BOTTOM    = 0
            set COL_DEBUG_No   = 10
            set COL_DEBUG_SORT = '[INFO1],[OB(BIN):650,...,666],[PIX(BIN):2,6, ...,642,646]'
            set COL_DEBUG_MSG  = 'OB(BIN) + PIX(BIN)'
            set INFO_BOTTOM_COL = `repeat $INFO_BOTTOM printf ',XXX'`
            cat $argv[1]_ROW |awk -F, '{print  "00" $1 }' >> $INFO_GX

    #Analog No.11
    else if ($OB_EN == "OFF" && $TEMP_EN == "ON" ) then
            set COL_RANGE = ( 1 `seq 669 -4 25` )
            set INFO_TOP     = 5
            set INFO_BOTTOM  = 0
            set COL_DEBUG_No    = 11
            set COL_DEBUG_SORT = '[INFO5],[TEMP:670],[PIX(BIN):2,6, ...,642,646]'
            set COL_DEBUG_MSG  = 'TEMP + PIX(BIN)'
            set INFO_BOTTOM_COL = `repeat $INFO_BOTTOM printf ',XXX'`
            cat $argv[1]_ROW |awk -F, '{print  "00" $1 "," $2 ",000,000,000" }' >> $INFO_GX


    #Analog No.12
    else if ($OB_EN == "5"     && $TEMP_EN == "ON" ) then
            set COL_RANGE = ( 1 `seq 21 -4 5`  `seq 669 -4 25` )
            set INFO_TOP       = 0
            set INFO_BOTTOM    = 0
            set COL_DEBUG_No   = 12
            set COL_DEBUG_SORT = '[TEMP:670],[OB(BIN):650,...,666],[PIX(BIN):2,6, ...,642,646]'
            set COL_DEBUG_MSG  = 'TEMP + OB(BIN) + PIX(BIN)'
            set INFO_BOTTOM_COL = `repeat $INFO_BOTTOM printf ',XXX'`
            touch  $INFO_GX

    #Analog No.17
    else if ($OB_EN == "20"    && $TEMP_EN == "OFF" ) then
            set COL_RANGE = ( `seq 22 -1 3`  `seq 669 -4 25` )
            set INFO_TOP       = 2
            set INFO_BOTTOM    = 0
            set COL_DEBUG_No   = 17
            set COL_DEBUG_SORT = '[INFO1],[INFO1],[OB:649,650, ...n+1,668],[PIX(BIN):2,6, ...,642,646]'
            set COL_DEBUG_MSG  = 'OB(ALL) + PIX(BIN)'
            set COL_DEBUG_MSG  = 'TEMP + OB(ALL) + PIX(BIN)'
            set INFO_BOTTOM_COL = `repeat $INFO_BOTTOM printf ',000'`
            cat $argv[1]_ROW |awk -F, '{print  "00" $1 "," $2 }' >> $INFO_GX

    #Analog No.18
    else if ($OB_EN == "20"    && $TEMP_EN == "ON"  ) then
            set COL_RANGE = ( 1 `seq 22 -1 3`  `seq 669 -4 25` )
            set INFO_TOP       = 1
            set INFO_BOTTOM    = 0
            set COL_DEBUG_No   = 18
            set COL_DEBUG_SORT = '[INFO1],[TEMP:670],[OB:649,650, ...n+1,668],[PIX(BIN):2,6, ...,642,646]'
            set COL_DEBUG_MSG  = 'TEMP + OB(ALL) + PIX(BIN)'
            set INFO_BOTTOM_COL = `repeat $INFO_BOTTOM printf ',000'`
            cat $argv[1]_ROW |awk -F, '{print  "00" $1  }' >> $INFO_GX
    endif
#===BINNING=OFF 
else if  ($BINNING == "OFF") then
    #Analog No.1
    if      ($OB_EN == "OFF" && $TEMP_EN == "OFF") then
            set COL_RANGE = ( `seq 668 -1 25` )
            set INFO_TOP       = 4
            set INFO_BOTTOM    = 0
            set COL_DEBUG_No   = 1
            set COL_DEBUG_SORT = '[INFO3],[INFO1],[PIX:3,4, ...n+1,646]'
            set COL_DEBUG_MSG  = 'PIX(ALL)'
            set INFO_BOTTOM_COL = `repeat $INFO_BOTTOM printf ',XXX'`
            cat $argv[1]_ROW |awk -F, '{print  "00" $1 "," $2 ",000,000" }' >> $INFO_GX

    #Analog No.2
    else if      ($OB_EN == "5"     && $TEMP_EN == "OFF") then
            set COL_RANGE = ( `seq 22 -1 3`  `seq 668 -1 25` )
            set INFO_TOP       = 0
            set INFO_BOTTOM    = 0
            set COL_DEBUG_No   = 2
            set COL_DEBUG_SORT = '[OB:649,650, ...n+1,668],[PIX:3,4, ...n+1,646]'
            set COL_DEBUG_MSG  = 'OB(ALL) + PIX(ALL)'
            set INFO_BOTTOM_COL = `repeat $INFO_BOTTOM printf ',XXX'`
	    touch $INFO_GX

    #Analog No.3
    else if      ($OB_EN == "OFF" && $TEMP_EN == "ON") then
            set COL_RANGE = ( 1  `seq 668 -1 25` )
            set INFO_TOP       = 3
            set INFO_BOTTOM    = 0
            set COL_DEBUG_No   = 3
            set COL_DEBUG_SORT = '[INFO3],[TEMP:670],[PIX:3,4, ...n+1,646]'
            set COL_DEBUG_MSG  = 'TEMP + PIX(ALL)'
            set INFO_BOTTOM_COL = `repeat $INFO_BOTTOM printf ',XXX'`
	    cat $argv[1]_ROW |awk -F, '{print  "00" $1 "," $2 ",000" }' >> $INFO_GX
    #Analog No.4
    else if      ($OB_EN == "5" && $TEMP_EN == "ON" && $DUMMY_EN == "OFF") then
            set COL_RANGE = ( 1 `seq 22 -1 3`  `seq 668 -1 25` )
            set INFO_TOP       = 7
            set INFO_BOTTOM    = 0
            set COL_DEBUG_No   = 4
            set COL_DEBUG_SORT = '[INFO7],[TEMP:670],[OB:649,650,...n+1,668],[PIX:3,4, ...n+1,646]'
            set COL_DEBUG_MSG  = 'TEMP + OB(ALL) + PIX(ALL)' 
            set INFO_BOTTOM_COL = `repeat $INFO_BOTTOM printf ',XXX'`
	    cat $argv[1]_ROW |awk -F, '{print  "00" $1 "," $2 ",000,000,000,000,000" }' >> $INFO_GX

    #Analog No.8
    else if      ($DUMMY_EN == "ON") then
            set COL_RANGE = ( 1 `seq 22 -1 3`  `seq 668 -1 25` 670 669  24 23  2  )
            set INFO_TOP     = 7
            set INFO_BOTTOM  = 3
            set COL_DEBUG_No = 8
            set COL_DEBUG_SORT = '[INFO7],[TEMP:670],[OB:649,650,...n+1,668],[PIX:3,4,...n+1,646],[DUMMY:1,647,669],[INFO3]'
            set COL_DEBUG_MSG  = 'TEMP + OB(ALL) + PIX(ALL) + DUMMY' 
            set INFO_BOTTOM_COL = `repeat $INFO_BOTTOM printf ',000'`
	    cat $argv[1]_ROW |awk -F, '{print  "00" $1 "," $2 ",000,000,000,000,000" }' >> $INFO_GX
    endif
endif


@ COL_TOTAL = $INFO_TOP + $INFO_BOTTOM + $#COL_RANGE - 1
echo $COL_TOTAL ,$#COL_RANGE
set Q1_LAST = `repeat $INFO_BOTTOM printf ',XXX'`
set Q3_LAST = `repeat $INFO_BOTTOM printf ',FFF'`
set Q4_LAST = `repeat $INFO_BOTTOM printf ',000'`
set Q1_GX_INFO = `repeat $INFO_TOP printf "XXX," | sed -e 's/,$//g'`
set Q2_GX_INFO = `awk -v max=$COL_TOTAL 'BEGIN { for (i=0; i<=max; i++) {printf("%03X", i); if (i<max) { printf(",");} } printf("\n"); }'`
set Q3_GX_INFO = `repeat $INFO_TOP printf "FFF," | sed -e 's/,$//g'`
set Q4_GX_INFO = `repeat $INFO_TOP printf "000," | sed -e 's/,$//g'`
sed -i -e "s/__LINE1__/$Q1_GX_INFO$Q1_LAST/g" $INFO_GX
sed -i -e "s/__LINE2__/$Q2_GX_INFO/g" $INFO_GX
sed -i -e "s/__LINE3__/$Q3_GX_INFO$Q3_LAST/g" $INFO_GX
sed -i -e "s/__LINE4__/$Q4_GX_INFO$Q4_LAST/g" $INFO_GX
#==========================================#
#COLUMN SORT
#==========================================#
set AWK_COMMAND = "print "
foreach col ($COL_RANGE)
    set AWK_COMMAND = `echo $AWK_COMMAND '$'${col}`
    if ($col != $COL_RANGE[$#COL_RANGE]) then
        set AWK_COMMAND = `echo $AWK_COMMAND ,`
    endif
end

#=========================================#
#OUTPUT PROCESS
#=========================================#
set dir_path = "./exp_dirs"
if ( ! -d $dir_path ) then
    mkdir $dir_path
    chmod 777 -R $dir_path
endif


set OUTPUT    = "$dir_path/NO${ANALOG_NO}_TAP${TAP}_VTEMP_${VTEMP_EN}_${VROI}_$argv[1]"

cat $argv[1]_DEL | awk -F, -v OFS=, "{$AWK_COMMAND}" | awk -v var="$INFO_BOTTOM_COL" -v flame_info="$FLAME_INFO" '{if (NR>flame_info) {print  $0 var} else { print $0}} ' > ${OUTPUT}_tmp
    if ( `cat $INFO_GX | wc -l ` > 0 ) then
    awk -F, 'BEGIN {OFS=","} {if (NR==FNR) {a[NR] = $0} else {print a[FNR], $0}}' $INFO_GX ${OUTPUT}_tmp | sed -e "s/,,//g" -e 's/,$//g' -e "s/^,//g"> $OUTPUT
else
    cat ${OUTPUT}_tmp | sed -e "s/,,//g" -e 's/,$//g' -e "s/^,//g"> $OUTPUT
endif
sed -i -e "s///g" $OUTPUT
if ($INVERT == "ON") then
     mv $OUTPUT $dir_path/out.tmp
     set OUTPUT    = "$dir_path/NO${ANALOG_NO}_TAP${TAP}_VTEMP_${VTEMP_EN}_${VROI}_INVERT_$argv[1]"
     python $INVERT_HEX $dir_path/out.tmp $OUTPUT
endif
sed -i -e "s///g" $OUTPUT
#gzip $OUTPUT
chmod 777 $OUTPUT
#==========================================#
#PROCESS_MONITER
#==========================================#
set LINE = '#============================================#'
echo "\n$LINE\n Summary\n$LINE "
echo "[ ROW_ROI_RANGE ]"
if ("$CHECK_DPD" == "OFF") then
    echo "PIX = $PIX_start ~ $PIX_end (LINE = $PIX_start_Q ~ $PIX_end_Q)"
endif
echo "\n[ COLUMN_RANGE ]"
echo "COL Analog_No.$COL_DEBUG_No"
echo "ALLAY  : $COL_DEBUG_SORT"
echo "OUTPUT : $COL_DEBUG_MSG"
echo "ALLAY Image:\n   `repeat $INFO_TOP printf 'INFO '`  $COL_RANGE `repeat $INFO_BOTTOM printf 'INFO '`"
echo "Created : $OUTPUT"
rm -f *_ROW *_ROI *_tmp ${OUTPUT}_tmp $dir_path/out.tmp >& /dev/null
