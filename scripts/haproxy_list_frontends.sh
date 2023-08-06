#!/bin/bash
# https://cbonte.github.io/haproxy-dconv/1.7/management.html

echo "show stat" | socat stdio /var/lib/haproxy/admin.sock | grep ",FRONTEND," | sed 's/,FRONTEND,.*//'
