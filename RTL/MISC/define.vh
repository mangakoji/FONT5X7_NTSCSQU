//
    `define ack always@(posedge CK_i or negedge XARST_i)
    `define sck always@(posedge CK_i)
    `define xar if(~XARST_i)
    `define xsr if(~XSRST_i)
    `define cke if(CK_EE_i)
    `define b   begin
    `define C   begin
    `define e   end
    `define J   end
    `define D   end
    `define a   assign
    `define func function
    `define efunc endfunction
    `define s   signed
    `define Ds  $signed
    `define in  input
    `define out output
    `define w   wire
    `define r   reg
    `define int integer
    `define gen generate
    `define egen endgenerate
    `define gv genvar
    `define p   parameter
    `define param parameter
    `define lp  localparam
    `define pe  posedge
    `define ne  negedge
    `define rep repeat
    `define init initial
    `define al always
    `define elif else if
    `define elsif else if
