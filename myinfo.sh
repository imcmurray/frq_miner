#!/bin/bash
FAIRQUARK_PATH=`pwd`
for addr in $(fairquarkd listtransactions "" 99999 | grep -C 1 '"generate"\|"receive"' | grep --color=never -o "\b[A-Za-z0-9]\{33,36\}\b" |
 sort -u); do
    echo Address: ${addr}
    echo PrivKey: $(fairquarkd dumpprivkey ${addr})
    echo
done
