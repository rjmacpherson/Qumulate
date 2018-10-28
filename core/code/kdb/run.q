/ Main Script to Run Components

/ =============================================================================
/ [a] List Usage and Global Variables Information 
/ =============================================================================

/ run.q -component [component]

/ Run script has to load configuration and default libraries for the component 
/ Then load the comonent script 

/ =============================================================================
/ [b] Load Configuration Settings and Utility Functions  
/ ============================================================================= 

/ Set Configuration Directories

/ Load configuration library 
.config.dir.kdbhome  : (getenv`KDBHOME);
system"l ",.config.dir.kdbhome,"/lib/config.q";

if[`component in key .config.cmdLine;
   system raze "l ",.config.cmdLine`component];
