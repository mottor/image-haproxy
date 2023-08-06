#!/bin/bash
# https://cbonte.github.io/haproxy-dconv/1.7/management.html

echo "show backend" | socat stdio /var/lib/haproxy/admin.sock | grep -vE '^#' | grep -vE '^$'
