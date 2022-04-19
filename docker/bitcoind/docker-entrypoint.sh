#!/bin/bash

set -e

TESTNET=${TESTNET:="1"}
SELF_MANAGED=${SELF_MANAGED:="true"}

# Set testnet section configs
if [[ "${TESTNET}" == "1" ]]; then
  OPTS=$(echo -e "[test]\nrpcport=${RPC_PORT:-18332} \
    \nrpcbind=${RPC_BIND:-"127.0.0.1"}"
    )
else
  OPTS=$(echo -e "rpcport=${RPC_PORT:-8332} \
    \nrpcbind=${RPC_BIND:-"127.0.0.1"}"
    )
fi

if [[ ! -s "$DATA_DIR/bitcoin.conf" || ${SELF_MANAGED} == "false" ]]; then
    touch "$DATA_DIR/bitcoin.conf"
cat <<-EOF > "$DATA_DIR/bitcoin.conf"
# This file was created by Docker.
# You can override this file with your changes.
# To override this file set SELF_MANAGED=true via docker envs
printtoconsole=1
debug=${DEBUG:-0}
server=${SERVER:-1}
listen=${LISTEN:-1}
testnet=${TESTNET}
rpcallowip=${RPC_ALLOWED:-127.0.0.1}
rpcpassword=${RPC_PASSWORD:-password}
rpcuser=${RPC_USER:-bitcoin}
txindex=${TX_INDEX:-0}
blockfilterindex=${BLOCK_FILTER_INDEX:-0}
zmqpubrawblock=${ZEROMQ_BLOCK_URL:-"tcp://127.0.0.1:28000"}
zmqpubhashblock=${ZEROMQ_BLOCK_URL:-"tcp://127.0.0.1:28000"}
zmqpubrawtx=${ZEROMQ_TX_URL:-"tcp://127.0.0.1:29000"}
zmqpubhashtx=${ZEROMQ_TX_URL:-"tcp://127.0.0.1:29000"}
${OPTS}
EOF
  chown -R bitcoin:bitcoin "$DATA_DIR"
fi

exec gosu bitcoin "$@"
