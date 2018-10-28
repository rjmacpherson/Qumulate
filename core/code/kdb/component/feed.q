/ Fake Feed Component Script 

/ =============================================================================
/ [a] List Usage and Global Variables Information 
/ =============================================================================

/ Generate a stream of fake quote and trade data
/ Connects to default tick TP on `:localhost:5010

/ =============================================================================
/ [b] Load Configuration Settings and Utility Functions  
/ ============================================================================= 

/ Set Default port if not set on command line 
if[not system"p";system"p 5009"];
.log.info "Port set to ",string system"p"

/ Get tp from cmd line, else set defaults 
$[`tp in key .config.cmdLineArgs;
    .feed.i.tpPort:"I"$first .config.cmdLineArgs`tp;
    .feed.i.tpPort:5010];

/ =============================================================================
/ [c] Create atoms and lists of seed basic data 
/ =============================================================================

.feed.syms :`AMB`AIG`AAPL`DELL`DOW`GOOG`HPQ`INTC`IBM`MSFT;
.feed.pxs  :33 27 84 12 20 72 36 51 42 29; / price
.feed.modes:" ABHILNORYZ"; / mode
.feed.conds:" 89ABCEGJKLNOPRTWZ"; / cond
.feed.exs  :"NONNONONNN"; / ex
.feed.cnt  :count .feed.syms;

.feed.len:10000;

.feed.maxn:15;  / max trades per tick
.feed.qpt :5;   / avg quotes per trade

/ Set random seed to generate consist random numbers for comparision 
\S 235721

/ =============================================================================
/ [d] Fuctions to generate random data, rounding and volumes 
/ =============================================================================

/ Create a list of a random normal distribution 
genNormRand:{[x] exp 0.001*(cos 2*(acos -1)*x?1f)*sqrt neg 2*log x?1f };
/ Rounds a float to 2 .d.p
rndTo2dp:{[x] 0.01*floor 0.5+x*100};
/ Generate a  list of vintegers with a min of 10 and max of 99
vol:{[x] 10+`int$x?90 };

/ =============================================================================
/ [e] Batch Generation, Trades and Quotes Tick Generation
/ =============================================================================

/ Generate a batch of prices
/  @param x (Integer) Length of the batch
/  @returns GLOBAL qx (List of integers) List of symbol indexes
/  @returns GLOBAL qb (List of integers) List of buy margins 
/  @returns GLOBAL qa (List of integers) List of ask margins 
/  @returns GLOBAL qp (List of integers) List of prices 
/  @returns GLOBAL p  (List of integers) List of last price of each sym in batch
/  @returns GLOBAL qn (Integer ) Position within each batch 
batch:{[x]
    qx::x?.feed.cnt;
    qb::rndTo2dp x?1.0;
    qa::rndTo2dp x?1.0;
    ind:where each qx=/:til .feed.cnt;
    dist:genNormRand x;
    / Index into normal distribution
    / Create cumulative product of each list and multiply by base price 
    rawPxs:.feed.pxs*prds each dist ind;
    qp::x#0.0;
    (qp raze ind):rndTo2dp raze rawPxs;
    / last price of each sym in batch
    p::last each rawPxs;
    qn::0 };

/ Generates trade tick data 
/  @param x (Integer) count of the trade tick to be generated
/  @returns (list of lists) data for a trade tick
trades:{[x]
    / If batch length is less than the position plus the number of trades
    / Generate a new batch of random data
    if[not (qn+x)<count qx;
        batch .feed.len];
    / Generate the trade positions and sym indices from the current batch 
    batchInds:qx batchPositions:qn+til x;
    / Increment postion within batch to not repeat data
    qn+:x;
    / Create list of lists for trade tick (sym;price;size;stop;cond;ex)
    (   
        .feed.syms batchInds; 
        qp batchPositions;
        `int$x?99;
        1=x?20;
        x?.feed.conds;
        .feed.exs batchInds
    )
    };

/ Generates quote tick data 
/  @param x (Integer) count of the quote tick to be generated
/  @returns (list of lists) data for a quote tick
quotes:{[x]
    / If batch length is less than the position plus the number of quotes
    / Generate a new batch of random data
    if[not (qn+x)<count qx;
        batch .feed.len];
    / Generate the quote positions and sym indices from the current batch 
    batchInds:qx batchPositions:qn+til x;
    basePx:qp batchPositions;
    / Increment postion within batch to not repeat data 
    qn+:x;
    / Create list of lists for quote tick (sym;bid;ask;bsize;asize;mode;ex)
    (
        .feed.syms batchInds;
        basePx-qb batchPositions;
        basePx+qa batchPositions;
        vol x;
        vol x;
        x?.feed.modes;
        .feed.exs batchInds
    )
    };

/ =============================================================================
/ [f] Feed functions to send to TP
/ =============================================================================

/ Send ticks to TP in list of list format 
feed:{[]
    hTP $[rand 2;
        (".u.upd";`trade;trades 1+rand .feed.maxn);
        (".u.upd";`quote;quotes 1+rand .feed.qpt*.feed.maxn)];
    };

/ =============================================================================
/ [h] Execution 
/ =============================================================================

/  @param host (Symbol) host to connect to 
/  @param port (Integer) Port number to connect to 
/  @param timeOut (Integer) Timeout limit in millise.feed.conds 
connectWithTimeout:{[host;port;timeOut] 
    .log.info "Opening connection to : ",string[host],":",string[port];
    hostPort: hsym `$string[host],":",string port;
    :@[hopen;(hostPort;timeOut);
        {[e;h;p].log.error "Cannot connect to ", string[h],":",string[p]," because: ",e}[;host;port]
        ];
    };

hTP:connectWithTimeout[`localhost;.feed.i.tpPort;2000];
/ Generate an initial batch of data 
batch .feed.len
/ Intialize ticks to be sent to TP every second 
.z.ts:feed
system"t 1000"
