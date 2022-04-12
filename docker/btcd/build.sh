#!/bin/sh

VERSION="$1"

docker build -t btcd .

docker tag btcd jr0sco/btcd:${VERSION}
docker push jr0sco/btcd:${VERSION}
