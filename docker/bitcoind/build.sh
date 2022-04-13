#!/bin/sh

VERSION="$1"
BASE_IMAGE_OS="debian_bullseye"

docker build --build-arg BITCOIN_VERSION="${VERSION}" -t bitcoind .

docker tag bitcoind jr0sco/bitcoind:"${BASE_IMAGE_OS}-bitcoind_${VERSION}"
docker push jr0sco/bitcoind:"${BASE_IMAGE_OS}-bitcoind_${VERSION}"
