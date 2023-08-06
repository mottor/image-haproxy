#!/bin/bash
# https://cbonte.github.io/haproxy-dconv/1.7/management.html

FRONTEND=${1}
MAXCONN_VALUE=${2}

echo "set maxconn frontend $FRONTEND $MAXCONN_VALUE" | socat stdio /var/lib/haproxy/admin.sock
