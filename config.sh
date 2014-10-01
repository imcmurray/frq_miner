#!/bin/bash
FAIRQUARK_PATH=`pwd`
nano ${FAIRQUARK_PATH}/.fairquark/fairquark.conf
${FAIRQUARK_PATH}/stop-fairquarkd.sh
${FAIRQUARK_PATH}/start-fairquarkd.sh
