#!/bin/sh

if pgrep -x "openvpn" > /dev/null; then
  pkexec pkill openvpn
else
  pkexec openvpn $XDG_CONFIG_HOME/openvpn/julio.ovpn
fi