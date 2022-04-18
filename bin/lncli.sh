#!/bin/sh

docker exec -it -u bitcoin lnd lncli "$@"
