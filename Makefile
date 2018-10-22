default:

blacklist:
	curl -sSfL https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts | awk '/^(#.*|0.0.0.0.*|)$$/' > blacklist
	# Add local blacklist
	cat blacklist.local >> blacklist
