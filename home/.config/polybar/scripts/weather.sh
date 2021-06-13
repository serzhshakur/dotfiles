#!/bin/bash

FORMAT_TYPE=${1:?"please specify an output format short|full"}
FORMAT=""

case $FORMAT_TYPE in
    short) FORMAT="%c+%t\n" ;;
    full) FORMAT="%l+%c+%t+%m+%w\n" ;;
esac

curl -fsL \
  --retry 3 --retry-connrefused \
  --connect-timeout 1 \
  wttr.in/Riga\?format="$FORMAT" |
  grep '°C' || echo ""
