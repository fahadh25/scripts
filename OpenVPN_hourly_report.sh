#!/bin/bash

##This script will get daily user report of openvpn (connction/disconnection)
IP=$(hostname -I | awk '{print $1}')
VPN=BDVPN4

#Last day Data fetch from openvpn log file

cat /var/log/openvpn.log | grep "$(date  --date="60 minute ago" +"%a %b %_d %H")" | grep -E 'authentication succeeded|SIGTERM|SIGUSR1' | awk '{print $1,$2,$3,$4,$5,$6,$7,$(NF-2)}' |sed 's/TLS:/Connected username:/' | sed 's/SIGTERM.*/Disconnected/' | sed 's/SIGUSR1.*/Disconnected/' > /root/$VPN-hourly-report.txt

#Sending mail
mail -r "OpenVPN <it.escalation@gmail.com>" -s "OpenVPN Hourly Report | $VPN " -a "/root/BDVPN4-hourly-report.txt" git-bd-alerts@augmedix.com << EOF
Dear team,
Please find the OpenVPN HOURLY user connection report as attached.

Date= $(date  --date="60 minute ago" +"%a %b %d %H") hrs
IP= $IP
VPN= $VPN

Thanks

EOF

