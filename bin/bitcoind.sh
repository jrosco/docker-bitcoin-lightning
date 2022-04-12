#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${DIR}/init.sh

ARG=$1

function start() {
    touch ${MNTVOL}/${BTCNAME}/.env
    docker run --rm --name ${BTCNAME} -d \
        --env-file ${MNTVOL}/${BTCNAME}/.env \
        -v ${MNTVOL}/${BTCNAME}:/data/ \
        -p 127.0.0.1:18332:18332 \
        -p 127.0.0.1:28332:28332 \
        -p 127.0.0.1:28333:28333 \
        ${BTCIMAGE}
}

function stop() {
    docker stop ${BTCNAME}
}

function restart() {
    stop; sleep 5; start
}

function status() {
    docker ps -f name=${BTCNAME}
}

case ${ARG} in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    status)
        status
        ;;
    *)
esac
