#!/bin/sh

VERSION="$1"

echo ${VERSION}

docker build --build-arg LND_VERSION=${VERSION} -t lnd .

docker tag jr0sco/lnd jr0sco/lnd:${VERSION}
docker push jr0sco/lnd:${VERSION}
