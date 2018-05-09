default:

blacklist:
	curl -sSfL https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts | awk '/^(#.*|0.0.0.0.*|)$$/' > blacklist
	# Add health check response
	echo "0.0.0.0 health.server.test" >> blacklist
