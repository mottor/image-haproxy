#!/bin/bash

BACKEND="$1"
SERVER="$2"
STATE="$3"
echo "enable server $BACKEND/$SERVER" | socat stdio /var/lib/haproxy/admin.sock
