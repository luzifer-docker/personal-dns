#!/bin/bash
set -euxo pipefail

packages=(
	github.com/Luzifer/bind-log-metrics
	github.com/Luzifer/named-blacklist
	github.com/Luzifer/rootzone
)

for pkg in "${packages[@]}"; do
	targetdir="/go/src/${pkg}"

	# Get sources
	git clone "https://${pkg}.git" "${targetdir}"

	# Go to directory and install util
	pushd "${targetdir}"
	go install -mod=readonly
	popd
done
