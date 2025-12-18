# Twitch uses POST requests to i.e. video-edge-47127a.sjc05.hls.live-video.net
# *.ts URLs to track users. The view-counts and also the channel-point
# distribution relies on those trackers to be available. As I'm an active
# Twitch user, I want those points and to be seen as a viewer.

echo "# Unblock Twitch Video-Tracking"
named-blacklist --config blacklist-config.yaml |
  awk '/^.*\.live-video\.net\s/{ print $1 }' |
  sort -u
