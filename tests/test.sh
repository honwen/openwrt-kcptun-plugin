#!/bin/sh

set -e

TS=$(date '+%s')
SCRIPTPATH="$(
  cd -- "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)"

# single port
sed 's+./src/kcptun+kcptun-plugin+g' ${SCRIPTPATH}/client.json >/tmp/client.$TS.json
sed 's+./src/kcptun+kcptun-plugin+g' ${SCRIPTPATH}/server.json >/tmp/server.$TS.json

sed "s+crypt+key=$TS;crypt+g; s+port-upper=[^;]*;++g" -i /tmp/client.$TS.json /tmp/server.$TS.json

docker rm -f test-server test-client >/dev/null 2>&1
docker run -d --name test-server -v=/tmp/server.$TS.json:/var/config.json:ro -v=$(dirname $SCRIPTPATH)/src/kcptun:/usr/bin/kcptun:ro -p 54321:54321/udp chenhw2/ss-obfs sh -c "ssserver \$ARGS"
docker run -d --name test-client -v=/tmp/client.$TS.json:/var/config.json:ro -v=$(dirname $SCRIPTPATH)/src/kcptun:/usr/bin/kcptun:ro --network=host chenhw2/ss-obfs sh -c "sslocal \$ARGS"
sleep 1

echo "# Test 00:"
curl --socks5-hostname 127.0.0.1:1080 --max-time 1 --retry 5 ifconfig.cc
ret00="$?"
echo
echo "# Test 01:"
curl --socks5-hostname 127.0.0.1:1080 --max-time 1 --retry 5 ifconfig.co
ret01="$?"

docker logs test-server
docker logs test-client
docker rm -f test-server test-client >/dev/null 2>&1
rm -f /tmp/client.$TS.json /tmp/server.$TS.json

# multi port
sed 's+./src/kcptun+kcptun-plugin+g' ${SCRIPTPATH}/client.json >/tmp/client.$TS.json
sed 's+./src/kcptun+kcptun-plugin+g' ${SCRIPTPATH}/server.json >/tmp/server.$TS.json

sed "s+crypt+key=$TS;crypt+g" -i /tmp/client.$TS.json /tmp/server.$TS.json

docker rm -f test-server test-client >/dev/null 2>&1
docker run -d --name test-server -v=/tmp/server.$TS.json:/var/config.json:ro -v=$(dirname $SCRIPTPATH)/src/kcptun:/usr/bin/kcptun:ro -p=54321-54333:54321-54333/udp chenhw2/ss-obfs sh -c "ssserver \$ARGS"
docker run -d --name test-client -v=/tmp/client.$TS.json:/var/config.json:ro -v=$(dirname $SCRIPTPATH)/src/kcptun:/usr/bin/kcptun:ro --network=host chenhw2/ss-obfs sh -c "sslocal \$ARGS"
sleep 1

echo "# Test 10:"
curl --socks5-hostname 127.0.0.1:1080 --max-time 1 --retry 5 ifconfig.cc
ret10="$?"
echo
echo "# Test 11:"
curl --socks5-hostname 127.0.0.1:1080 --max-time 1 --retry 5 ifconfig.co
ret11="$?"

docker logs test-server
docker logs test-client
docker rm -f test-server test-client >/dev/null 2>&1
rm -f /tmp/client.$TS.json /tmp/server.$TS.json

if [ "V${ret00}${ret10}${ret10}${ret11}" = "V0000" ]; then
  echo "# Test: OK"
else
  echo "# Test: Failed"
  exit 1
fi
