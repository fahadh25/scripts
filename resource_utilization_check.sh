#!/bin/bash

#This script will check the RAM, CPU and Disk consumption
#and trigger a mail alert if utilization cross threshold.

#Vairable call for email alert
IP=$(hostname -I | awk '{print $1}')
TO=your email address
HOST=$HOSTNAME

#Variable call for Disk space
DISK=$(df -h --total | awk '$1=="total"{printf $5}' | cut -d '%' -f1)
THRESHOLD=70

#Check Disk space and trigger email 
if (( $(echo "$DISK > $THRESHOLD" | bc -l) )); then
 mail -r "Resource Alert <from_email@example.com>" -s " Resource limitation alert from $IP | $HOST " $TO,  << EOF
 Disk space of below server is critically low.
 IP: $IP
 HOSTNAME: $HOST
 Current consumption: $DISK%
EOF
fi


#variable call for RAM
RAM=$(free -m | awk 'NR==2{printf "%.2f\n", $3*100/$2 }')
THRESHOLD=80

#Check RAM consumption and trigger email 
if (( $(echo "$RAM > $THRESHOLD" | bc -l) )); then
 mail -r "Resource Alert <from_email@example.com>" -s " Resource limitation alert from $IP | $HOST "  $TO,  << EOF
 RAM consumption of below server is very high.
 IP: $IP
 HOSTNAME: $HOST
 Current consumption: $RAM%
EOF
fi


#variable call for CPU load
CPU=$(top -bn1 | grep load | awk '{printf "%.2f\n", $(NF-2)}')
THRESHOLD=70

#Check CPU load and trigger email 
 if (( $(echo "$CPU > $THRESHOLD" | bc -l) )); then
 mail -r "Resource Alert <from_email@example.com>" -s " Resource limitation alert from $IP | $HOST "  $TO,  << EOF
 CPU load average of below server is very high.
 IP: $IP
 HOSTNAME: $HOST 
 Current consumption: $CPU%
EOF
fi


