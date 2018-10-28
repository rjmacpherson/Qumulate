#!/bin/bash
# KDB Action Script to start, stop and clean up KDB Processes

# =============================================================================
# [a] Source Core Environment Variables and Logging Functions
# =============================================================================

export QUMULATEHOME=~/q/Qumulate
export CONFIGHOME=$QUMULATEHOME/config
export CODEHOME=$QUMULATEHOME/code
export BASHHOME=$CODEHOME/bash

source $CONFIGHOME/core-variables.cf
source $BASHHOME/log.sh 

# =============================================================================
# [b] Create Command to Run  
# =============================================================================

export ACTION=$1
export COMPONENT=$2
export RUNMETHOD=$3

# Ensure passed component is a known environment variable 
if [ ! -n "$(printenv $COMPONENT)" ]
then 
	logErr "Passed Component not known"
	exit 1
fi

# if [ "$COMPONENT" = ALL ]
# then 
# run set command for each and 

# Set command based on action and component parameters 
function setActionCmd
{
    if [ "$ACTION" = "start" ]
    then 
	    logInfo "Starting KDB Process: "$COMPONENT
	    COMMAND="$BASHHOME/kdbStart.sh $COMPONENT $RUNMETHOD" 
    elif [ "$ACTION" = "stop" ]
    then
        logInfo "Stopping KDB Processes"
        COMMAND="$BASHHOME/kdbStop.sh" 
    elif [ "$ACTION" = "cleanup" ]
    then 
	    logInfo "Starting clean up Process"
	    COMMAND="$BASHHOME/kdbCleanup.sh"
    else
	    logErr "Command Line argument not known"
	    exit 1
    fi 
}

function evalActionCmd
{
    setActionCmd 
    eval $COMMAND
}

# ============================================================================
# [c] Execution
# ============================================================================

evalActionCmd