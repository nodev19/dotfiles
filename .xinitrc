setxkbmap gb
xrandr --output HDMI-1 --auto --primary --output eDP-1 --auto --right-of HDMI-1
xset r rate 200 80
xbanish &
exec i3
