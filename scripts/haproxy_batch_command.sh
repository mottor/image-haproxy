#!/bin/bash
# https://cbonte.github.io/haproxy-dconv/1.7/management.html

RAW_COMMAND=${1}
DELIMITER=${2:-;}

if [ "$RAW_COMMAND" == "" ]; then
  echo "ERROR: need 1st argument - commands list, delimited by '$DELIMITER'"
  exit 1
fi

IFS="$DELIMITER" read -ra COMMANDS_LIST <<< "$RAW_COMMAND"

for ONE_COMMAND in "${COMMANDS_LIST[@]}"; do
  ONE_COMMAND=$(echo $ONE_COMMAND | sed 's/(^\s+|\s+$)//')
  if [ "$ONE_COMMAND" != "" ]; then
    echo "exec: $ONE_COMMAND"
    echo "$ONE_COMMAND" | socat stdio /var/lib/haproxy/admin.sock
  fi
done
