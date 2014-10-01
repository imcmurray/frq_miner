#!/bin/bash
FAIRQUARK_PATH=`pwd`
conf=$(fairquarkd getbalance)
unconf=$(fairquarkd getbalance '' 1)
immature=$(echo "scale=4;${unconf} - ${conf}" | bc)
echo "Stats: $(fairquarkd getmininginfo)"
echo "Confirmed Balance:  ${conf}"
echo "Immature Balance:   ${immature}"
echo "Immature TX: $(fairquarkd listtransactions | grep immature | wc -l)"
echo "Connections: $(fairquarkd getconnectioncount)"
qrkAdr=$(fairquarkd listtransactions "" 99999 | grep -C 1 '"generate"\|"receive"' | grep "address" | cut -d":" -f2
echo "Fairquark mined coin addresses: ${qrkArd}"
