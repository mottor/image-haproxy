#!/bin/bash
# https://cbonte.github.io/haproxy-dconv/1.7/management.html

IS_RAW="$1"

if [ "$IS_RAW" == "raw" ]; then
  RED=""
  GREEN=""
  YELLOW=""
  BLUE=""
  CYAN=""
  NC=""
else
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  BLUE='\033[0;34m'
  CYAN='\033[0;36m'
  NC='\033[0m' # No Color
fi

TMP_FILE=/tmp/haproxy_state

echo 'Backend_name|Srv_name|Srv_addr|Weight|Admin_state|Healthchecks|Op_state' > $TMP_FILE
echo '------------|--------|--------|------|-----------|------------|--------' >> $TMP_FILE

# Get state from HAproxy
STATE=$( echo "show servers state" | socat stdio /var/lib/haproxy/admin.sock )

echo "$STATE" | while read -r LINE; do
    # Remove unwanted lines
    [ "$LINE" == "1" ] && continue
    ( echo "$LINE" | grep -Eq "^# " ) && continue

    #echo "LINE = $LINE"
    BACKEND_NAME=$( echo $LINE | cut -d' ' -f 2 )
    SRV_NAME=$( echo $LINE | cut -d' ' -f 4 )
    SRV_ADDR=$( echo $LINE | cut -d' ' -f 5 )

    _SRV_OP_STATE=$( echo $LINE | cut -d' ' -f 6 )
    case $_SRV_OP_STATE in
        0) SRV_OP_STATE="${RED}STOPPED${NC}" ;;
        1) SRV_OP_STATE="STARTING" ;;
        2) SRV_OP_STATE="RUNNING" ;;
        3) SRV_OP_STATE="STOPPING" ;;
    esac

    _SRV_ADMIN_STATE=$( echo $LINE | cut -d' ' -f 7 )
    if [ "$_SRV_ADMIN_STATE" == "0" ]; then
        SRV_ADMIN_STATE="${GREEN}READY${NC}"
    else
        SRV_ADMIN_STATE=""

        STATE_FMAINT=$(( $_SRV_ADMIN_STATE & 0x01 ))
        if [ $STATE_FMAINT -eq $(printf "%d" "0x01") ]; then
            SRV_ADMIN_STATE="$SRV_ADMIN_STATE,forced_maintenance(0x01)"
        fi

        STATE_IMAINT=$(( $_SRV_ADMIN_STATE & 0x02 ))
        if [ $STATE_IMAINT -eq $(printf "%d" "0x02") ]; then
            SRV_ADMIN_STATE="$SRV_ADMIN_STATE,inherited_maintenance(0x02)"
        fi

        STATE_CMAINT=$(( $_SRV_ADMIN_STATE & 0x04 ))
        if [ $STATE_FDRAIN -eq $(printf "%d" "0x04") ]; then
            SRV_ADMIN_STATE="$SRV_ADMIN_STATE,configuration_maintenance(0x04)"
        fi

        STATE_FDRAIN=$(( $_SRV_ADMIN_STATE & 0x08 ))
        if [ $STATE_FDRAIN -eq $(printf "%d" "0x08") ]; then
            SRV_ADMIN_STATE="$SRV_ADMIN_STATE,forced_DRAIN(0x08)"
        fi

        STATE_IDRAIN=$(( $_SRV_ADMIN_STATE & 0x10 ))
        if [ $STATE_IDRAIN -eq $(printf "%d" "0x10") ]; then
            SRV_ADMIN_STATE="$SRV_ADMIN_STATE,inherited_DRAIN(0x10)"
        fi

        STATE_RMAINT=$(( $_SRV_ADMIN_STATE & 0x20 ))
        if [ $STATE_RMAINT -eq $(printf "%d" "0x20") ]; then
            SRV_ADMIN_STATE="$SRV_ADMIN_STATE,ip_resolution_failure(0x20)"
        fi

        # Remove first comma
        FIRST_CHAR=${SRV_ADMIN_STATE:0:1}
        if [ "$FIRST_CHAR" == "," ]; then
            SRV_ADMIN_STATE=${SRV_ADMIN_STATE:1}
        fi

        SRV_ADMIN_STATE="${RED}${SRV_ADMIN_STATE}${NC}"
    fi

    _SRV_CHECK_RES=$( echo $LINE | cut -d' ' -f 12 )
    case $_SRV_CHECK_RES in
        0) SRV_CHECK_RES="${YELLOW}UNKNOWN${NC}" ;;
        1) SRV_CHECK_RES="${YELLOW}NEUTRAL${NC}" ;;
        2) SRV_CHECK_RES="${RED}FAILED${NC}" ;;
        3) SRV_CHECK_RES="PASSED" ;;
        4) SRV_CHECK_RES="${YELLOW}CONDPASS${NC}" ;;
    esac

    SRV_WEIGHT=$( echo $LINE | cut -d' ' -f 8 )

    printf "$BACKEND_NAME|$SRV_NAME|$SRV_ADDR|$SRV_WEIGHT|$SRV_ADMIN_STATE|$SRV_CHECK_RES|$SRV_OP_STATE\n" >> $TMP_FILE
done

if [ "$IS_RAW" == "raw" ]; then
  cat $TMP_FILE
else
  cat $TMP_FILE | column -t -s"|"
fi

rm $TMP_FILE
