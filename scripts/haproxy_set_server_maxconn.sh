#!/bin/bash
# https://cbonte.github.io/haproxy-dconv/1.7/management.html

BACKEND=${1}
SERVER_NAME=${2}
MAXCONN_VALUE=${3}

echo "set maxconn server $BACKEND/$SERVER_NAME $MAXCONN_VALUE" | socat stdio /var/lib/haproxy/admin.sock
