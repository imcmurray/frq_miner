#!/bin/bash
FAIRQUARK_PATH=`pwd`
coins=$(./${FAIRQUARK_PATH}/peek | grep Confirmed | awk {'print $3 '} | cut -d'.' -f1)
echo "Found ${coins} that we can transferred to my wallet.\n"
echo "Setting the account to mined...\n"
./myinfo | grep Address | awk {'print "fairquarkd setaccount " $2 " mined"'} > ${FAIRQUARK_PATH}/setAct.sh
sh ${FAIRQUARK_PATH}/setAct.sh
echo "Account set, now initiating the transfer...\n"
fairquarkd sendfrom mined qNed1vapV1znvM2octi38jie1y9Bv6GfsS ${coins}
echo "\nDone\n";
