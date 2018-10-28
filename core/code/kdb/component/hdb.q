/ Historical Database (HDB) Component Script

/ =============================================================================
/ [a] List Usage and Global Variables Information 
/ =============================================================================

/q hdb -p [port] 

/ =============================================================================
/ [b] Load Configuration Settings and Utility Functions  
/ ============================================================================= 

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