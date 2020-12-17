#!/bin/bash
set -euxo pipefail

# Install build utilities
apk --no-cache add curl jq

# Get latest versions of tools using Github API
ASSET_URL=$(
	curl -s "https://api.github.com/repos/Yelp/dumb-init/releases/latest" |
		jq -r '.assets[] | .browser_download_url' |
		grep "$(uname -m)$"
)
[[ -n $ASSET_URL ]] || exit 1

# Install tools
curl -sSfLo /usr/local/bin/dumb-init "${ASSET_URL}"
chmod +x /usr/local/bin/dumb-init

# Cleanup
apk --no-cache del curl jq
