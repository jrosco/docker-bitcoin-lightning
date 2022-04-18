#!/bin/sh

docker exec -it -u bitcoin bitcoind bitcoin-cli "$@"
