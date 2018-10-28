#!/bin/bash
# KDB Start Up Component Script

# =============================================================================
# [a Usage 
# ============================================================================= 

# Called from kdbAction.sh 
# Relies on variables set within kdbAction.sh 

# .../kdbStart.sh [ COMPONENT ] [ RUNMETHOD]  

# =============================================================================
# [b] Start Core Processes
# =============================================================================

COMPONENT=$1
RUNMETHOD=$2

COMMAND="$QEXEC $KDBHOME/run.q -component $(printenv $COMPONENT)"

if [ "$RUNMETHOD" = "int" ]
then 
	logInfo "Running process interactively"
	eval "rlwrap $COMMAND -method int"
# Background is default if $RUNMETHOD not passed
elif [ "$RUNMETHOD" = "bg" ] || [ ! -n "$RUNMETHOD" ]
then 
	logInfo "Starting $COMPONENT in the background"
	LOGFILE=$LOGHOME/${COMPONENT}_$DATETIME_TAG.log
    eval "$COMMAND -method bg  >& $LOGFILE &"
    echo $! > $PIDHOME/$COMPONENT.pid 
else
    logErr "Passed Run Method not known"
    exit 1
fi
