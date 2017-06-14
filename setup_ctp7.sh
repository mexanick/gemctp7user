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
    echo "Fetching binaries, firmware and libraries"
    echo "cd ./bin && wget https://github.com/mexanick/xhal/releases/download/v2.0.0/ipbus && cd -"
    cd ./bin && wget https://github.com/mexanick/xhal/releases/download/v2.0.0/ipbus && cd -
    echo "cd ./lib && wget https://github.com/mexanick/xhal/releases/download/v2.0.0/liblog4cplus.so && wget https://github.com/mexanick/xhal/releases/download/v2.0.0/libxhal_ctp7.so && wget https://github.com/mexanick/xhal/releases/download/v2.0.0/libxerces-c.so && wget https://github.com/mexanick/xhal/releases/download/v2.0.0/librwreg_ctp7.so && wget https://github.com/mexanick/xhal/releases/download/v2.0.0/liblmdb.so && ln -sf librwreg_ctp7.so librwreg.so && ln -sf libxerces-c.so libxerces-c-3.1.so && cd -"
    cd ./lib && wget https://github.com/mexanick/xhal/releases/download/v2.0.0/liblog4cplus.so && wget https://github.com/mexanick/xhal/releases/download/v2.0.0/libxhal_ctp7.so && wget https://github.com/mexanick/xhal/releases/download/v2.0.0/libxerces-c.so && wget https://github.com/mexanick/xhal/releases/download/v2.0.0/librwreg_ctp7.so && wget https://github.com/mexanick/xhal/releases/download/v2.0.0/liblmdb.so && ln -sf librwreg_ctp7.so librwreg.so && ln -sf libxerces-c.so libxerces-c-3.1.so && cd -
    echo "cd ./python && wget https://github.com/mexanick/xhal/files/1071017/reg_interface.zip && unzip reg_interface.zip && rm reg_interface.zip && cd -"
    cd ./python && wget https://github.com/mexanick/xhal/files/1071017/reg_interface.zip && unzip reg_interface.zip && rm reg_interface.zip && cd -
    echo "cd ./fw && wget https://github.com/evka85/GEM_AMC/releases/download/v1.9.4/gem_ctp7_v1_9_4_GBT.bit && ln -sf gem_ctp7_v1_9_4_GBT.bit gem_ctp7.bit && cd -"
    cd ./fw && wget https://github.com/evka85/GEM_AMC/releases/download/v1.9.4/gem_ctp7_v1_9_4_GBT.bit && ln -sf gem_ctp7_v1_9_4_GBT.bit gem_ctp7.bit && cd -
    echo "cd ./oh_fw && wget https://github.com/thomaslenzi/OptoHybridv2/releases/download/2.2.D.FB/optohybrid_top.bit -O optohybrid_2.2.D.FB.bit && ln -sf optohybrid_2.2.D.FB.bit optohybrid_top.bit && wget https://github.com/thomaslenzi/OptoHybridv2/releases/download/2.2.D.FB/optohybrid_top.mcs -O optohybrid_2.2.D.FB.mcs && ln -sf optohybrid_2.2.D.FB.mcs optohybrid_top.mcs && cd -"
    cd ./oh_fw && wget https://github.com/thomaslenzi/OptoHybridv2/releases/download/2.2.D.FB/optohybrid_top.bit -O optohybrid_2.2.D.FB.bit && ln -sf optohybrid_2.2.D.FB.bit optohybrid_top.bit && wget https://github.com/thomaslenzi/OptoHybridv2/releases/download/2.2.D.FB/optohybrid_top.mcs -O optohybrid_2.2.D.FB.mcs && ln -sf optohybrid_2.2.D.FB.mcs optohybrid_top.mcs && cd -
    echo "cd ./xml && wget https://github.com/evka85/GEM_AMC/releases/download/v1.9.4/address_table_v1_9_4.zip && unzip address_table_v1_9_4.zip && cp address_table_v1_9_4/gem_amc_top.xml gem_amc_v1_9_4.xml && rm -rf address_table* && ln -sf gem_amc_v1_9_4.xml gem_amc_top.xml && cd -"
    cd ./xml && wget https://github.com/evka85/GEM_AMC/releases/download/v1.9.4/address_table_v1_9_4.zip && unzip address_table_v1_9_4.zip && cp address_table_v1_9_4/gem_amc_top.xml gem_amc_v1_9_4.xml && rm -rf address_table* && ln -sf gem_amc_v1_9_4.xml gem_amc_top.xml && cd -
    echo "rsync -aXch --progress --partial --links bin fw lib oh_fw scripts xml python root@$ctp7host:/mnt/persistent/gemdaq/"
    rsync -aXch --progress --partial --links bin fw lib oh_fw scripts xml python root@$ctp7host:/mnt/persistent/gemdaq/
    echo "Clearing folders"
    rm ./bin/*.*
    rm ./lib/*.*
    rm ./fw/*.*
    rm ./oh_fw/*.*
    rm ./python/reg_interface/*.*
    rm ./xml/*.*
fi
