# date
date=$(date +'%A  %Y-%m-%d %l:%M:%S %p')

# volume
vol_amt=$(amixer -c 1 get Master | grep -Po "\d?\d?\d%")
vol_on=$(amixer -c 1 get Master | grep -Po "\[(off|on)\]")
if [ "$vol_on" = "[on]" ]; then
  volume="vol $vol_amt"
else
  volume="mute"
fi

# playerctl
playerctl_status=$(playerctl status)

if [ "$playerctl_status" = "Playing" ]; then
  playerctl="[$(playerctl metadata artist)]: $(playerctl metadata title)"
else
  playerctl="$playerctl_status"
fi

echo "$playerctl · $volume · $date"
