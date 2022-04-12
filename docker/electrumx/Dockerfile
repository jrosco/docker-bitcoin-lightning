FROM python:3.6.7-slim

ENV VERSION 1.9.3

# https://electrumx.readthedocs.io/en/latest/environment.html#envvar-COIN
ENV COIN BitcoinSegwit
# https://electrumx.readthedocs.io/en/latest/environment.html#envvar-NET
ENV NET testnet
# https://electrumx.readthedocs.io/en/latest/environment.html#envvar-DB_DIRECTORY
ENV DAEMON_URL bitcoin:password@127.0.0.1
# https://electrumx.readthedocs.io/en/latest/environment.html#envvar-DAEMON_URL
ENV DB_DIRECTORY /home/electrumx
# https://electrumx.readthedocs.io/en/latest/environment.html#envvar-RPC_HOST
ENV RPC_HOST 127.0.0.1
# https://electrumx.readthedocs.io/en/latest/environment.html#envvar-RPC_PORT
ENV RPC_PORT 8000

RUN groupadd -r electrumx && useradd -r -m -g electrumx electrumx

RUN apt update && \
        apt install -y \
        build-essential libc6-dev \
        libncurses5-dev libncursesw5-dev \
        libreadline6-dev \
        libleveldb-dev \
        git && \
    rm -rf /var/cache/apt/

RUN pip3 install plyvel

RUN git clone https://github.com/kyuupichan/electrumx.git /opt/electrumx \
    && cd /opt/electrumx \
    && git checkout tags/${VERSION} \
    && python3 setup.py install

ADD docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 8000
ENTRYPOINT [ "/docker-entrypoint.sh" ]