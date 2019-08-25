#!/usr/local/bin/dumb-init /bin/bash
set -euxo pipefail

# Start bind
exec named -c /etc/bind/named.conf -g
