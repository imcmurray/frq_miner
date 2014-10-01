#!/bin/bash
FAIRQUARK_PATH=`pwd`
mkdir /var/spool/cron/crontabs/ > /dev/null 2>&1
echo "@reboot ${FAIRQUARK_PATH}/start-fairquarkd" | sudo tee    /var/spool/cron/crontabs/$(whoami) > /dev/null 2>&1
echo ""                                 | sudo tee -a /var/spool/cron/crontabs/$(whoami) > /dev/null 2>&1
sudo chmod 0600 /var/spool/cron/crontabs/$(whoami)
sudo update-rc.d cron defaults
echo "rpcusername=${FAIRQUARK_USERNAME}
rpcpassword=$(cat /dev/urandom | tr -cd '[:alnum:]' | head -c32)
gen=1
genproclimit=-1" > ${FAIRQUARK_PATH}/.fairquark/fairquark.conf
