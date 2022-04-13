#!/bin/bash

VERSION="$1"
PUSH="${2-false}"
BASE_IMAGE_OS="debian_bullseye"

docker build --build-arg BITCOIN_VERSION="${VERSION}" -t bitcoind .
docker tag bitcoind jr0sco/bitcoind:"${BASE_IMAGE_OS}-bitcoind_${VERSION}"
if [[ "${PUSH}" == "true" ]]; then
  docker push jr0sco/bitcoind:"${BASE_IMAGE_OS}-bitcoind_${VERSION}"
fi
