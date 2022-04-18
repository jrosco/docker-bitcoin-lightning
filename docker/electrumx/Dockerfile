FROM python:3.9.12-slim-buster

ARG VERSION=1.16.0

WORKDIR /home/electrumx

# https://electrumx.readthedocs.io/en/latest/environment.html#envvar-COIN
ENV COIN BitcoinSegwit
# https://electrumx.readthedocs.io/en/latest/environment.html#envvar-NET
ENV NET testnet
# https://electrumx.readthedocs.io/en/latest/environment.html#envvar-DAEMON_URL
ENV DAEMON_URL bitcoin:password@127.0.0.1:18332
# https://electrumx.readthedocs.io/en/latest/environment.html#envvar-DB_DIRECTORY
ENV DB_DIRECTORY /home/electrumx
# https://electrumx.readthedocs.io/en/latest/environment.html#envvar-SERVICES
ENV SERVICES tcp://localhost:50001

RUN set -ex \
    && apt-get update \
    && apt-get install -y -qq --no-install-recommends \
      build-essential libc6-dev \
      libncurses5-dev libncursesw5-dev \
      libreadline6-dev \
      libleveldb-dev \
      git \
    && rm -rf /var/cache/apt/

RUN set -ex \
    && git clone https://github.com/spesmilo/electrumx /opt/electrumx \
    && cd /opt/electrumx \
    && git checkout tags/${VERSION} \
    && python3 setup.py install

RUN set -ex \
    && groupadd -r electrumx \
    && useradd -r -m -g electrumx electrumx

RUN set -ex \
    && apt-get -y remove \
      build-essential \
      git

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# EXPOSE 50002
ENTRYPOINT [ "/entrypoint.sh" ]
