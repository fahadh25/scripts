#!/bin/bash
#This script will fetch .WAV call record from asterisk and COPY or MOVE to user backup_dir_path
#run this script as below patter
# ./data_backup.sh FROM_DATE TO_DATE mv or cp
#Example:   ./data_backup.sh 2001-12-25 2001-12-28 cp
#this will COPY all the .WAV files from 2001-12-25 to 2001-12-28 date to backup directory



#Veriable declare to get the parameters from user commnad argument
FROM="${1}"
TO="${2}"
ACTION="${3}"
BK_DIR="backup_dir_path"

#If didn't give enough/wrong information
if [[ ${#} -lt 2 ]]
then
 echo "Please run as follow: "${0}" FROM_DATE TO_DATE mv(for move) or cp(for copy)"
 echo "Example: "${0}" 2001-12-25 2001-12-28 cp"
 echo
 exit 1
fi

#If anything rather then cp/mv
if [[ ${ACTION} != @(cp|mv) ]] 
then 
 echo "Please use cp for COPY or mv for MOVE"
 exit 1
fi

#Warning on data moving/deleting
if [[ ${ACTION} == mv ]]
then
 echo "WARNING...!!! WARNING...!!!"
 echo "You are parmanently MOVING data from DB folder"
 read -p 'Please confirm by pressing y/n: ' CONFIRMATION
fi

if [[ ${CONFIRMATION} == @(N|n) ]]
then
 echo "Misson aborted: ${CONFIRMAION}"
 exit 1
fi

#Creating Backup directory

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

echo "Backup Directory created"

#Fetch data

find asterisk_audio_path_location -name "*.wav" -newermt ""${FROM}" 00:00:00" ! -newermt ""${TO}" 00:05:59" -exec "${ACTION}" "{}" ${BK_DIR} \;

#Check Copy/Move successed or not
if [[ ${?} -eq 1 ]]
then
 echo "Please check the date format: it must be yyyy-mm-dd"
 exit 1
fi
echo " "${ACTION}" is done"

#ZIPing the directory
echo "Compression will start now"
tar -zcf /path_to_zip_file_location/$(date +%F-%H-%M).tar.gz ${BK_DIR}  --remove-files
echo
echo "Compression done. Please get your backup file /path_to_zip_file_location/$(date +%F-%H-%M).tar.gz"


#check process done or any error
if [[ ${?} -eq 0 ]]
then
 echo
 echo "Successful....!!!"
 exit 1
fi






