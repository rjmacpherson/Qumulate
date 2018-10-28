#!/bin/bash
# Clean up script 

cd $LOGHOME
echo "Removing all logs in $LOGHOME"
rm *.log

cd $PIDHOME
echo "Removing all PID Files in $PIDHOME"
rm *.pid
