#!/usr/bin/env sh

# exit from script if error was raised.
set -e

# Set default variables if needed.
BITCOIN_RPC_HOST=${BITCOIN_RPC_HOST:-localhost}
BITCOIN_RPC_USER=${BITCOIN_RPC_USER:-bitcoin}
BITCOIN_RPC_PASSWORD=${BITCOIN_RPC_PASSWORD:-password}
DEBUG=${DEBUG:-info}
NETWORK=${NETWORK:-testnet}
CHAIN=${CHAIN:-bitcoin}
BACKEND=${BACKEND:-bitcoind}
ZMQ_PUB_RAW_TX=${ZMQ_PUB_RAW_TX:-"tcp://127.0.0.1:28332"}
ZMQ_PUB_RAW_BLK=${ZMQ_PUB_RAW_BLK:-"tcp://127.0.0.1:28333"}
LIGHTNING_DATA=${LIGHTNING_DATA:-"/data/.lnd"}

COMMON_PARAMS=$(echo \
    "--${CHAIN}.active" \
    "--${CHAIN}.${NETWORK}" \
    "--${CHAIN}.node=${BACKEND}" \
    "--debuglevel=${DEBUG}" \
    "--lnddir=${LIGHTNING_DATA}" \
    "--configfile=${LIGHTNING_DATA}/lnd.conf"
)

if echo ${BACKEND}|grep -q 'bitcoind\|btcd\|litecoind\|ltcd'; then
    BITCOIN_PARAMS=$(echo \
    "--${BACKEND}.rpchost=${BITCOIN_RPC_HOST}" \
    "--${BACKEND}.rpcuser=${BITCOIN_RPC_USER}" \
    "--${BACKEND}.rpcpass=${BITCOIN_RPC_PASSWORD}" \
    "--${BACKEND}.dir=/data/"
    )
fi

if echo ${BACKEND}|grep -q 'bitcoind\|litecoind'; then
    ZMQ_PARAMS=$(echo \
    "--${BACKEND}.zmqpubrawblock=${ZMQ_PUB_RAW_TX}" \
    "--${BACKEND}.zmqpubrawtx=${ZMQ_PUB_RAW_BLK}" \
    )
fi

if [[ ! -s "${LIGHTNING_DATA}/lnd.conf" ]]; then
    mkdir -p ${LIGHTNING_DATA}; touch ${LIGHTNING_DATA}/lnd.conf
cat <<-EOF > "${LIGHTNING_DATA}/lnd.conf"
    [Application Options]
    maxpendingchannels=5

    [autopilot]
    autopilot.active=0
    autopilot.maxchannels=5
    autopilot.allocation=0.6
EOF
    chown -R bitcoin:bitcoin "${LIGHTNING_DATA}/"
fi

su bitcoin -c "lnd ${COMMON_PARAMS} \
    ${BITCOIN_PARAMS} \
    ${ZMQ_PARAMS} \
    $@"
