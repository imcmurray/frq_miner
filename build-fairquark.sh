#!/bin/bash
FAIRQUARK_PATH=`pwd`
[[ -f $(FAIRQUARK_PATH)/stop-fairquarkd.sh ]] && ./${FAIRQUARK_PATH}/stop-fairquarkd.sh
if [[ -d fairquark ]]; then
    cd ${FAIRQUARK_PATH}/FairQuark/src
    git pull
    cd ${FAIRQUARK_PATH}/FairQuark/src
    make -f makefile.unix clean
else
    cd ${FAIRQUARK_PATH}
    git clone https://github.com/jdgdredd/FairQuark
fi
cd ${FAIRQUARK_PATH}/FairQuark/src
make -f makefile.unix USE_UPNP=- DEBUGFLAGS=""
sudo cp fairquarkd /usr/local/bin/
