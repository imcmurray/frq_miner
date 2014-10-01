#!/bin/bash
FAIRQUARK_PATH=`pwd`
export PATH="/usr/local/bin:$PATH"
echo Starting fairquarkd
[[ -n "$(pidof fairquarkd)" ]] && killall --older-than 60s -q start-fairquarkd fairquarkd
function background_loop
    while :; do
        fairquarkd -blocknotify="${FAIRQUARK_PATH}/notify-block" -walletnotify="${FAIRQUARK_PATH}/notify-wallet" >/dev/null 2>&1
        sleep 5
        date >> ${FAIRQUARK_PATH}/crash.log
    done
background_loop &
