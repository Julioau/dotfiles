#!/bin/sh

if pgrep -x "openvpn" > /dev/null; then
  pkexec pkill openvpn
else
  pkexec openvpn /home/juli/.config/openvpn/julio.ovpn
fi