#!/bin/sh
#
# ref post: https://forum.netgate.com/topic/131539/solved-how-to-restart-openvpn-in-a-script
# ref comment: https://forum.netgate.com/post/992107

# I copy this file under root folder of pfsense.
# in cron job setting input:
# /root/restart_opvn_when_url_not_reachable.sh [interface id] [url to check] > /dev/null

VPN_IF=$1
if [ "$VPN_IF" = "" ]; then
	VPN_IF=1
fi

checkURL=$2
if [ "$checkURL" = "" ]; then
	checkURL="https://www.google.com"
fi

VPN_IP=`/sbin/ifconfig ovpnc$VPN_IF | /usr/bin/grep 'inet ' | /usr/bin/awk '{print $2}'`
VPN_GW=`/sbin/ifconfig ovpnc$VPN_IF | /usr/bin/grep 'inet ' | /usr/bin/awk '{print $4}'`
echo "VPN Interface  = $VPN_IF"
echo "VPN IP Address = $VPN_IP"
echo "VPN Gateway    = $VPN_GW"
echo "Checking URL  = $checkURL"

if [ "$VPN_IP" != "" ] && [ "$VPN_GW" != "" ]
then
	# If ovpn interface has an IP and a gateway, test further
	if curl --interface ovpnc$VPN_IF -k $checkURL > Manhuagui.html
	then echo "Access URL was successful"
	else echo "Access URL was Failed"
		echo "Restarting OpenVPN client $VPN_IF"
		/usr/local/sbin/pfSsh.php playback svc restart openvpn client $VPN_IF
		fi
else
	# ovpn interface failed IP and/or gateway value check, restart service
	/usr/local/sbin/pfSsh.php playback svc restart openvpn client $VPN_IF
fi
