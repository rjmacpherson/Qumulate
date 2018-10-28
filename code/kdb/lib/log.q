/ Logging Library 

/ =============================================================================
/ [a] Configuration Settings 
/ =============================================================================

/ The minimum level to log at. The logging order is DEBUG, INFO, WARN, ERROR, FATAL.
.log.level:`INFO;
/ Configuration to determine if logging functions will be coloured
if[not `logColours in key`.log;.log.logColours:0b];
/ Supported log levels and their output
.log.levels:`TRACE`DEBUG`INFO`WARN`ERROR`FATAL!neg 1 1 1 1 2 2;
/ Colour configuration
.log.colour.DEFAULT:"\033[0m";
.log.colour.TRACE  :.log.colour.DEFAULT;
.log.colour.DEBUG  :.log.colour.DEFAULT;
.log.colour.INFO   :.log.colour.DEFAULT;
.log.colour.WARN   :"\033[1;33m";
.log.colour.ERROR  :"\033[1;31m";
.log.colour.FATAL  :"\033[4;31m";

/ =============================================================================
/ [b] Create Logging Functions  
/ =============================================================================

/ Logging function
/  @param fh (Integer) The file handle to print to
/  @param lvl (Symbol) The level that is being logged
/  @param msg (String) The message to log
/  @returns Log message to passed file handle 
.log.msg:{[fh;lvl;msg]
    logMessage:string [.z.d]," ",string[.z.t]," ",string[lvl]," : ", msg;
    if[.log.logColours;
        logMessage:.log.colour[lvl],logMessage,.log.colour.DEFAULT;
        ];
    fh@logMessage;
    };

/ Configures the logging functions based on the specified level.
/  @param baseLevel (Symbol) The level to log from
.log.setLevel:{[baseLevel]
    if[not baseLevel in key .log.levels;
        '"IllegalArgumentException";
        ];
    logIndex:key[.log.levels]?baseLevel;
    enabled:logIndex _ .log.levels;
    / Create projections of each logging function with correct file handles and colours
    @[`.log;lower key enabled;:;.log.msg .'flip(get;key)@\:enabled];
    -1 "Logging enabled [ Level: ",string[baseLevel]," ]";
    .log.level:baseLevel;
    };

 .log.init:{[]
    .log.setLevel .log.level;
    };

/ =============================================================================
/ [c] Intialization  
/ =============================================================================

 .log.init[];