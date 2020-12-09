#!/bin/bash
set -euxo pipefail

# Install build utilities
apk --no-cache add curl

# Get latest versions of tools using latestver
DUMB_INIT_VERSION=$(curl -sSfL 'https://lv.luzifer.io/catalog-api/dumb-init/latest.txt?p=version')
[ -z "${DUMB_INIT_VERSION}" ] && { exit 1; }

# Install tools
curl -sSfLo /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VERSION}/dumb-init_${DUMB_INIT_VERSION}_x86_64
chmod +x /usr/local/bin/dumb-init

# Cleanup
apk --no-cache del curl
