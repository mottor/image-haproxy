#!/bin/bash
# https://cbonte.github.io/haproxy-dconv/1.7/management.html

MAXCONN_VALUE=${1}

echo "set maxconn global $MAXCONN_VALUE" | socat stdio /var/lib/haproxy/admin.sock
