#!/bin/sh

echo "CTP7 Virtex-7 cold boot in progress..."

cd $(dirname "$0")

false
RETVAL=$?

while [ $RETVAL -ne 0 ]
do
    v7load $GEM_PATH/gem_ctp7.bit
    RETVAL=$?
done

# Disable Opto TX Lasers
/bin/txpower enable

# Configure GTHs in loopback mode
sh gth_config_opto.sh

# GTH channel reset procedure
sh gth_reset.sh

#Print gth status register
sh gth_status.sh
