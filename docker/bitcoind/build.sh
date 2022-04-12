#!/bin/sh

VERSION="$1"

docker build --build-arg BITCOIN_VERSION=${VERSION} -t bitcoind .

docker tag bitcoind jr0sco/bitcoind:${VERSION}
docker push jr0sco/bitcoind:${VERSION}
