#!/bin/bash

BACKEND="$1"
SERVER="$2"
WEIGHT="$3"

if [ "$BACKEND" == "" ]; then
  echo "ERROR: Need 1st argument - backend name"
  exit 1
fi

if [ "$SERVER" == "" ]; then
  echo "ERROR: Need 2nd argument - server name"
  exit 1
fi

if [ "$WEIGHT" == "" ]; then
  echo "ERROR: Need 3rd argument - WEIGHT"
  exit 1
fi

echo "set weight $BACKEND/$SERVER $WEIGHT" | socat stdio /var/lib/haproxy/admin.sock
