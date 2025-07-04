#!/usr/bin/dumb-init /bin/bash
set -euxo pipefail

# No influx credentials present, don't use metrics sender
[[ -n ${INFLUX_HOST:-} ]] ||
  exec named -c /etc/bind/named.conf -g

# Start bind
bind-log-metrics <(
  named -c /etc/bind/named.conf -g 2>&1
)
