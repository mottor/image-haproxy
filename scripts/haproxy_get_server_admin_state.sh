#!/bin/bash
# https://cbonte.github.io/haproxy-dconv/1.7/management.html
CUR_DIR=$( cd $(dirname $0) && pwd )

BACKEND="$1"
SERVER="$2"

if [ "$BACKEND" == "" ]; then
  echo "ERROR: Need 1st argument = backend name"
  exit 1
fi

if [ "$SERVER" == "" ]; then
  echo "ERROR: Need 2nd argument = server name"
  exit 1
fi

STATE=$("${CUR_DIR}/haproxy_show_state.sh" raw)
FOUND=$(echo "$STATE" | grep "^${BACKEND}|${SERVER}|" | wc -l)

if [ "$FOUND" == "1" ]; then
  echo "$STATE" | grep "^${BACKEND}|${SERVER}|" | cut -d'|' -f 5
else
  echo "ERROR: state for ${BACKEND}/${SERVER} - found $FOUND lines, but 1 expected."
  exit 1
fi