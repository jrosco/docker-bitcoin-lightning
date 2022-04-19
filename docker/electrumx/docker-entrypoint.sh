#!/bin/bash

ulimit -n 10000

test -e "/home/${USERNAME}/electrumx.env" \
  && . "/home/${USERNAME}/electrumx.env"

cd /opt/electrumx/ || exit 1

su "${USERNAME}" -c ". venv/bin/activate"

su "${USERNAME}" -c "venv/bin/python3 electrumx_server $@"

