#!/bin/bash
# Stop Script 

# =============================================================================
# [a] Stop Processes with PID Files
# =============================================================================

# Kill each process with a PID file 
# Remove the PID file 
for pidfile in $PIDHOME/*; do 
    PID=$(cat $pidfile)
    echo "Killing Process with PID: $PID"
    kill -9 $PID
    rm $pidfile
done

