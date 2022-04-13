#!/bin/bash

set -e

DATA_DIR=/data
BITCOIN_TESTNET=${BITCOIN_TESTNET:="1"}
SELF_MANAGED=${SELF_MANAGED:="true"}

# Set testnet section configs
if [[ "${BITCOIN_TESTNET}" == "1" ]]; then
  OPTS=$(echo -e "[test]\nrpcport=${BITCOIN_RPC_PORT:-18332} \
    \nrpcbind=${BITCOIN_RPC_BIND:-"127.0.0.1"}"
    )
else
  OPTS=$(echo -e "rpcport=${BITCOIN_RPC_PORT:-8332} \
    \nrpcbind=${BITCOIN_RPC_BIND:-"127.0.0.1"}"
    )
fi

if [[ ! -s "${DATA_DIR}/bitcoin.conf" || ${SELF_MANAGED} == "false" ]]; then
    touch ${DATA_DIR}/bitcoin.conf
cat <<-EOF > ${DATA_DIR}/bitcoin.conf
# This file was created by Docker.
# You can override this file with your changes.
# To override this file set SELF_MANAGED=true via docker envs
debug=${DEBUG:-0}
printtoconsole=1
rpcallowip=${BITCOIN_RPC_ALLOWED:-127.0.0.1}
rpcpassword=${BITCOIN_RPC_PASSWORD:-password}
rpcuser=${BITCOIN_RPC_USER:-bitcoin}
server=${BITCOIN_SERVER:-1}
listen=${LISTEN:-1}
testnet=${BITCOIN_TESTNET}
zmqpubrawblock=${ZMQ_PUB_RAW_BLK:-"tcp://127.0.0.1:28333"}
zmqpubrawtx=${ZMQ_PUB_RAW_TX:-"tcp://127.0.0.1:28332"}
${OPTS}
EOF
    chown -R bitcoin:bitcoin ${DATA_DIR}
fi

exec gosu bitcoin "$@"

