#!/bin/sh

if pgrep -x "openvpn" > /dev/null
then
    # VPN is running, so stop it
    pkexec pkill openvpn
else
    # VPN is not running, so start it
    pkexec openvpn /home/julio/Downloads/julioA.ovpn
fi