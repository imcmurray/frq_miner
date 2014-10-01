#!/bin/bash
FAIRQUARK_PATH=`pwd`
killall -q start-fairquarkd
fairquarkd stop
sleep 3
[[ -n "$(pidof fairquarkd)" ]] && killall fairquarkd
