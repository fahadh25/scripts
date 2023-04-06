#!/bin/sh

if [[ ("$1" == "show") && ("$2" == "") ]]; then
    asterisk -rvx "database show"

elif [[ ("$1" == "add") && ("$2" != "") ]]; then
    asterisk -rvx "database put blacklist "$2" blacklist-sb"

elif [[ ("$1" == "delete") && ("$2" != "") ]]; then
    asterisk -rvx "database del blacklist "$2""

elif [[("$1" == "check") && ("$2" != "")]]; then
    asterisk -rvx "database get blacklist "$2""

else
    echo "Wrong Command"
fi
