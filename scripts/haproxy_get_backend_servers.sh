#!/bin/sh
# https://cbonte.github.io/haproxy-dconv/1.7/management.html

WANTED_BACKEND="${1:-}"

if [ "$WANTED_BACKEND" == "" ]; then
  echo "ERROR: Need 1st argument = backend name"
  exit 1
fi

STATE=$( echo "show servers state" | socat stdio /var/lib/haproxy/admin.sock )
RES=""

while read -r LINE; do
    # Remove unwanted lines
    [ "$LINE" == "1" ] && continue
    ( echo "$LINE" | grep -Eq "^# " ) && continue

    BACKEND_NAME=$( echo $LINE | cut -d' ' -f 2 )
    [ "$BACKEND_NAME" != "$WANTED_BACKEND" ] && continue

    SRV_NAME=$( echo $LINE | cut -d' ' -f 4 )
    SRV_ADDR=$( echo $LINE | cut -d' ' -f 5 )
    RES="${RES}${SRV_NAME}@${SRV_ADDR};"
done < <(echo -e "$STATE")

echo "$RES" | sed -E 's/[;]+$//g'