#!/bin/bash
set -euxo pipefail

packages=(
  github.com/Luzifer/bind-log-metrics@latest
  github.com/Luzifer/named-blacklist@latest
  github.com/Luzifer/rootzone@latest
)

for pkg in "${packages[@]}"; do
  go install \
    -mod=readonly \
    -modcacherw \
    "${pkg}"
done
