FROM python:3.9.12-slim-buster AS builder

ARG VERSION=1.16.0
ARG SSL_EXPIRY=1826
ARG CREATE_SSL=true

# install required packages
RUN set -ex \
    && apt-get update \
    && apt-get install -y -qq --no-install-recommends \
      build-essential libc6-dev \
      libncurses5-dev libncursesw5-dev \
      libreadline6-dev \
      libleveldb-dev \
      git \
    && rm -rf /var/cache/apt/

# clone repo and install
RUN set -ex \
    && git clone https://github.com/spesmilo/electrumx /tmp/electrumx \
    && cd /tmp/electrumx \
    && git checkout tags/${VERSION} \
    && python3 -m venv venv \
    && . venv/bin/activate \
    && python3 setup.py install

# create self signed ssl cert
RUN set -ex \
    && \
    if [ "${CREATE_SSL}" = "true" ]; then \
      mkdir /tmp/ssl \
      && cd /tmp/ssl \
      && openssl genrsa -out electrumx.key 2048 \
      && openssl req -new -key electrumx.key -out electrumx.csr -subj '/CN=localhost/O=electrumx/C=US' \
      && openssl x509 -req -days ${SSL_EXPIRY} -in electrumx.csr -signkey electrumx.key -out electrumx.crt; \
    fi

FROM python:3.9.12-slim-buster

ARG USER_ID=1000

# https://electrumx.readthedocs.io/en/latest/environment.html#envvar-LOG_LEVEL
ENV LOG_LEVEL info
# https://electrumx.readthedocs.io/en/latest/environment.html#envvar-COIN
ENV COIN BitcoinSegwit
# https://electrumx.readthedocs.io/en/latest/environment.html#envvar-NET
ENV NET testnet
# https://electrumx.readthedocs.io/en/latest/environment.html#envvar-DAEMON_URL
ENV DAEMON_URL bitcoin:password@127.0.0.1:18332
# https://electrumx.readthedocs.io/en/latest/environment.html#envvar-DB_DIRECTORY
ENV DB_DIRECTORY /home/electrumx
# https://electrumx.readthedocs.io/en/latest/environment.html#envvar-SERVICES
ENV SERVICES tcp://:50001,ssl://:50002,wss://:50004,rpc://
# https://electrumx.readthedocs.io/en/latest/environment.html#envvar-USERNAME
ENV USERNAME electrumx
# https://electrumx.readthedocs.io/en/latest/environment.html#envvar-PEER_DISCOVERY
ENV PEER_DISCOVERY on
# https://electrumx.readthedocs.io/en/latest/environment.html#envvar-SSL_CERTFILE
ENV SSL_CERTFILE /opt/electrumx/ssl/electrumx.crt
# https://electrumx.readthedocs.io/en/latest/environment.html#envvar-SSL_CERTFILE
ENV SSL_KEYFILE /opt/electrumx/ssl/electrumx.key

WORKDIR /home/${USERNAME}

# create user and group
RUN set -ex \
    && groupadd -g ${USER_ID} -r ${USERNAME} \
    && useradd -r -m -g ${USERNAME} -u ${USER_ID} ${USERNAME}

COPY --from=builder /tmp/ssl /opt/electrumx/ssl
COPY --from=builder /tmp/electrumx/ /opt/electrumx

# change ownership of the ssl cert files
RUN set -ex \
    && chown ${USER_ID}:${USER_ID} \
      /opt/electrumx/ssl/electrumx.crt \
      /opt/electrumx/ssl/electrumx.key

COPY electrumx.env /home/${USERNAME}/electrumx.env

COPY docker-entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 50001 50002 50004

# ENTRYPOINT ["bash"]
ENTRYPOINT [ "/entrypoint.sh" ]
