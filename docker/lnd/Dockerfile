# FROM golang:alpine3.15 as builder
FROM alpine:3.15.4 as builder

ARG LND_VERSION=v0.13.3-beta
ARG PLATFORM=linux-amd64
ARG RELEASE_PGP_KEY=https://raw.githubusercontent.com/lightningnetwork/lnd/master/scripts/keys/roasbeef.asc
ARG RELEASE_SIG_KEY_FILE=manifest-roasbeef-${LND_VERSION}.sig

ENV DOWNLOAD_URL=https://github.com/lightningnetwork/lnd/releases/download

# Install dependencies and install/build lnd.
RUN set -ex \
    && apk add --no-cache --update \
      alpine-sdk \
      curl \
      gnupg

# import pgp keys and checksums
RUN set -ex \
  && curl ${RELEASE_PGP_KEY} | gpg --import

# build lnd via downloads
RUN set -ex \
    && cd /tmp \
    && wget -q ${DOWNLOAD_URL}/${LND_VERSION}/lnd-${PLATFORM}-${LND_VERSION}.tar.gz \
    && wget -q ${DOWNLOAD_URL}/${LND_VERSION}/${RELEASE_SIG_KEY_FILE} \
    && wget -q ${DOWNLOAD_URL}/${LND_VERSION}/manifest-${LND_VERSION}.txt \
    && tar xvf lnd-${PLATFORM}-${LND_VERSION}.tar.gz \
    && lnd-${PLATFORM}-${LND_VERSION}/lnd --version \
    && grep lnd-${PLATFORM}-${LND_VERSION} manifest-${LND_VERSION}.txt | sha256sum -c \
    && gpg --verify *.sig manifest-${LND_VERSION}.txt \
    && mv lnd-${PLATFORM}-${LND_VERSION} lnd/

# Start a new, final image to reduce size
FROM alpine:3.15.4 as final

ARG USER_ID=1000

# Copy the binaries from the builder image.
COPY --from=builder /tmp/lnd/lncli /bin/
COPY --from=builder /tmp/lnd/lnd /bin/

RUN set -ex \
    && addgroup -g ${USER_ID} bitcoin \
    && adduser -u ${USER_ID} -D -G bitcoin -h /data -s /bin/sh bitcoin

# Add bash.
RUN set -ex \
    && apk add --no-cache \
      bash

# Copy the entrypoint script.
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Expose lnd ports (server, rpc).
EXPOSE 9735 10009

ENTRYPOINT ["/docker-entrypoint.sh"]
