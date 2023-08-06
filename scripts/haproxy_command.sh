#!/bin/bash
# https://cbonte.github.io/haproxy-dconv/1.7/management.html

COMMAND=${1}
echo "$COMMAND" | socat stdio /var/lib/haproxy/admin.sock

