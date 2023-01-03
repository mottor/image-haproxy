#!/bin/sh

BACKEND="$1"
SERVER="$2"
WEIGHT="$3"
echo "set weight $BACKEND/$SERVER $WEIGHT" | socat stdio /var/lib/haproxy/admin.sock
