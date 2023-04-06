#!/bin/bash
# declare STRING variable
BK_DIR="/tmp/IVR_BKUP"
BK_ROOT="/tmp"
BK_SERVER="TRC16263"
BK_EMAIL="shoaib@synesisit.com.bd"
FROM_DIR="/var/spool/asterisk/monitor/"
#FROM_DIR="/var/spool/asterisk/voicemail/default/1234/en/"

BK_FILES="ivrs"
BK_DB_USR="root"

#BK_FTP_SERVER="172.16.16.12"
BK_FTP_SERVER="192.168.101.12"
BK_FTP_USR="blvas01"
BK_FTP_PASS="blvas123"

if [ -d $BK_DIR ]
then
    echo "Directory $BK_DIR exists."
	chmod 777 $BK_DIR
	rm -rf $BK_DIR/*
else
    echo " Directory $BK_DIR does not exists.creating directory.."
	mkdir $BK_DIR
	chmod 777 $BK_DIR
fi

#move files to back up directory

`find "$FROM_DIR" -type f -name "*.gsm" -newermt "2019-12-01 00:00:00" ! -newermt "2019-12-10 23:59:59"  -exec mv "{}" "$BK_DIR" \;`

#set and print variable on a screen
BK_FILENAME=$BK_SERVER-$BK_FILES-`date +%F-%H-%M-%S.tar.gz`
echo $BK_FILENAME
BK_START_TIME=`date +%F-%H-%M-%S`
#`mysqldump -u "$BK_DB_USR" "$BK_FILES" | gzip -9 > $BK_DIR/$BK_FILENAME`
`tar -zcvf $BK_ROOT/$BK_FILENAME $BK_DIR --remove-files`
BK_END_TIME=`date +%F-%H-%M-%S`


#FTP Part
`curl -T $BK_ROOT/$BK_FILENAME ftp://$BK_FTP_SERVER --user $BK_FTP_USR:$BK_FTP_PASS`


#Email part
#`df -m > $BK_ROOT/$BK_FILENAME.mail`
#`free -m >> $BK_ROOT/$BK_FILENAME.mail`
#`ps ax >> $BK_ROOT/$BK_FILENAME.mail`
#`mail -s "$BK_SERVER $BK_FILES backup $BK_START_TIME to $BK_END_TIME" $BK_EMAIL < $BK_ROOT/$BK_FILENAME.mail`

#REMOVE the TEMP files
#`rm -rf $BK_DIR/*`
#`rm $BK_ROOT/$BK_FILENAME`
#`rm $BK_ROOT/$BK_FILENAME.mail`
