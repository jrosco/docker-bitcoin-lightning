# Bitcoin/Lightning Dockerfile

Repo for spinning up your own Bitcoin and Lightning Standalone Docker Containers (bitcoind, lnd, neutrino)

_**N.B Testnet is enabled by default**_

## Bitcoin (bitcoind) Container

---
See [Dockerfile](./docker/bitcoind/Dockerfile)

### Dockerfile Argument Values - bitcoind

|Key|Default Values|Info|Required|Editable|
|---|---|---|---|---|
|PLATFORM|`x86_64-linux-gnu`|The containers OS platform (included in the bitcoin archive files)|no|no|
|BITCOIN_VERSION|`22.0`|Bitcoin version to use [Support Versions](conf/supported_versions/bitcoind.txt)|no|yes|
|USER_ID|`1000`|The run container as bitcoin UID. Make this the same as the local directory UID permissions|no|yes|
|PGP_KEY_SERVER|`hkps://keyserver.ubuntu.com`|OpenPGP [keyserver](https://keyserver.ubuntu.com) |no|yes
|RELEASE_PGP_SIGNATURE|[release keys](https://raw.githubusercontent.com/bitcoin/bitcoin/master/contrib/builder-keys/keys.txt)|The releases PGP key IDs ([see](https://raw.githubusercontent.com/bitcoin/bitcoin/master/contrib/builder-keys/keys.txt))|no|yes|

### Container Environment Values - bitcoind

---
|Key|Default Values|Info|
|---|---|---|
|DEBUG|`0`|Enable/Disable Debug logging mode|
|LISTEN|`1`|Enable/Disable bitcoin to listen|
|SERVER|`1`|Enable/Disable Bitcoin server|
|TESTNET|`1`|Enable/Disable testnet|
|SELF_MANAGED|`true`|When `true` the bitcoin.conf is self managed, if `false` file is controlled by Docker|
|RPC_ALLOWED|`127.0.0.1`|RPC Whitelist IPs addresses|
|RPC_USER|`bitcoin`|The Bitcoin RPC user|
|RPC_PASSWORD|`password`|The Bitcoin RPC password (_**IMPORTANT: ensure you update this**_)|
|RPC_PORT|`18332`|Bitcoin RPC Port|
|RPC_BIND|`127.0.0.1`|RPC BIND address|
|TX_INDEX|`0`|Maintain a full transaction index|
|BLOCK_FILTER_INDEX|`0`|Store and retrieve block filters, hashes, and headers|
|ZMQ_PUB_RAW_TX|`tcp://127.0.0.1:28332`|The ZeroMQ raw publisher transactions URL|
|ZMQ_PUB_RAW_BLK|`tcp://127.0.0.1:28333`|The ZeroMQ raw publisher blocks URL|11
---

### Docker Build - bitcoind

---
Build latest version

```bash
docker build -t bitcoind .
```

Build older versions `<=0.21.2` (old [release key](https://raw.githubusercontent.com/bitcoin-dot-org/Bitcoin.org/master/laanwj-releases.asc))

See [supported versions](conf/supported_versions/bitcoind.txt)

```bash
docker build \
  --build-arg BITCOIN_VERSION=0.16.3 \
  --build-arg RELEASE_PGP_SIGNATURE=01EA5486DE18A882D4C2684590C8019E36C2E964 \
  -t bitcoind .
```

Build with different UID

```bash
docker build --build-arg USER_ID=1001 -t bitcoind .
```

### Docker Create Volume - bitcoind

---
Create a persistent volume

```bash
docker volume create --name bitcoind
```

See volume details

```bash
docker volume inspect bitcoind
```

### Docker Run - bitcoind

Run bitcoind with persistent volume

```bash
docker run -it --name bitcoind \
    -v bitcoind:/home/bitcoin \
    -p 127.0.0.1:18332:18332 \
    -p 127.0.0.1:28332:28332 \
    -p 127.0.0.1:28333:28333 \
    bitcoind
```

## Lightning (lnd) Container

---
See [Dockerfile](./docker/lnd/Dockerfile)

### Dockerfile Argument Values - lnd

|Key|Default Values|Info|Required|Editable|
|---|---|---|---|---|
|PLATFORM|`linux-amd64`|The containers OS platform|no|no|
|LND_VERSION|`v0.13.3-beta`|Lightning version to use|no|yes|
|USER_ID|`1000`|The run container as bitcoin UID. Make this the same as the local directory UID permissions|no|yes|
|RELEASE_PGP_KEY|[roasbeef.asc](https://raw.githubusercontent.com/lightningnetwork/lnd/master/scripts/keys/roasbeef.asc)|The PGP key ID (info found on releases [page](https://github.com/lightningnetwork/lnd/releases))|no|yes|
|RELEASE_SIG_KEY_FILE|`manifest-roasbeef-${LND_VERSION}.sig`|The signed key used with release (info found on releases [page](https://github.com/lightningnetwork/lnd/releases))|no|yes|

### Container Environment Values - lnd


|Key|Default Values|Info|
|---|---|---|
|BITCOIN_RPC_USER|bitcoin|The Bitcoin RPC user|
|BITCOIN_RPC_PASSWORD|password |The Bitcoin RPC password|
|DEBUG|info|Logging level|
|NETWORK|testnet|Which network to use (testnet,simnet,mainnet)|
|CHAIN|bitcoin|Which blockchain to use (bitcoin,litecoin)|
|BACKEND|bitcoind|Which backend to use (bitcoind,btcd,litecoind,ltcd,neutrino )|
|ZMQ_PUB_RAW_TX|tcp://127.0.0.1:28332|The ZeroMQ raw publisher transactions URL|
|ZMQ_PUB_RAW_BLK|tcp://127.0.0.1:28333|The ZeroMQ raw publisher blocks URL|
|LIGHTNING_DATA|/data/.lnd|The Lightning .lnd directory location|

### Docker Build - lnd

---
Build latest version

```bash
docker build -t lnd .
```

Build with differnet Lightning version

```bash
docker build --build-arg LND_VERSION=v0.12.1-beta -t lnd .
```

Build with different UID

```bash
docker build --build-arg USER_ID=1001 -t lnd .
```

### Docker Create Volume - lnd

---
Create a persistent volume

```bash
docker volume create --name lnd
```

See volume details

```bash
docker volume inspect lnd
```

### Docker Run - lnd

Run lnd with bitcoind container

```bash
docker run --rm --name lnd \
    --network container:bitcoind \
    -v lnd:/data \
    lnd
```

Run lnd with neutrino backend

```bash
docker run --rm --name lnd \
    -e BACKEND=neutrino \
    -v lnd:/data \
    lnd
```

Build you own certificates:

---

```bash
cd ~/.lnd
openssl ecparam -genkey -name prime256v1 -out tls.key
openssl req -new -sha256 -key tls.key -out csr.csr -subj '/CN=localhost/O=lnd'
openssl req -x509 -sha256 -days 36500 -key tls.key -in csr.csr -out tls.cert
rm csr.csr
```
