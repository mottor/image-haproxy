#!/bin/bash

BACKEND="$1"
SERVER="$2"
STATE="$3"
echo "set server $BACKEND/$SERVER state $STATE" | socat stdio /var/lib/haproxy/admin.sock
