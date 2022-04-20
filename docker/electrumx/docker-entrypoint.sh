#!/bin/bash

ulimit -n 10000

# https://electrumx.readthedocs.io/en/latest/environment.html#envvar-TOR_PROXY_HOST
test ! -z "$TOR_PROXY_HOST" && export TOR_PROXY_HOST=$TOR_PROXY_HOST
# https://electrumx.readthedocs.io/en/latest/environment.html#envvar-TOR_PROXY_PORT
test ! -z "$TOR_PROXY_PORT" && export TOR_PROXY_PORT=$TOR_PROXY_PORT

test -e "/home/${USERNAME}/electrumx.env" \
  && . "/home/${USERNAME}/electrumx.env"

cd /opt/electrumx/ || exit 1

su "${USERNAME}" -c ". venv/bin/activate"

su "${USERNAME}" -c "venv/bin/python3 electrumx_server $@"

