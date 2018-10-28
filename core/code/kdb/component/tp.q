/ Tickerplant (TP) Component Script 

/ =============================================================================
/ [a] List Usage and Global Variables Information 
/ ============================================================================= 

/ GLOBALS
/ These are set in u.q 
/    .u.tblsToHdlSyms - dictionary of tables->(tables;handlees)
/    .u.tbls - table names
/ These are set in tp.q 
/    .tp.logMsgCnt - msg count in log file
/    .tp.totalMsgCnt - total msg count (log file plus those held in buffer)
/    .tp.tpLogPath - tp log filepath, e.g. `:./sym2008.09.11
/    .tp.tpLogHdl - handle to tp log file
/    .tp.date - date

/ =============================================================================
/ [b] Load Configuration Settings and Utility Functions  
/ ============================================================================= 

/ Load tick utility functions 
.log.info "Loading Tick Utility fuctions";
system"l ",.config.dir.kdbhome,"/lib/u.q";

/ Load table schemas
/ system"l tick/",(src:first .z.x,enlist"sym"),".q"
.log.info "Loading tables configuration";
system"l ",.config.dir.schema, "/",.config.stackName,"Schema.q";

/ Set Default port if not set on command line 
if[not system"p";system"p 5010"];
.log.info "Port set to ",string system"p";

/ Set system time interval
.log.info "Setting system timer intervals";
system"t 1000";

/ =============================================================================
/ [c] Ticker Plant Functions   
/ ============================================================================= 

/ TP initialization function 
/  @param tpLogName (String) Prefix name of the Tickerplant Log file
/  @param tpLogDir (String) Tickerplant log directory 
/  @returns GLOBAL .tp.date (Date) current date 
/  @returns GLOBAL .tp.tpLogHdl (Handle) Handle to the TP Log file 
/  @returns GLOBAL .tp.tpLogPath (Symbol) Name of the TP Log File 
.tp.init:{[tpLogName;tpLogDir]
    .log.info "Initializing Tickerplant";
    / .u. init loaded from u.q 
    .u.init[];
    / Throw error if the first two columns of each table are not `time`sym
    if[not min(`time`sym~2#cols value@) each .u.tbls;
        '.log.error "First two columns of each table must be `time`sym"
        ];
    / Apply the grouped attribute to the sym column of each table
    @[;`sym;`g#]each .u.tbls; 
    / Set global .tp.date as UTC date 
    .tp.date::.z.d;
    / Assign .tp.tpLogHdl and exectue if string is passed
    if[.tp.tpLogHdl::count tpLogDir;
        / Assign the tpLogPath variable with postfix of ".........."
        .tp.tpLogPath::`$":",tpLogDir,"/",tpLogName,10#".";
        / Set handle to TP log file 
        .tp.tpLogHdl::.tp.getTpLogHdl .tp.date
        ]
    };

/ Sets name of TP log file, get the msg counts from log file
/ Checks if the TP file is corrupt else return a handle to the TP log
/  @param date (Date) date 
/  @returns GLOBAL .tp.tpLogPath (Symbol) Path to logfile 
/  @returns GLOBAL .tp.logMsgCnt (Long) 
/  @returns GLOBAL .tp.totalMsgCnt (Long)
/  @returns handle to current TP Log file  
.tp.getTpLogHdl:{[date]
    / key on a filepath returns the descriptor if the file exists.
    / Otherwise an empty list and set .tp.tpLogPath to (). 
    if[not type key .tp.tpLogPath::`$(-10_string .tp.tpLogPath),string date;
        .[.tp.tpLogPath;();:;()]
        ];
    / Return the number of chunks in the logfile 
    / Logfile is invalid will assign as (number of valid chunks; length of valid part)
    .tp.logMsgCnt::.tp.totalMsgCnt::-11!(-2;.tp.tpLogPath);
    / Throw error and exit if TP logfile is corrupt 
    if[0<=type .tp.logMsgCnt;
        .log.error (string .tp.tpLogPath)," is a corrupt log. Truncate to length ",(string last .tp.logMsgCnt)," and restart";
        exit 1
        ];
    hopen .tp.tpLogPath
    };

/ Run end of day if date supplied is greater than .tp.date
/  @param date (date) date to compare to global TP date 
.tp.ts:{[date] 
    if[.tp.date<date;
        if[.tp.date<date-1;
            '.log.error "Date supplied is more than 2 days before .tp.date"
            ];
        .tp.endofday[]
        ]
    };

/ Run the end of day function using the global .tp.date  
/  @returns GLOBAL .tp.date (date) 
/  @returns GLOBAL .tp.tpLogHdl (Int)
.tp.endofday:{
    .u.end .tp.date;
    .tp.date+:1;
    / Close and reopen a handle to the new TP log 
    if[.tp.tpLogHdl;
        hclose .tp.tpLogHdl;
        .tp.tpLogHdl::.tp.getTpLogHdl .tp.date
        ]
    };

/ Main u.upd function to update and publish tables with new data 
/  @param tbl (Symbol) Table to update 
/  @param data (list of lists) Data to update table with 
.u.upd:{[tbl;data]
    / Run check that .tp.date is the current date 
    .tp.ts"d"$currentTimestamp:.z.P;
    / Append timespan to data if not present
    if[not -16=type first first data;
        currentTime:"t"$currentTimestamp;
        data:$[0>type first data;
              currentTime,data;
              (enlist(count first data)#currentTime),data
              ]
        ];
    tblCols:key flip value tbl;
    / Publish the data 
    .u.pub[tbl;$[0>type first data;enlist tblCols!data;flip tblCols!data]];
    / Append data to the TP log file if present, increment global msg cnt
    if[.tp.tpLogHdl;
       .tp.tpLogHdl enlist (`upd;tbl;data);
       .tp.logMsgCnt+:1
       ];
    };

/ =============================================================================
/ [d] TP Intialize  
/ ============================================================================= 

.tp.init[.config.tpLogName;.config.dir.tpLogDir];

.z.ts:{.tp.ts .z.D}; 
