#!/bin/sh

helpstring="Usage: $0 [-o OptoHybrid fw version] [-c CTP7 fw version] [-a CTP7 user account to create] [-u Update CTP7 libs/bins/fw images] CTP7 hostname"

while getopts "a:c:o:uh" opts
do
    case $opts in
        c)
            ctp7fw="$OPTARG";;
        o)
            ohfw="$OPTARG";;
        a)
            newuser="$OPTARG";;
        u)
            update="1";;
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

ping -q -c 1 $ctp7host >& /dev/null
ctp7up=$?
if [ $ctp7up != 0 ]
then
    echo "Unable to ping host ${ctp7host}"
    exit
fi

# create local links if requested
if [ -n "${ohfw}" ]
then
    # echo "creating links for OH firmware version: ${ohfw}"
    if [ -f "oh_fw/optohybrid_${ohfw}.bit" ]
    then
        echo "ln -sf optohybrid_${ohfw}.bit oh_fw/optohybrid_top.bit"
        ln -sf optohybrid_${ohfw}.bit oh_fw/optohybrid_top.bit
    else
        echo "OH firmware oh_fw/optohybrid_${ohfw}.bit missing"
    fi

    if [ -f "oh_fw/optohybrid_${ohfw}.mcs" ]
    then
        echo "ln -sf optohybrid_${ohfw}.mcs oh_fw/optohybrid_top.mcs"
        ln -sf optohybrid_${ohfw}.mcs oh_fw/optohybrid_top.mcs
    else
        echo "OH firmware oh_fw/optohybrid_${ohfw}.mcs missing"
    fi
fi

if [ -n "${ctp7fw}" ]
then
    # echo "creating links for CTP7 firmware version: ${ctpfw}"
    if [ -f "fw/gem_ctp7_gem_ctp7_${ctp7fw}.bit" ]
    then
        echo "ln -sf gem_ctp7_${ctp7fw}.bit fw/gem_ctp7.bit"
        ln -sf gem_ctp7_${ctp7fw}.bit fw/gem_ctp7.bit
    else
        echo "CTP7 firmware fw/gem_ctp7_${ctp7fw}.bit missing"
    fi

    if [ -f "xml/gem_amc_top_${ctp7fw}.xml" ]
    then
        echo "ln -sf gem_amc_top_${ctp7fw}.xml xml/gem_amc_top.xml"
        ln -sf gem_amc_top_${ctp7fw}.xml xml/gem_amc_top.xml
    else
        echo "CTP7 firmware xml/gem_amc_top_${ctp7fw}.xml missing"
    fi
fi

# create new CTP7 user if requested
if [ -n "${newuser}" ]
then
    read -p "Create CTP7 user account: ${newuser} (y|n) : " create
    while true
    do
        case $create in
            [yY]* )
                echo "ssh root@$ctp7host adduser ${newuser} -h /mnt/persistent/${newuser}";
                ssh root@$ctp7host adduser ${newuser} -h /mnt/persistent/${newuser};
                echo "rsync -aXch --progress --partial --links .profile .bashrc .viminfo .vimrc .inputrc ${newuser}@$ctp7host:~/";
                rsync -aXch --progress --partial --links .profile .bashrc .viminfo .vimrc .inputrc ${newuser}@$ctp7host:~/;
                break;;
            [nN]* )
                break;;
            * )
                echo "Enter y or n (case insensitive)";;
        esac
    done
fi

# Update CTP7 gemdaq paths
if [ -n "${update}" ]
then
    echo "Creating/updating CTP7 gemdaq directory structure"
    echo "ssh root@$ctp7host mkdir -p /mnt/persistent/gemdaq"
    ssh root@$ctp7host mkdir -p /mnt/persistent/gemdaq
    echo "rsync -aXch --progress --partial --links bin fw lib oh_fw scripts xml python root@$ctp7host:/mnt/persistent/gemdaq/"
    rsync -aXch --progress --partial --links bin fw lib oh_fw scripts xml python root@$ctp7host:/mnt/persistent/gemdaq/
fi
