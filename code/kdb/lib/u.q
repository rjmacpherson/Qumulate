/ Utility Library for TP and RDB Processes 

/ =============================================================================
/ [a]  Global Variables Information 
/ ============================================================================= 

/ GLOBALS
/  .u.tblsToHdlSyms - dictionary of tables->(handle;syms)
/  .u.tbls - table names

/ =============================================================================
/ [b]  Define Utility Functions 
/ ============================================================================= 

/ Initialse function 
/  @returns GLOBAL .u.tbls List of table names in the `. namespace 
/  @returns GLOBAL .u.tblsToHdlSyms dictionary of tables to empty list 
.u.init:{[]
    .u.tbls::tables`.;
    .u.tblsToHdlSyms::.u.tbls!(count .u.tbls)#()
    };

/ Delete the handle to that table in the .u.tblsToHdlSyms dictionary 
/  @param tbl (Symbol) Table 
/  @param hdl (Int) Handle 
.u.del:{[tbl;hdl]
    / Look up the handle in the dictionary and drop it
    .u.tblsToHdlSyms[tbl]_:.u.tblsToHdlSyms[tbl;;0]?hdl 
    };

/ Custom Utility port close function 
/  @param hdl (Int) Handle that was used before port close  
.z.pc:{[hdl]
    .u.del[;hdl] each .u.tbls
    };

/ Simple select function
/  @param tbl (Table) table to select data from
/  @param syms (Symbol(s)) List of symbols to filter select on  
.u.sel:{[tbl;syms]
    / Return all syms if ` passed
    $[`~syms;
        tbl;
        select from tbl where sym in syms
        ]
    };

/ Publish on all handles in .u.tblsToHdlSyms with sym filters  
/  @param tbl(Table) Table to publish
/  @param data  (list of lists) Data to publish
.u.pub:{[tbl;data]
        {[t;d;tblsToHdlSyms]
            if[count d:.u.sel[d;] tblsToHdlSyms 1;
                (neg first tblsToHdlSyms)(`upd;t;d)]
            }[tbl;data] each .u.tblsToHdlSyms tbl
    };  

/ Add subscribers to the .u.tblsToHdlSyms dictionary
/  @param tbl (Symbol) Table to add
/  @param syms (Symbol) Syms to add 
/  @returns (table;schema) of subscribed table
.u.add:{[tbl;syms]
    / Compare counts of tblsToHdls indexed by tbl to 
    $[(count .u.tblsToHdlSyms tbl)>i:.u.tblsToHdlSyms[tbl;;0]?.z.w;
        .[`.u.tblsToHdlSyms; (tbl;i;1); union; syms];
        .u.tblsToHdlSyms[tbl],:enlist(.z.w; syms)
        ];
    (
        tbl;
        / Check if the value of the tbl is a dictionary
        $[99=type val:value tbl;
            / filter based on passed syms if value is a dictionary
            .u.sel[val;] syms;
            / else return the schema of the subscribed table
            0#val
            ]
    )
    };

/ Subscribe function to subscribe to a table 
/  @param tbl (Symbol) table name to subscribe to 
/  @param syms (Symbol(s)) Syms to subscribe to
.u.sub:{[tbls;syms]
    / Subscribe to all tables individually in .u.tbls if passed `
    if[tbls~`;
        :.u.sub[;syms] each .u.tbls
        ];
    / Check that tbl is in .u.tbls else throw signal
    if[not tbls in .u.tbls;
        'tblIsNotIn.u.tbls 
        ];
    .u.del[tbls;] .z.w;
    .u.add[tbls;syms]
    };

/ End of day function 
/  @param date (date) Date to run the end of day function for 
.u.end:{[date]
    / Send .u.end function to all open handles
    (neg union/[.u.tblsToHdlSyms[;;0]])@\:(`.u.end;date)
    };
