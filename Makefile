export GIT_VERSION:=$(shell git describe --tags --always)

default:

blacklist:
	named-blacklist --config blacklist-config.yaml >named.blacklist
