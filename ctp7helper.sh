#!/bin/sh

helpstring="Usage: $0 [options] <CTP7 hostname>
  Options:
    -c Check CTP7 fw version
    -f Reload CTP7 firmware
    -i Restart IPBus
    -r Recover CTP7
    -u CTP7 Uptime

Plese report bugs to
https://github.com/cms-gem-daq-project/gemctp7user"

while getopts "cfruh" opts
do
    case $opts in
        c)
            checkctp7fw="1";;
        f)
            reloadctp7fw="1";;
        i)
            restartipbus="1";;
        r)
            recoverctp7="1";;
        u)
            checkuptime="1";;
        h)
            echo >&2 ${helpstring}
            exit 1;;
        \?)
            echo >&2 ${helpstring}
            exit 1;;
        [?])
            echo >&2 ${helpstring}
            exit 1;;
    esac
done

shift $((OPTIND-1))
ctp7host=${1}

ping -q -c 1 ${ctp7host} >& /dev/null
ctp7up=$?
if [ $ctp7up != 0 ]
then
    echo "Unable to ping host ${ctp7host}"
    exit
fi

if [ -n "${reloadctp7fw}" ]
then
    TASK_DESCRIPTION="Reloading the CTP7 firmware"
    ACTION_MESSAGE="Are you sure you want to reload the CTP7 firmware?"
    COMMAND="ssh -qt gemuser@${ctp7host} \"sh -lc 'cold_boot.sh'\""
elif [ -n "${recoverctp7}" ]
then
    TASK_DESCRIPTION="Recover the CTP7"
    ACTION_MESSAGE="Are you sure you want to recover the CTP7?"
    COMMAND="ssh -qt gemuser@${ctp7host} \"sh -lc 'recover.sh'\""
elif [ -n "${restartipbus}" ]
then
    TASK_DESCRIPTION="Restart the IPBus service on the CTP7"
    ACTION_MESSAGE="Are you sure you want to restart IPBus?"
    COMMAND="ssh -qt gemuser@${ctp7host} \"sh -lc 'restart_ipbus.sh'\""
elif [ -n "${checkctp7fw}" ]
then
    TASK_DESCRIPTION="Checking the CTP7 firmware version"
    ACTION_MESSAGE="Are you sure you want to check the CTP7 firmware version?"
    COMMAND="ssh -qt gemuser@${ctp7host} \"ls -l /mnt/persistent/gemdaq/fw/gem_ctp7.bit && ls -l /mnt/persistent/gemdaq/xml/gem_amc_top.xml\""
elif [ -n "${checkuptime}" ]
then
    TASK_DESCRIPTION="Checking the CTP7 uptime"
    ACTION_MESSAGE="Are you sure you want to check the CTP7 uptime?"
    COMMAND="ssh -qt gemuser@${ctp7host} \"uptime\""
fi

if [ -n "${COMMAND}" ]
then
    echo "${TASK_DESCRIPTION} (make sure you post an elog stating what command you executed and any output)"
    read -p "${ACTION_MESSAGE}: (y|n) : " create
    while true
    do
        case $create in
            [yY]* )
                eval ${COMMAND}
                break;;
            [nN]* )
                break;;
            * )
                echo "Enter y or n (case insensitive)";;
        esac
    done
else
    echo "No command specified, not doing anything"
fi
