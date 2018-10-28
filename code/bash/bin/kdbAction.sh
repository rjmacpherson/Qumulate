#!/bin/bash
# KDB Action Script to control KDB Processes

# =============================================================================
# [a] Source Core Libraries and Config
# =============================================================================

QUMULATEHOME=~/q/Qumulate
CONFIGHOME=$QUMULATEHOME/config
CODEHOME=$QUMULATEHOME/code
BASHHOME=$CODEHOME/bash

# Source bash library scripts
for file in $BASHHOME/lib/*
do 
    source $file 
    # Manually display until logging functions loaded
    date_time=`date --utc "+%Y.%m.%d %H:%M:%S.%3N"`
    echo -e $date_time" INFO : Loaded core bash library file: "`basename $file`
done

# Source all core config
for file in $CONFIGHOME/core/*
do
    source $file
    logInfo "Loaded core bash configuration file: "`basename $file`
done

# =============================================================================
# [b] Create Command to Run  
# =============================================================================

ACTION=$1
COMPONENT=$2
RUNMETHOD=$3

# Ensure passed component is a known environment variable/not ALL
if [ ! -n "$(printenv $COMPONENT)" ] && [ ! "$COMPONENT" == ALL ]
then 
	logErr "Passed Component not known"
	exit 1
fi

# Set command based on action and component parameters
# USAGE: evalAction [ ACTION ] [ COMPONENT ] [ RUNMETHOD ]
function evalAction
{
    if [ "$1" = "start" ]
    then 
	    logInfo "Starting KDB Process: "$2
	    COMMAND="$BASHHOME/bin/kdbStart.sh $2 $3" 
    elif [ "$1" = "stop" ]
    then
        logInfo "Stopping KDB Processes"
        COMMAND="$BASHHOME/bin/kdbStop.sh" 
    elif [ "$1" = "status" ]
    then 
        logInfo "KDB Status"
    elif [ "$1" = "cleanup" ]
    then 
	    logInfo "Starting clean up Process"
	    COMMAND="$BASHHOME/bin/kdbCleanup.sh"
    else
	    logErr "Command Line argument not known"
	    exit 1
    fi 
    eval $COMMAND
}

# ============================================================================
# [c] Execution
# ============================================================================

if [ "$COMPONENT" = ALL ]
then
    for COMPONENT in TP FEED
    do 
        echo "Starting component : $COMPONENT"
        evalAction $ACTION $COMPONENT $RUNMETHOD
    done 
else 
    evalAction $ACTION $COMPONENT $RUNMETHOD
fi 

