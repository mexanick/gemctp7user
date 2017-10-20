#!/bin/sh

helpstring="Usage: $0 [-c Check CTP7 fw version] [-r Recover CTP7] [-f Reload CTP7 firmware] CTP7 hostname"

while getopts "cfrh" opts
do
    case $opts in
        c)
            echo "selected check ctp7 fw"
            checkctp7fw="1";;
        f)
            echo "selected reload ctp7 fw"
            reloadctp7fw="1";;
        r)
            echo "selected recover ctp7"
            recoverctp7="1";;
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

echo ctp7host     ${ctp7host}
echo checkctp7fw  ${checkctp7fw}
echo reloadctp7fw ${reloadctp7fw}
echo recoverctp7  ${recoverctp7}

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
    COMMAND="ssh texas@${ctp7host} cold_boot.sh"
elif [ -n "${recoverctp7}" ]
then
    TASK_DESCRIPTION="Recover the CTP7"
    ACTION_MESSAGE="Are you sure you want to recover the CTP7?"
    COMMAND="ssh texas@${ctp7host} recover.sh"
elif [ -n "${checkctp7fw}" ]
then
    TASK_DESCRIPTION="Checking the CTP7 firmware version"
    ACTION_MESSAGE="Are you sure you want to check the CTP7 firmware version?"
    COMMAND="ssh -qt texas@${ctp7host} \"ls -l /mnt/persistent/gemdaq/fw/gem_ctp7.bit && ls -l /mnt/persistent/gemdaq/xml/gem_amc_top.xml\""
fi

echo TASK_DESCRIPTION $TASK_DESCRIPTION
echo ACTION_MESSAGE   $ACTION_MESSAGE
echo COMMAND          $COMMAND

# Reload CTP7 firmware
## turn this into a function to always prompt, regardless of the command to be executed
if [ -n "${COMMAND}" ]
then
    read -p "${TASK_DESCRIPTION}: (y|n) : " create
    while true
    do
        case $create in
            [yY]* )
                echo ${ACTION_MESSAGE}
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
