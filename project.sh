#!/bin/bash

#C program

function1()
{
    cd
    read name
    mkdir $name
    cd $name
    while [ 1 ];
    do
        clear
        touch $name.c
        echo -e "#include<stdio.h> \n#include<string.h> \n#include<signal.h> \n#include<math.h>
        \nint main() \n{ \n\n   return 0;\n}" > $name.c
        vi $name.c
        
        gcc -o $name $name.c
        ./$name
        read state
        if [ "$state" != "e" ];
        then
            break
        fi
    done
}
#function1
clean_up()
{
    echo "PID: $1"
    while [ 1 ]
    do
        IS_LIVE=$(ps -p $1 | grep $1 )
        if [ -z "$IS_LIVE" ];
        then
            IS_BLOCKING=$(sed -n 1p /etc/hosts | grep "127.0.0.1 facebook")
            if [ -z "$IS_BLOCKING" ]
            then
                echo "Exiting..."
            else
                sed -i 1d /etc/hosts
            fi
                break
        fi
    done
}

#schedule 

function2()
{
    #trap "sed -i 1d /etc/hosts; exit" SIGINT SIGTERM 
    SET_TIME=$1
    if [ -z "$SET_TIME" ];
    then
        SET_TIME="01:00"
    fi
    STRICT_TIME_START_1="04:02"
    STRICT_TIME_START_2="04:14"
    STRICT_TIME_END_1="04:13"
    STRICT_TIME_END_2="04:15"
    START_TIME_1=$(date --date="$STRICT_TIME_START_1" +%s)
    START_TIME_2=$(date --date="$STRICT_TIME_START_2" +%s)
    END_TIME_1=$(date --date="$STRICT_TIME_END_1" +%s)
    END_TIME_2=$(date --date="$STRICT_TIME_END_2" +%s)
    IS_BLOCKING=0
    while [ 1 ]
    do
        CUR_TIME=$(date '+%H:%M')
        CUR_TIME_MINUTE=$(date --date="$CUR_TIME" +%s)
        DIST_TIME_START_1=$(( $START_TIME_1 - $CUR_TIME_MINUTE ))  
        DIST_TIME_START_2=$(( $START_TIME_2 - $CUR_TIME_MINUTE ))  
        DIST_TIME_END_1=$(( $END_TIME_1 - $CUR_TIME_MINUTE ))  
        DIST_TIME_END_2=$(( $END_TIME_2 - $CUR_TIME_MINUTE ))  
        if [ $IS_BLOCKING -eq 0 -a $DIST_TIME_START_1 -le 0 -a $DIST_TIME_END_1 -gt 0 ];
        then
            sed -i 1i"127.0.0.1 www.facebook.com" /etc/hosts
            IS_BLOCKING=1
        elif [ $IS_BLOCKING -eq 1 -a $DIST_TIME_END_1 -le 0 -a $DIST_TIME_START_2 -gt 0 ];
        then
            sed -i 1d /etc/hosts
            IS_BLOCKING=0
        elif [ $IS_BLOCKING -eq 0 -a $DIST_TIME_START_2 -le 0 -a $DIST_TIME_END_2 -gt 0 ];
        then    
            sed -i 1i"127.0.0.1 www.facebook.com" /etc/hosts
            IS_BLOCKING=1
        elif [ $IS_BLOCKING -eq 1 -a $DIST_TIME_END_2 -le 0  ];
        then
            sed -i 1d /etc/hosts
            IS_BLOCKING=0
             
        fi    
                
        #if [ $(($STRICT_TIME_START - $CUR_TIME))  ]
        if [ "$CUR_TIME" == "$SET_TIME" ];
        then
            xdg-open https://trello.com/c/NrlPcuCZ/14-landuong-linux-shell-script
#xdg-open https://trello.com/b/AGECPovB/internship-programming-july-2020
#            xdg-open https://docs.google.com/spreadsheets/d/1quPTUlVpyrnW3IeGIcMVGk0Y5Uy_OUWfWTyMbGT9gyg/edit#gid=133767006
            sleep 100
        fi

        sleep 10
    done
}
function2 $1 &
clean_up $! &

function3()
{
    read location
    geocode_api="https://api.mapbox.com/geocoding/v5/mapbox.places/${location}.json?access_token=pk.eyJ1IjoidmlldGFuaHBuIiwiYSI6ImNrMW4xc3d4NDA1c3EzYnBkbDlpcnZqZG8ifQ.w-zH89twO9EHzK_f9MeuqA"
    latitude=$(curl -s ${geocode_api} | jq '.features[0].center[1]')
    longitude=$(curl -s ${geocode_api} | jq '.features[0].center[0]')
    forecast_api="https://api.darksky.net/forecast/0b16aa4375ee5d1f2347b38d1b50b642/${latitude},${longitude}"
    summary=$(curl -s ${forecast_api} | jq '.daily.data[0].summary')
    temperature=$(curl -s ${forecast_api} | jq '.currently.temperature')
    precipProbability=$(curl -s ${forecast_api} | jq '.currently.precipProbability')
   echo "${summary} It is currently `echo "scale=2; ($temperature-32)*5/9" | bc -l` degress out. There is a  ${precipProbability}% chance of rain."
}
#function3
