FROM debian:bullseye-slim

ARG BITCOIN_VERSION
ARG USER_ID=1000
ARG RELEASE_PGP=https://raw.githubusercontent.com/bitcoin-dot-org/Bitcoin.org/master/laanwj-releases.asc

RUN set -ex \
    && apt-get update \
    && apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu gpg gpg-agent wget procps \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && apt-get autoclean

# install bitcoin binaries
RUN set -ex \
    && BITCOIN_ARCHIVE=bitcoin-${BITCOIN_VERSION}-$(uname -m)-linux-gnu.tar.gz \
    && cd /tmp \
    && wget -q https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/${BITCOIN_ARCHIVE} \
    && wget -q https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/SHA256SUMS.asc \
    && wget -q "${RELEASE_PGP}" -O releases.asc \
    && SHA256=`grep "${BITCOIN_ARCHIVE}" SHA256SUMS.asc | awk '{print $1}'` \
    && echo "${SHA256} ${BITCOIN_ARCHIVE}" | sha256sum -c - \
    && gpg --no-tty --import ./releases.asc \
    && gpg --no-tty --verify SHA256SUMS.asc \
    && tar -xzf ${BITCOIN_ARCHIVE} -C /usr/local --strip-components=1 --exclude=*-qt \
    && rm -rf /tmp/* \
    && apt-get remove wget gpg-agent --yes || apt-get autoremove --yes \
    && bitcoind --version

# create user and data directory
RUN set -ex \
    && adduser --disabled-password --home /data --uid ${USER_ID} bitcoin --quiet 

ADD docker-entrypoint.sh /

# mainnet and testnet ports (rpc, http)
EXPOSE 8332 8333 18332 18333

# mainnet and testnet zmq interfaces (block, tx)
EXPOSE 28332 28333

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["bitcoind", "-datadir=/data"]
