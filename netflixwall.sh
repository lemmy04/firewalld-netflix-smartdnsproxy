#!/bin/bash 

#
#
# this script generates firewalld rules for redirecting all netflix-related dns traffic to the smartdnsproxy dns of your choice
# configuration happens in the three variables at the start
# MACS: contains the MAC addresses of all the devices on your LAN that should use smartdnsproxy
#       that way you can easily switch between smartdnsproxy and your localized netflix by switching your TV between Wifi and ethernet.
#
# TARGETS: all ip addresses / ip ranges listed on https://support.smartdnsproxy.com/article/101-static-ip-routing-for-router-modem
# SMARTDNS: the smartdnsproxy nameserver that you're using, from https://www.smartdnsproxy.com/Servers

# synopsis: netflixwall.sh [install|remove]


MACS="fc:f1:52:4d:ce:0e 04:5d:4b:9c:6f:6c d0:50:99:27:6a:34 b8:ee:65:47:1c:b0 8c:fe:57:03:23:5f"
TARGETS="8.8.8.8/32 8.8.4.4/32 45.57.0.0/17 198.38.98.0/24 198.38.112.0/24 108.175.32.0/20 185.2.220.0/22 198.45.48.0/20 37.77.184.0/21"
SMARTDNS="54.93.173.153"


OPERATION=$1

case ${OPERATION} in
	install|INSTALL)
		firewalld_command="--add-rule"
		;;
	remove|REMOVE)
		firewalld_command="--remove-rule"
		;;
	*)
		echo "$0 install|remove"
		exit 1
		;;
esac

for i in $MACS; do
	for j in $TARGETS; do
		firewall-cmd --direct --permanent ${firewalld_command} ipv4 nat PREROUTING 0 -m mac --mac-source ${i} -d ${j} -p tcp --dport 53 -j DNAT --to ${SMARTDNS}
		firewall-cmd --direct --permanent ${firewalld_command} ipv4 nat PREROUTING 0 -m mac --mac-source ${i} -d ${j} -p udp --dport 53 -j DNAT --to ${SMARTDNS}
	done;
done;


#for i in $MACS; do
#	for j in $TARGETS; do
#		firewall-cmd --direct --permanent --remove-rule ipv4 filter FORWARD 0 -m mac --mac-source ${i} -d ${j} -j DROP
#		firewall-cmd --direct --permanent --add-rule ipv4 nat PREROUTING 0 -m mac --mac-source ${i} -d ${j} -p tcp --dport 53 -j DNAT --to 54.93.173.153
#		firewall-cmd --direct --permanent --add-rule ipv4 nat PREROUTING 0 -m mac --mac-source ${i} -d ${j} -p udp --dport 53 -j DNAT --to 54.93.173.153
#	done
#done
