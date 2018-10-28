/ Historical Database (HDB) Component Script

/ =============================================================================
/ [a] List Usage and Global Variables Information 
/ =============================================================================

/q hdb -p [port] 

/ =============================================================================
/ [b] Load Configuration Settings and Utility Functions  
/ ============================================================================= 

/ Set Configuration Directories
/ TODO: Export this to a config.q script for all components 
.config.stackName    : "example";
.config.dir.schema   : (getenv`SCHEMAHOME);
.config.dir.stackData: (getenv`DATAHOME),"/",.config.stackName,"Data";
.config.dir.tpLogDir : .config.dir.stackData,"/tpLog";
.config.dir.hdbDir   : .config.dir.stackData,"/hist";
.config.dir.kdbhome  : (getenv`KDBHOME);
.config.tpLogName    : .config.stackName,"TpLog"; 
.config.cmdLineArgs  : .Q.opt .z.x;

system"l ",.config.dir.kdbhome,"/lib/log.q";

/ Load table config 
.log.info "Loading tables configuration";
system"l ",.config.dir.schema, "/",.config.stackName,"Schema.q";

/ Set Default port if not set on command line 
if[not system"p";system"p 5012"];
.log.info "Port set to ",string system"p";

/ Get tp and hdb ports from cmd line, else set defaults 
$[`tp in key .config.cmdLineArgs;
    .hdb.i.tpPort:"I"$first .config.cmdLineArgs`tp;
    .hdb.i.tpPort:5010];
$[`hdb in key .config.cmdLineArgs;
    .hdb.i.hdbPort:"I"$first .config.cmdLineArgs`hdb;
    .hdb.i.hdbPort:5013];

/ =============================================================================
/ [c]  HDB Functions   
/ ============================================================================= 