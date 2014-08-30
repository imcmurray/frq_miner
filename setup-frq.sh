# Quarkcoin All-In-One EZ Setup Script
# ISM - Hacked to provide fairquark
# Download the fairquark.wallet.tgz from the fairquark site
# and unpack the archive. Then run this script.
#
# Hacked together by GigaWatt
# Donations welcome!
#   BTC: 1E2egHUcLDAmcxcqZqpL18TPLx9Xj1akcV
#   XPM: AWHJbwoM67Ez12SHH4pH5DnJKPoMSdvLz2
# Last Update: 27 August, 2013

{
# PUT YOUR SETTINGS HERE
QUARKCOIN_USERNAME="root"

# Build swapfile
if [[ ! -f /swapfile ]]; then
    echo "Building swapfile..."
    sudo dd if=/dev/zero of=/swapfile bs=64M count=16
    sudo mkswap /swapfile
    sudo swapon /swapfile

    # Mount on reboot
    if [[ -z "$(cat /etc/fstab | grep swapfile)" ]]; then
        echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab > /dev/null 2>&1
    fi
fi

# Auto reboot on kernel panic
if [[ -z "$(cat /etc/sysctl.conf | grep '^kernel.panic')" ]]; then
    echo "kernel.panic=3" | sudo tee /etc/sysctl.conf >/dev/null 2>&1
fi


echo "Installing libraries..."
sudo apt-get update
sudo apt-get install build-essential bc curl fail2ban git haveged libboost-all-dev libdb++-dev libminiupnpc-dev libssl-dev m4 nano -y

# Install GMP
cd ~/
rm -rf gmp-5.1.2.tar.bz2 gmp-5.1.2
wget http://mirrors.kernel.org/gnu/gmp/gmp-5.1.2.tar.bz2
tar xjvf gmp-5.1.2.tar.bz2
cd gmp-5.1.2
./configure --enable-cxx
make
sudo make install
rm -rf gmp-5.1.2.tar.bz2 gmp-5.1.2
cd ~/

# Enable HAVEGED for entropy
sudo update-rc.d haveged defaults
sudo service haveged restart


echo "Downloading and building quark..."
cat << "SCRIPT" > ~/build-fairquark
#!/bin/bash
[[ -f ~/stop-fairquarkd ]] && ./stop-fairquarkd
#if [[ -d ~/fairquark ]]; then
    cd ~/fairquark/src
#    git pull
#    cd ~/fairquark/src
    make -f makefile.unix clean
#else
#    cd ~
#    git clone https://github.com/MaxGuevara/quark.git
#fi
cd ~/fairquark/src
make -f makefile.unix USE_UPNP=- DEBUGFLAGS=""
sudo cp fairquarkd /usr/local/bin/
SCRIPT
chmod +x ~/build-fairquark
~/build-fairquark


echo "Building settings and scripts..."
mkdir ~/.fairquark
echo "rpcusername=${QUARKCOIN_USERNAME}
rpcpassword=$(cat /dev/urandom | tr -cd '[:alnum:]' | head -c32)
gen=1
genproclimit=-1" > ~/.fairquark/fairquark.conf


# Notification scripts
cat << "SCRIPT" > ~/notify-block
#!/bin/bash
# YOUR SCRIPT HERE
SCRIPT
chmod +x ~/notify-block

cat << "SCRIPT" > ~/notify-wallet
#!/bin/bash
# YOUR SCRIPT HERE
cp ~/.fairquark/wallet.dat ~/${HOSTNAME}.bak
SCRIPT
chmod +x ~/notify-wallet


# Watchdog runner
cat << "SCRIPT" > ~/start-fairquarkd
#!/bin/bash
export PATH="/usr/local/bin:$PATH"
echo Starting fairquarkd
[[ -n "$(pidof fairquarkd)" ]] && killall --older-than 60s -q start-fairquarkd fairquarkd
function background_loop
    while :; do
        fairquarkd -blocknotify="~/notify-block" -walletnotify="~/notify-wallet" >/dev/null 2>&1
        sleep 5
        date >> ~/crash.log
    done
background_loop &
SCRIPT
chmod +x ~/start-fairquarkd
~/start-fairquarkd


# Add to startup
mkdir /var/spool/cron/crontabs/ > /dev/null 2>&1
echo "@reboot ${HOME}/start-fairquarkd" | sudo tee    /var/spool/cron/crontabs/$(whoami) > /dev/null 2>&1
echo ""                                 | sudo tee -a /var/spool/cron/crontabs/$(whoami) > /dev/null 2>&1
sudo chmod 0600 /var/spool/cron/crontabs/$(whoami)
sudo update-rc.d cron defaults


# Watchdog stopper
cat << "SCRIPT" > ~/stop-fairquarkd
#!/bin/bash
killall -q start-fairquarkd
fairquarkd stop
sleep 3
[[ -n "$(pidof fairquarkd)" ]] && killall fairquarkd
SCRIPT
chmod +x ~/stop-fairquarkd

# Watchdog restarter
cat << "SCRIPT" > ~/restart-fairquarkd
#!/bin/bash
~/stop-fairquarkd
~/start-fairquarkd
SCRIPT
chmod +x ~/restart-fairquarkd

# Peek at status
cat << "SCRIPT" > ~/peek
#!/bin/bash
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
SCRIPT
chmod +x ~/peek


# Dump address info
cat << "SCRIPT" > ~/myinfo
#!/bin/bash
for addr in $(fairquarkd listtransactions "" 99999 | grep -C 1 '"generate"\|"receive"' | grep --color=never -o "\b[A-Za-z0-9]\{33,36\}\b" |
 sort -u); do
    echo Address: ${addr}
    echo PrivKey: $(fairquarkd dumpprivkey ${addr})
    echo
done
SCRIPT
chmod +x ~/myinfo


# Edit fairquark config file
cat << "SCRIPT" > ~/config
#!/bin/bash
nano ~/.fairquark/fairquark.conf
~/stop-fairquarkd
~/start-fairquarkd
SCRIPT
chmod +x ~/config


# Automate the sending of coins to my address
# PLEASE edit this file and replace my info with yours
cat << "SCRIPT" > ~/sendToMe
coins=$(./peek | grep Confirmed | awk {'print $3 '} | cut -d'.' -f1)
echo "Found ${coins} that we can transferred to my wallet.\n"
echo "Setting the account to mined...\n"
./myinfo | grep Address | awk {'print "fairquarkd setaccount " $2 " mined"'} > setAct.sh
sh setAct.sh
echo "Account set, now initiating the transfer...\n"
fairquarkd sendfrom mined qNed1vapV1znvM2octi38jie1y9Bv6GfsS ${coins}
echo "\nDone\n";
SCRIPT
chmod +x ~/sendToMe


echo
echo
echo '=========================================================='
echo 'All Done!'
echo 'fairquarkd should be up and running'
echo
echo 'Run ~/start-fairquarkd  to start fairquarkd and begin mining'
echo 'Run ~/stop-fairquarkd   to stop fairquarkd and stop mining'
echo 'Run ~/build-fairquark   to update and rebuild fairquarkd'
echo 'Run ~/config            to modify your fairquarkd config file'
echo 'Run ~/peek              to check on your mining status'
echo 'Run ~/myinfo            to view your fairquark address and privkey'
echo 'Run ~/sendToMe          to assign mined coins to an account and send them to your wallet'
}
