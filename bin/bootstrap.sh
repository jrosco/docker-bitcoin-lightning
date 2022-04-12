#!/bin/bash

# https://medium.com/@dougvk/run-your-own-mainnet-lightning-node-2d2eab628a8b
# userdata found in /var/lib/cloud/instances/XXXXXXXXX/user-data.txt

# install required packages
apt-get update
apt-get -y install \
    docker.io \
    python3 \
    jq \
    vim \
    unzip \
    fail2ban \
    git && \
    apt-get clean all

# get lightning stack files
git clone https://github.com/jrosco/lightning-node.git /opt/lightning-node
cd /opt/lightning-node && source bin/init.sh

# mount btcd and lnd data volume (create vol in sf region)
BTCDATADIR=/home/bitcoin/mainnet/
mkdir -p ${BTCDATADIR}
echo "/dev/disk/by-id/scsi-0DO_Volume_volume-sfo2-01 ${BTCDATADIR} ext4 defaults,nofail,discard 0 0" | sudo tee -a /etc/fstab
mount -a

# setup other files
cp /opt/lightning-node/conf/bash_aliases ~/.bash_aliases

# get a list of lnd peers
# lnd-cli listnodes| grep 'nodeid\|\"address\":\|port' | awk {'print $2'} | cut -d\" -f 2