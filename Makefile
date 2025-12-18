export GIT_VERSION:=$(shell git describe --tags --always)

default:

blacklist: whitelist.local
	named-blacklist --config blacklist-config.yaml >named.blacklist

.PHONY: whitelist.local
whitelist.local:
	echo '' >$@
	bash ci/gen-whitelist
