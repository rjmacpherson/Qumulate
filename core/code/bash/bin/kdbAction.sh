#!/bin/bash
# KDB Action Script to control KDB Processes

# =============================================================================
# [a] Source Command Line Variables
# =============================================================================

ACTION=$1
APP=$2
COMPONENT=$3
RUNMETHOD=$4

# =============================================================================
# [b] Source Core Specific Libraries and Config
# =============================================================================

QUMULATE_HOME=~/q/Qumulate
CORE_HOME=$QUMULATE_HOME/core
CORE_CODE_HOME=$CORE_HOME/code
CORE_BASH_HOME=$CORE_CODE_HOME/bash
CORE_CONFIG_HOME=$CORE_HOME/config

# Source bash library scripts
for file in $CORE_BASH_HOME/lib/*
do 
    source $file 
    # Manually display until logging functions loaded
    date_time=`date --utc "+%Y.%m.%d %H:%M:%S.%3N"`
    echo -e $date_time" INFO : Loaded core bash library file: "`basename $file`
done

# Source all core config, sourcing directories.cf first
for file in $CORE_CONFIG_HOME/directories.cf $CORE_CONFIG_HOME/$(ls $CORE_CONFIG_HOME/ | grep -vi directories)
do
    source $file
    logInfo "Loaded core bash configuration file: "`basename $file`
done

# =============================================================================
# [c] Source App Libraries and Config
# =============================================================================



# =============================================================================
# [d] Create Command to Run  
# =============================================================================

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
	    COMMAND="$CORE_BASH_HOME/bin/kdbStart.sh $2 $3" 
    elif [ "$1" = "stop" ]
    then
        logInfo "Stopping KDB Processes"
        COMMAND="$CORE_BASH_HOME/bin/kdbStop.sh" 
    elif [ "$1" = "status" ]
    then 
        logInfo "KDB Status"
    elif [ "$1" = "cleanup" ]
    then 
	    logInfo "Starting clean up Process"
	    COMMAND="$CORE_BASH_HOME/bin/kdbCleanup.sh"
    else
	    logErr "Command Line argument not known"
	    exit 1
    fi 
    eval $COMMAND
}

# ============================================================================
# [e] Execution
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

