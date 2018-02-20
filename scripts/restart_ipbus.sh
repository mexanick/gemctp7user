#!/bin/sh

ipbstatus=$(ps |grep [i]pbus)

if [ "$?" = "1" ]
then
    NOW=$(date +"%H-%M-%m-%d-%Y")
    echo "nohup ipbus 2>&1 > ${HOME}/logs/ipbus_${NOW}.log"
    nohup ipbus 2>&1 > ${HOME}/logs/ipbus_${NOW}.log
else
    echo "ipbus is running, not restarting"
fi
