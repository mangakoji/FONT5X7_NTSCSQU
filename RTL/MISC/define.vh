//M74mMB
//L3Hw 5
//    `define ack always@(posedge CK_i or negedge XARST_i)
    `define xar     if(~XARST_i)
    `define cke     if(CK_EE_i)
    `define b       begin
    `define e       end
    `define a       assign
    `define func    function
    `define efunc   endfunction
    `define eefunc  `e endfunction
    `define s       signed
    `define Ds      $signed
    `define us      unsigned
    `define Dus     $unsigned
    `define Du2s(x) `Ds({1'b0,x})
    `define in      input
    `define out     output
    `define io      inout
    `define w       wire
    `define r       reg
    `define int     integer
    `define gen     generate
    `define egen    endgenerate
    `define eegen   `e endgenerate
    `define gv      genvar
    `define ecase   endcase
    `define p       parameter
    `define param   parameter
    `define lp      localparam
    `define pe      posedge
    `define ne      negedge
    `define rep     repeat
    `define init    initial
    `define elif    else if
    `define eelse   `e else
    `define eelif   `e `elif
    `define emodule endmodule
    `define al      always
    `define alc(c)  `al@(`pe(c))
    `define alcr(c,xr) `al@(`pe(c) or `ne(xr))
    `define ack `alcr(CK_i,XARST_i)
    `define fori(gi,N) for(gi=0;gi<N;gi=gi+1)
    `define efor `e
//    `define elsif else if //alrady used ,who? where
    `define emodule endmodule
    `ifdef TANG_FPGA
        `define tri0 wire
        `define tri1 wire
    `else
        `define tri0 tri0
        `define tri1 tri1
    `endif
`define max(a,b)    (((a)>(b))?(a):(b))
`define min(a,b)    (((a)<(b))?(a):(b))
`define inc(x)      x<=((x)+1)
`define dec(x)      x<=((x)-1)
`define is0(x)      ((x)==0)
`define all0(x)     `is0(x)
`define all1(x)     (&x)
`define incc(x)     x<=((&x)?(x):((x)+1))
//`define incc(x,N) x<=((N)==0)?(`all1(x)?~0:((x)+1)):(`cy((x),((N)-1))?((N)-1):((x)+1))
`define decc(x)     x<=((`is0(x))?0:((x)-1))
`define cinc(x,N)   x<=(`cy((x),((N)-1))?0:((x)+1))
`define cdec(x,N)   x<=(`is0((x))?((N)-1):((x)-1))
`define sign(x)     (`Ds(x)<0)
`define abs(x)      (`sign(x)?(-(x)):(x))
`define cy(x,A)     (&((x)|(~A)))
`define sfl(x,A)    x<={x,A}
`define sfr(x,A)    x<=({A,x}>>(`bitw(A)))
`define div(x)      ((1'b1&x) & (~(1'b1&(x>>1))))
`define tgl(x)      x<=~(x)
`define slice(x,n,W) x[((n)*(W))+:(W)]
`define ALL1(N)     {(N){1'b1}}
`define ALL0(N)     {(N){1'b0}}
`define sfls(x,A)   (`sign(A)?((x)>>`abs(A)):((64'd0+(x))<<(A)))
`define keep(x)     x<=(x)
`define sfl1_bitw(x) ({1'b1,x}&{1'b1,~x})
`define bitw(x)     (log2(`sfl1_bitw(x)))
/*
    // log2() for calc bit width from data N
    // constant function on Verilog 2001
    `func `int log2 ;
        `in `int value ;
    `b
        value = value - 1 ;
        for(log2=0 ; value>0 ; log2=log2+1)
            value = value>>1 ;
    `eefunc
*/