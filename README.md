# Bitcoin/Lightning Dockerfile

Repo for spinning up your own Bitcoin and Lightning Standalone Docker Containers (bitcoind, lnd, neutrino)

_N.B Testnet is enabled by default._

Bitcoin (bitcoind) Container 
---
See [Dockerfile](./docker/bitcoind/Dockerfile)
### Dockerfile Argument Values
|Key|Default Values|Info|Required|Editable|
|---|---|---|---|---|
|BITCOIN_VERSION|n/a|Bitcoin version to use [Support Versions](conf/supported_versions/bitcoind.txt)|yes|yes|
|USER_ID|`1000`|The run container as bitcoin UID. Make this the same as the local directory UID permissions|no|yes|
|PGP_KEY_SERVER|`hkps://keyserver.ubuntu.com`|OpenPGP [keyserver](https://keyserver.ubuntu.com) |no|yes
|RELEASE_PGP_SIGNATURE|"`71A3B16735405025D447E8F274810B012346C9A6 01EA5486DE18A882D4C2684590C8019E36C2E964`"|The releases PGP key IDs ([see](https://raw.githubusercontent.com/bitcoin/bitcoin/master/contrib/builder-keys/keys.txt))|no|yes|

### Container Environment Values
-----
|Key|Default Values|Info|
|---|---|---|
|DEBUG|`0`|Enable/Disable Debug logging mode|
|SELF_MANAGED|`true`|When `true` the bitcoin.conf is self managed, if `false` file is controlled by Docker|
|BITCOIN_RPC_ALLOWED|`127.0.0.1`|RPC Whitelist IPs addresses|
|BITCOIN_RPC_USER|`bitcoin`|The Bitcoin RPC user|
|BITCOIN_RPC_PASSWORD|`password`|The Bitcoin RPC password|
|BITCOIN_RPC_PORT|`18332`|Bitcoin RPC Port|
|BITCOIN_RPC_BIND|`127.0.0.1`|RPC BIND address|
|BITCOIN_SERVER|`1`|Enable/Disable Bitcoin server|
|LISTEN|`1`|Enable/Disable bitcoin to listen|
|BITCOIN_TESTNET|`1`|Enable/Disable testnet|
|ZMQ_PUB_RAW_TX|`tcp://127.0.0.1:28332`|The ZeroMQ raw publisher transactions URL|
|ZMQ_PUB_RAW_BLK|`tcp://127.0.0.1:28333`|The ZeroMQ raw publisher blocks URL|
---
### Docker Build
---
```bash
docker build --build-arg BITCOIN_VERSION=0.16.3 -t bitcoind .
```
Build with different UID
```bash
docker build --build-arg USER_ID=1001 --build-arg BITCOIN_VERSION=0.16.3 -t bitcoind .
```
---
Run bitcoind with DEBUG enabled

```bash
docker run --name bitcoind \
    -e DEBUG=1 \
    -v $(pwd):/data \
    -p 127.0.0.1:18332:18332 \
    -p 127.0.0.1:28332:28332 \
    -p 127.0.0.1:28333:28333 \
    bitcoind
```

Lightning (lnd) Container
---
See [Dockerfile](./docker/lnd/Dockerfile)
### Dockerfile Argument Values
|Key|Default Values|Info|
|---|---|---|
|LND_VERSION|v0.5.2-beta|Lightning version to use|
|USER_ID|1000|The run container as bitcoin UID. Make this the same as the local directory UID permissions|

### Container Environment Values

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

### Docker Build
---

```bash
docker build -t lnd .
```
Build with differnet Lightning version
```bash
docker build --build-arg LND_VERSION=v0.5-beta -t lnd .
```
Build with different UID
```bash
docker build --build-arg USER_ID=1001 -t lnd .
```
---
Run Lightning with Bitcoin Backend

```bash
docker run --rm --name lnd --network container:bitcoind -d \
    -v {local.bitcoin.dir}:/data \
    -v :/data/.lnd \
    lnd
```
Run Lightning with Neutrino Backend

```bash
docker run --rm --name lnd -d \
    -e BACKEND=neutrino \
    -v {local.lightning.dir}:/data \
    -v :/data/.lnd \
    lnd
```

Build you own LND certificate:

---

```bash
cd ~/.lnd
openssl ecparam -genkey -name prime256v1 -out tls.key
openssl req -new -sha256 -key tls.key -out csr.csr -subj '/CN=localhost/O=lnd'
openssl req -x509 -sha256 -days 36500 -key tls.key -in csr.csr -out tls.cert
rm csr.csr
```
