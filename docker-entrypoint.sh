#!/usr/local/bin/dumb-init /bin/bash
set -euxo pipefail

# Start bind in background
named -p 1053 -c /etc/bind/named.conf -g &

# Start coredns to filter blacklist
coredns -conf /etc/Corefile
