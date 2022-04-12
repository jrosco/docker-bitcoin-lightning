RUNAS=${RUNAS:=bitcoin}
MNTVOL=${MNTVOL:='/home/bitcoin/mainnet'}
DEVICE=${DEVICE:='/dev/sda'}
BTCIMAGE=${BTCIMAGE:='jr0sco/bitcoind'}
BTCNAME=${BTCNAME:=bitcoind}
BTCIMAGE=${BTCDIMAGE:='jr0sco/btcd'}
BTCNAME=${BTCDNAME:=btcd}
LNDIMAGE=${LNDIMAGE:='jr0sco/lnd'}
LNDNAME=${LNDNAME:=lightning}
ELECXNAME=${ELECXNAME:=electrumx}
ELECXIMAGE=${ELECXIMAGE:='jr0sco/electrumx'}
APPDIR=${APPDIR:='/opt/lightning-node'}

mkdir -p ${MNTVOL}/${LNDNAME}
mkdir -p ${MNTVOL}/${BTCNAME}
mkdir -p ${MNTVOL}/${ELECXNAME}

function checkmountpoint() {
    mountpoint ${MNTVOL} || exit
}

function waitforblock() {
    while true; do
        LOCALBLK=$(docker exec -it ${BTCNAME} su ${RUNAS} -c "bitcoin-cli getblockchaininfo|grep blocks|cut -d: -f2|cut -d, -f1| tr -d '[:space:]'")
        CURRENTBLK=$(curl -s https://blockchain.info/q/getblockcount)
        test -z ${LOCALBLK} && LOCALBLK=0
        if [ ${LOCALBLK} == ${CURRENTBLK} ]; then
            echo "blocks synced ${LOCALBLK}/${CURRENTBLK}"
            break;
        else
            echo "waiting for blocks to sync ${LOCALBLK}/${CURRENTBLK}"
            sleep 3
        fi
    done
}
