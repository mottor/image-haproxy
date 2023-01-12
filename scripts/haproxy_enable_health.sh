#!/bin/bash

BACKEND="$1"
SERVER="$2"

if [ "$BACKEND" == "" ]; then
  echo "ERROR: Need 1st argument - backend name"
  exit 1
fi

if [ "$SERVER" == "" ]; then
  echo "ERROR: Need 2nd argument - server name"
  exit 1
fi

echo "enable health $BACKEND/$SERVER" | socat stdio /var/lib/haproxy/admin.sock
