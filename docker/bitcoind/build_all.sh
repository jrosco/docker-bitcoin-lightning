#!/bin/bash

BASE_IMAGE_OS="debian_bullseye"
PUSH="${1-false}"

for version in $(grep '^[0-9]*\.[0-9]*\.[0-9]*$' ../../conf/supported_versions/bitcoind.txt); do 
	echo "docker build ${version}"
	docker build --build-arg BITCOIN_VERSION="${version}" -t bitcoind .
	docker tag bitcoind jr0sco/bitcoind:"${BASE_IMAGE_OS}-bitcoind_${version}"
	if [[ "${PUSH}" == "true" ]]; then
    docker push jr0sco/bitcoind:"${BASE_IMAGE_OS}-bitcoind_${version}"
  fi
done
