docker run --rm \
    --name=bitcoind \
    -v bitcoin-data:/home/bitcoin \
    -p 8333:8333 \
    -p 8332:8332 \
    -p 18332:18332 \
    -p 18333:18333 \
    bitcoind bitcoind -testnet -bind=0.0.0.0
