#!/bin/bash
set -euo pipefail

target=blacklist

# Download compiled blacklist
curl -sSfL https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts | awk '/^(#.*|0.0.0.0.*|)$$/' >${target}

# Remove entries on local whitelist
for entry in $(cat whitelist.local); do
	grep -v "${entry}" ${target} >${target}.tmp
	mv ${target}.tmp ${target}
done

# Add local blacklist
cat blacklist.local >>${target}
