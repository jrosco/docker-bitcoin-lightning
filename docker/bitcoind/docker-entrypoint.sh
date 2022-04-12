#!/bin/bash

set -e

DATA_DIR=/data
BITCOIN_TESTNET=${BITCOIN_TESTNET:="1"}

# Set testnet section configs
if [[ "${BITCOIN_TESTNET}" == "1" ]]; then
  RPC_PORT=$(echo -e "[test]\nrpcport=${BITCOIN_RPC_PORT:-18332}")
else
  RPC_PORT="rpcport=${BITCOIN_RPC_PORT:-8332}"
fi

if [[ ! -s "${DATA_DIR}/bitcoin.conf" ]]; then
    touch ${DATA_DIR}/bitcoin.conf
cat <<-EOF > ${DATA_DIR}/bitcoin.conf
printtoconsole=1
rpcallowip=${BITCOIN_RPC_ALLOWED:-127.0.0.1}
rpcpassword=${BITCOIN_RPC_PASSWORD:-password}
rpcuser=${BITCOIN_RPC_USER:-bitcoin}
server=${BITCOIN_SERVER:-1}
listen=${LISTEN:-1}
testnet=${BITCOIN_TESTNET}
zmqpubrawblock=${ZMQ_PUB_RAW_BLK:-"tcp://127.0.0.1:28333"}
zmqpubrawtx=${ZMQ_PUB_RAW_TX:-"tcp://127.0.0.1:28332"}
${RPC_PORT}
EOF
    chown -R bitcoin:bitcoin ${DATA_DIR}
fi

exec gosu bitcoin "$@"

