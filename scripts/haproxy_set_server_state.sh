#!/bin/bash

BACKEND="$1"
SERVER="$2"
STATE="$3"

if [ "$BACKEND" == "" ]; then
  echo "ERROR: Need 1st argument - backend name"
  exit 1
fi

if [ "$SERVER" == "" ]; then
  echo "ERROR: Need 2nd argument - server name"
  exit 1
fi

if [ "$STATE" == "" ]; then
  echo "ERROR: Need 3rd argument - STATE"
  exit 1
fi

echo "set server $BACKEND/$SERVER state $STATE" | socat stdio /var/lib/haproxy/admin.sock
