FROM debian:bullseye-slim

ARG BITCOIN_VERSION
ARG USER_ID=1000
ARG PGP_KEY_SERVER=hkps://keyserver.ubuntu.com
ARG RELEASE_PGP_SIGNATURE="71A3B16735405025D447E8F274810B012346C9A6 \
    01EA5486DE18A882D4C2684590C8019E36C2E964"

# install required packages
RUN set -ex \
    && apt-get update \
    && apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu gnupg wget procps \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && apt-get autoclean

# import pgp signature keys 
RUN set -ex \
    && for k in ${RELEASE_PGP_SIGNATURE}; do \
      gpg --keyserver ${PGP_KEY_SERVER} --recv-keys ${k}; \
    done

# install bitcoin binaries
RUN set -ex \
    && BITCOIN_ARCHIVE=bitcoin-${BITCOIN_VERSION}-$(uname -m)-linux-gnu.tar.gz \
    && cd /tmp \
    && wget -q https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/${BITCOIN_ARCHIVE} \
    && wget -q https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/SHA256SUMS.asc \
    && SHA256=`grep "${BITCOIN_ARCHIVE}" SHA256SUMS.asc | awk '{print $1}'` \
    && echo "${SHA256} ${BITCOIN_ARCHIVE}" | sha256sum -c - \
    && gpg --no-tty --verify SHA256SUMS.asc \
    && tar -xzf ${BITCOIN_ARCHIVE} -C /usr/local --strip-components=1 --exclude=*-qt \
    && bitcoind --version

# cleanup files 
RUN set -ex \
    && rm -rf /tmp/* \
    && apt-get remove wget gnupg --yes || apt-get autoremove --yes \

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
