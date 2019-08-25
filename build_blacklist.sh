#!/bin/bash
set -euo pipefail

target=blacklist

function cleanup() {
	rm -rf \
		${target} \
		${target}.tmp
}
trap cleanup EXIT

# Download compiled blacklist
curl -sSfL https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts | awk '/^(#.*|0.0.0.0.*|)$$/' >${target}

# Remove entries on local whitelist
for entry in $(cat whitelist.local); do
	grep -v "${entry}" ${target} >${target}.tmp
	mv ${target}.tmp ${target}
done

# Add local blacklist
cat blacklist.local >>${target}

# Convert into named response-policy file
cp blacklist.tpl named.${target}
awk '/^0.0.0.0/{ printf "%s  CNAME .\n", $2 }' blacklist |
	grep -v '^0.0.0.0  ' |
	sort >>named.${target}
