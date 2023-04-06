##This script will send email whenever someone login to following server.


#yum install postfix mailx -y
#systemctl start postfix
#systemctl enable postfix
#vim /etc/profile.d/ssh_alert.sh

	#!/bin/bash

	#Variable call

	IP=$(hostname -I | awk '{print $1}')
	#TIME=$(date +\%d/\%m/\%y_\%H:\%M)
	USER=$(who | awk '{print $1}')
	PTS=$(who | awk '{print $2}')
	TIME=$(who | awk '{print $3,$4}')
	FROM_IP=$(who | awk '{print $5}')
	TO=fahad.hossain@augmedix.com


	mail -r "ssh-alert <it.escalation@gmail.com>" -s "Alert: SSH Access to IP: $IP" $TO  << EOF
	Someone login through SSH to below AX Linux server.

	Server IP: $IP
	Hostname: $HOSTNAME
	Date & Time: $TIME
	User Name: $USER
	Terminal: $PTS
	From IP: $FROM_IP
	EOF

#chmod +x /etc/profile.d/ssh_alert.sh

##If you want to use relay host as gmail, then.

#yum -y install cyrus-sasl-plain
#vim /etc/postfix/main.cf

relayhost = [smtp.gmail.com]:587
smtp_use_tls = yes
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_tls_CAfile = /etc/ssl/certs/ca-bundle.crt
smtp_sasl_security_options = noanonymous
smtp_sasl_tls_security_options = noanonymous

#vim /etc/postfix/sasl_passwd   *will create sasl_passwd file
	[smtp.gmail.com]:587 it.escalation@gmail.com:Test@123
	**insert username and password of gmail account

#postmap /etc/postfix/sasl_passwd
#chown root:postfix /etc/postfix/sasl_passwd*
#chmod 640 /etc/postfix/sasl_passwd*
#systemctl reload postfix
#echo "This is a test." | mail -s "test message" user@example.net





***Logout and login to ssh, check inbox/junkbox for alert mail.