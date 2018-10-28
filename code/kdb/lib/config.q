/ Configuration Library for Processes 

/ =============================================================================
/ [a] Set Core Q Configuration Variables  
/ =============================================================================

.config.stackName    : "example";
.config.dir.schema   : (getenv`SCHEMAHOME);
.config.dir.stackData: (getenv`DATAHOME),"/",.config.stackName,"Data";
.config.dir.tpLogDir : .config.dir.stackData,"/tpLog";
.config.dir.hdbDir   : .config.dir.stackData,"/hist";
.config.dir.kdbhome  : (getenv`KDBHOME);
.config.tpLogName    : .config.stackName,"TpLog"; 
.config.cmdLine      : .Q.opt .z.x;

/ =============================================================================
/ [b] Run Method Settings 
/ =============================================================================



/ =============================================================================
/ [b] Load Base Libraries 
/ =============================================================================

/ Load logging functions 
system"l ",.config.dir.kdbhome,"/lib/log.q";

.log.info "Configuration library loaded";
