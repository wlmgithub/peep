#!/bin/bash

help() {
  cat << EOF
Usage: $0 [OPTIONS]...

Arguments:
  -b: block the core storage server
  -h: show help 
  -u: unblock the core storage server
EOF
}

server="<hostname_of_server_to_be_blocked>"

block() {
  echo Blocking $server
  sudo iptables -A INPUT -s $server -j DROP
}

unblock() {
  echo Unblocking $server
  line_number=`sudo iptables -L --line-numbers | grep $server | awk '{print $1}'`
  sudo iptables -D INPUT $line_number
}

if (($# == 0)); then
  help
  exit 0
fi

while getopts "bhu" opt ; do
  case $opt in
    b) block ;;
    h) help ;;
    u) unblock ;;
  esac
done
exit 0
