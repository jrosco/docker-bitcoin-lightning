FROM debian:bullseye-slim

ARG PLATFORM=x86_64-linux-gnu
ARG BITCOIN_VERSION=22.0
ARG USER_ID=1000
ARG PGP_KEY_SERVER=hkps://keyserver.ubuntu.com
ARG RELEASE_PGP_SIGNATURE="\
    0CCBAAFD76A2ECE2CCD3141DE2FFD5B1D88CA97D \
    152812300785C96444D3334D17565732E08E5E41 \
    0AD83877C1F0CD1EE9BD660AD7CC770B81FD22A8 \
    590B7292695AFFA5B672CBB2E13FC145CD3F4304 \
    28F5900B1BB5D1A4B6B6D1A9ED357015286A333D \
    637DB1E23370F84AFF88CCE03152347D07DA627C \
    CFB16E21C950F67FA95E558F2EEB9F5CC09526C1 \
    6E01EEC9656903B0542B8F1003DB6322267C373B \
    D1DBF2C4B96F2DEBF4C16654410108112E7EA81F \
    82921A4B88FD454B7EB8CE3C796C4109063D4EAF \
    9DEAE0DC7063249FB05474681E4AED62986CD25D \
    9D3CC86A72F8494342EA5FD10A41BDC3F4FAFF1C \
    74E2DEF5D77260B98BC19438099BAD163C70FBFA \
    "

ENV BITCOIN_ARCHIVE=bitcoin-${BITCOIN_VERSION}-${PLATFORM}.tar.gz
ENV DATA_DIR=/home/bitcoin/.bitcoin

WORKDIR $DATA_DIR

# install required packages
RUN set -ex \
    && apt-get update \
    && apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu gnupg wget procps \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && apt-get autoclean

# add bitcoin version as integer to file in container
RUN echo ${BITCOIN_VERSION} | sed -e s/\\.//g > /version

# import pgp signature keys 
RUN set -ex \
    && for k in ${RELEASE_PGP_SIGNATURE}; do \
      gpg --keyserver ${PGP_KEY_SERVER} --recv-keys ${k}; \
    done

# download bitcoin and verify
RUN set -ex \
    && cd /tmp \
    && wget -q https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/${BITCOIN_ARCHIVE} \
    && wget -q https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/SHA256SUMS.asc \
    && \
      if [ $(cat /version) -gt 0212 ]; then \
        wget -q https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/SHA256SUMS \
          && SHA256=$(grep "${BITCOIN_ARCHIVE}" SHA256SUMS | awk '{print $1}'); \
      else \
        SHA256=$(grep "${BITCOIN_ARCHIVE}" SHA256SUMS.asc | awk '{print $1}'); \
      fi \
    && echo "${SHA256} ${BITCOIN_ARCHIVE}" | sha256sum -c - \
    && gpg --no-tty --verify SHA256SUMS.asc

# install bitcoin binaries
RUN set -ex \
    && cd /tmp \
    && tar -xzf ${BITCOIN_ARCHIVE} -C /usr/local --strip-components=1 --exclude=*-qt \
    && bitcoind --version \
    && test -e /usr/local/bin/test_bitcoin && /usr/local/bin/test_bitcoin --show_progress \
    || echo "no test cases found"

# cleanup files 
RUN set -ex \
    && rm -rf /tmp/* \
    && apt-get remove wget gnupg --yes || apt-get autoremove --yes \

# create user and data directory
RUN set -ex \
    && adduser --disabled-password --uid ${USER_ID} bitcoin --quiet

ADD docker-entrypoint.sh /

VOLUME /data

# mainnet and testnet ports (rpc, http)
EXPOSE 8332 8333 18332 18333

# mainnet and testnet zmq interfaces (block, tx)
EXPOSE 28332 28333

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/sh", "-c", "bitcoind", "-datadir=$DATA_DIR"]
