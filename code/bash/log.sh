#!/bin/bash
# Bash Logging Functions Script

function logInfo
{
	date_time=`date --utc "+%Y.%m.%d %H:%M:%S.%3N"`
	echo -e $date_time" INFO : "$1
}

function logWarn
{
	date_time=`date --utc "+%Y.%m.%d %H:%M:%S.%3N"`
	echo -e "\033[1;33m"$date_time" WARN : "$1"\033[0m"
}

function logErr
{
	date_time=`date --utc "+%Y.%m.%d %H:%M:%S.%3N"`
	echo -e "\033[1;31m"$date_time" ERROR : "$1"\033[0m"
}

# Export all functions so that they are available to child processes
export -f logInfo logWarn logErr