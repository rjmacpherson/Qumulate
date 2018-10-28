#!/bin/bash
# Clean up script 

cd $LOGHOME
logInfo "Removing all logs in $LOGHOME"
rm *.log

cd $PIDHOME
logInfo "Removing all PID Files in $PIDHOME"
rm *.pid
