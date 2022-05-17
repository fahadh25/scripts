#!/bin/bash

#This command will check the bandwidth consumption.
#Please install the package first if it's not available 
#configure this as cron for recurring report

vnstat -l -i em1
