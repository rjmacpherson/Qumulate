/ Realtime Database (RDB) Component Script 

/ =============================================================================
/ [a] List Usage and Global Variables Information 
/ =============================================================================

/q rdb.q -p [port] -tp [port] -hdb [port]

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
$[`tp in key .config.cmdLine;
    .rdb.i.tpPort:"I"$first .config.cmdLine`tp;
    .rdb.i.tpPort:5010];
$[`hdb in key .config.cmdLine;
    .rdb.i.hdbPort:"I"$first .config.cmdLine`hdb;
    .rdb.i.hdbPort:5013];

/ =============================================================================
/ [c]  RDB Functions   
/ ============================================================================= 

/ define upd function as simple insert
upd:insert;

/ end of day: save, clear, hdb reload
.u.end:{[date]
	tbls:tables`.;
	/ Get List of tables where the sym column has a grouped attribute 
	groupedTbls:tbls@where `g=attr each tbls@\:`sym;
	/ Save tables .Q.hdpf[hdbPort;hdbDir;parition;`p#field]
	.Q.hdpf[`$":",string[.rdb.i.hdbPort];`$":",.config.dir.hdbDir;date;`sym];
	/ Apply grouped attribute to tables that had it before savedown
	@[;`sym;`g#] each groupedTbls;
    };

/ Replay Function to get table schema from TP and reply the log file 
/  @param schema (List of lists) Schema from all tables in the RDB
/  @param logMsgCnt (Long) Number of chunks in the TP log file 
/  @param tpLogPath (Symbol) Name of the TP Log File 
.u.rep:{[schema;logMsgCnt;tpLogPath]
	.log.info "Getting schema from TP";
	(.[;();:;].)each schema;
	/ If nothing to reply return empty list
	if[null logMsgCnt;
	    :()
	    ];
	/ Replay the TP long for all message received
	.log.info "Replying TP log file with number of chunks: ", string logMsgCnt;
	-11!(logMsgCnt;tpLogPath);
    };

/ connect to ticker plant for (schema;(logcount;log))
.u.rep .(hopen `$"::",string .rdb.i.tpPort)"(.u.sub[`;`];.tp.logMsgCnt;.tp.tpLogPath)";

