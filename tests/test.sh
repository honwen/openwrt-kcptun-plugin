#!/bin/sh

set -e

TS=$(date '+%s')
SCRIPTPATH="$(
  cd -- "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)"

sed 's+./src/kcptun+kcptun-plugin+g' ${SCRIPTPATH}/client.json >/tmp/client.$TS.json
sed 's+./src/kcptun+kcptun-plugin+g' ${SCRIPTPATH}/server.json >/tmp/server.$TS.json

docker rm -f test-server test-client >/dev/null 2>&1
docker run -d --name test-server -v=/tmp/server.$TS.json:/var/config.json:ro -v=$(dirname $SCRIPTPATH)/src/kcptun:/usr/bin/kcptun:ro -p 54321:54321/udp chenhw2/ss-obfs sh -c "ssserver \$ARGS"
docker run -d --name test-client -v=/tmp/client.$TS.json:/var/config.json:ro -v=$(dirname $SCRIPTPATH)/src/kcptun:/usr/bin/kcptun:ro --network=host chenhw2/ss-obfs sh -c "sslocal \$ARGS"
sleep 1

echo "# Test 0:"
curl --socks5-hostname 127.0.0.1:1080 ifconfig.cc
ret0="$?"
echo
echo "# Test 1:"
curl --socks5-hostname 127.0.0.1:1080 ifconfig.co
ret1="$?"

docker logs test-server
docker logs test-client
docker rm -f test-server test-client >/dev/null 2>&1
rm -f /tmp/client.$TS.json /tmp/server.$TS.json

if [ "V$ret0" = "V0" -a "V$ret1" = "V0" ]; then
  echo "# Test: OK"
else
  echo "# Test: Failed"
  exit 1
fi
