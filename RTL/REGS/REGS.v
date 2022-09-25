// REGS.v
//  
//  TB_REGS ()
//      REGS    ()
//          "REGS_init.vh"
//          REGS_CORE    ()
//M9Jm  :start wt RTL


`ifndef REGS_CORE
    `include "../MISC/define.vh"
    `default_nettype none
module REGS_CORE
#(
     `p C_DAT_W   = 8
    ,`p C_ADR_W   = 4
    ,`p C_ADRs    = 8'hFF
    ,`p C_USEs    = 8'hFF
    ,`p C_DEFAULTs= 8'hAA
)(
     `in`tri1               CK_i
    ,`in`tri1               XARST_i
    ,`in`tri0               RST_i
    ,`in`tri1[C_ADR_W-1:0]  ADRs_i
    ,`in`tri0[C_DAT_W-1:0]  WDATs_i
    ,`in`tri0               WT_i
    ,`in`tri0[C_DAT_W-1:0]  USR_WDATs_i
    ,`in`tri0[C_DAT_W-1:0]  USR_WTs_i
    ,`out`w[C_DAT_W-1:0]     REGs_o
    ,`in`tri1[C_DAT_W-1:0]  RDATsI_i
    ,`in`tri0               RD_i
    ,`out`w[C_DAT_W-1:0]    RDATsO_o
);
    `w hit = (ADRs_i == C_ADRs) ;
    `r[C_DAT_W-1:0] REGs ;
    `gen
        `gv gi ;
        `fori(gi,C_DAT_W)
        `b: g_REG
            if( C_USEs[gi])
            `b
                `ack`xar
                    REGs[gi] <= C_DEFAULTs[gi] ;
                else
                `b
                    if( WT_i & hit )
                        REGs[gi] <= WDATs_i[gi] ;
                    `elif( RST_i )
                        REGs[gi] <= C_DEFAULTs[gi] ;
                    `elif( USR_WTs_i[gi] )
                        REGs[gi] <= USR_WDATs_i[gi] ;
                `e
                `a REGs_o[gi] = REGs[gi] ;
                `a RDATsO_o[gi] = (RD_i & hit)? REGs[gi] : 0;
            `eelse
            `b
                `a REGs_o[gi] = C_DEFAULTs[gi] ;
                `a RDATsO_o[gi] =
                    (RD_i & hit)
                    ?                   (C_DEFAULTs[gi]|RDATsI_i[gi])
                    :                   0
                ;
            `e
        `e
    `egen
endmodule
    `define REGS_CORE
    `default_nettype wire
`endif


`ifndef REGS
/* well-known baudrate
      110
      300
      600
    1_200
    2_400
    4_800
    9_600
   14_400
   19_200
   38_400
   57_600
  112_500
  230_400
  460_800
  500_000 ??
  576_000 ??
  921_600
1_000_000 ??
1_152_000
1_500_000 ??
2_000_000 ??
6_250_000 ?
*/
    `include "../MISC/define.vh"
    `default_nettype none
module REGS
#(
      `p C_DAT_W = 8
    , `p C_ADR_W = 4
)(
     `in`tri0                           CK_i
    ,`in`tri1                           XARST_i
    ,`in`tri0                           RST_i
    ,`in`tri1[C_ADR_W-1:0]              ADRs_i
    ,`in`tri0[C_DAT_W-1:0]              WDATs_i
    ,`in`tri0                           WT_i
    ,`in`tri0[(2**C_ADR_W*C_DAT_W-1):0] USR_WDATss_i
    ,`in`tri0[(2**C_ADR_W*C_DAT_W-1):0] USR_WTss_i
    ,`in`tri0                           RD_i
    ,`out`w[(2**C_ADR_W)*C_DAT_W-1:0]   REGss_o
    ,`in`tri0[(2**C_ADR_W)*C_DAT_W-1:0] RDATss_i
    ,`out`w[C_DAT_W-1:0]                TX_Dat_s_o
) ;
    `include "./REGS_init.vh"
    `w[C_DAT_W-1:0] TX_Dat_s_s [0:(2**C_ADR_W-1)] ;
    `gen
        `gv gi ;
        `fori(gi,(2**C_ADR_W))
        `b:g_REGS
            `w[C_DAT_W-1:0] TX_DATs_A ;
            REGS_CORE
                #(
                     .C_DAT_W   ( C_DAT_W   )
                    ,.C_ADR_W   ( C_ADR_W   )
                    ,.C_ADRs    ( gi        )
                    ,.C_USEs    ( `slice(C_INITss,(2*gi+1),C_DAT_W) )
                    ,.C_DEFAULTs( `slice(C_INITss,(2*gi  ),C_DAT_W) )
                )REGS_CORE
                (
                     .CK_i              ( CK_i                          )
                    ,.XARST_i           ( XARST_i                       )
                    ,.RST_i             ( RST_i                         )
                    ,.ADRs_i            ( ADRs_i                        )
                    ,.WT_i              ( WT_i                          )
                    ,.WDATs_i           ( WDATs_i                       )
                    ,.USR_WDATs_i       ( `slice(USR_WDATss_i,gi,C_DAT_W))
                    ,.USR_WTs_i         ( `slice(USR_WTss_i  ,gi,C_DAT_W))
                    ,.REGs_o            ( `slice(REGss_o ,gi,C_DAT_W)   )
                    ,.RDATsI_i          ( `slice(RDATss_i,gi,C_DAT_W)   )
                    ,.RD_i              ( RD_i                          )
                    ,.RDATsO_o          ( TX_DATs_A                     )
                )
            ;
            if(gi==0)
                `a TX_Dat_s_s[gi] =TX_DATs_A ;
            else
                `a TX_Dat_s_s[gi]= TX_Dat_s_s[gi-1] | TX_DATs_A ;
        `e
    `egen
    `a TX_Dat_s_o= RD_i ? TX_Dat_s_s[2**C_ADR_W-1] : 0 ;
endmodule
    `define REGS
    `default_nettype wire
`endif


`ifndef FPGA_COMPILE
    `ifndef TB_REGS
        `include "../MISC/define.vh"
        `default_nettype none
        `timescale 1ns/1ns
module TB_REGS
#(
    parameter C_C=10.0
)(
) ;
    reg CK_i ;
    initial `b
        CK_i <= 1'b1 ;
        forever begin
            #(C_C/2.0)
                CK_i <= ~ CK_i ;
        end
    end
    reg XARST_i ;
    initial begin
        XARST_i <= 1'b1 ;
        #(0.1 * C_C)
            XARST_i <= 1'b0 ;
        #(3.1 * C_C)
            XARST_i <= 1'b1 ;
    end

    `r[7:0] BYTEs ;
    `r      REQ ;
    `w      TX_STB ;
    `w      TXD ;
    REGS
        #(
              .C_F_CK       ( 1000      )
            , .C_BAUD       (  100      )
        )REGS
        (
              .CK_i         ( CK_i      )
            , .XARST_i      ( XARST_i   )
            , .BYTEs_i      ( BYTEs     )
            , .REQ_i        ( REQ       )
            , .TXD_o        ( TXD       )
            , .STB_o        ( TX_STB    )
        )
    ;//REGS

    `r TX_STB_D ;
    `ack`xar
    `b                                  REQ <= 1'b0 ;
                                        BYTEs <= 0 ;
                                        TX_STB_D <= 1'b0 ;
    `e else
    `b
                                        TX_STB_D <= TX_STB ;
        if( TX_STB & ~TX_STB_D )
        `b                              REQ <= 1'b1 ;
        `eelif( ~TX_STB & TX_STB_D)
        `b                              REQ <= 1'b0 ;
                                        BYTEs <= BYTEs + 1 ;
        `e
    `e
    `w[7:0] RX_BYTEs ;
    `w      RX_DONE ;
    UART_RX_CORE
        #(
              .C_F_CK       ( 1000      )
            , .C_BAUD       (  100      )
        )UART_RX_CORE
        (
              .CK_i         ( CK_i      )
            , .XARST_i      ( XARST_i   )
            , .RXD_i        ( TXD       )
            , .BYTEs_o      ( RX_BYTEs  )
            , .DONE_o       ( RX_DONE   )
        )
    ;//UART_RX_CORE

    `r[7:0] STRB_BYTEs ;
    `ack`xar    STRB_BYTEs <= ~0 ;
    else
        if( RX_DONE )
            STRB_BYTEs <= RX_BYTEs ;


    integer ii ;
    initial
    `b
        for(ii=0;ii<=2**12;ii=ii+1)
        `b
            repeat(10) @(posedge CK_i) ;
        `e
        repeat(100) @(posedge CK_i) ;
        $stop ;
        $finish ;
    `e
endmodule
        `define TB_REGS
        `default_nettype wire
    `endif
`endif
