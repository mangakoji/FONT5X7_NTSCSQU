// REGS_TOP.v
//
//  TB_REGS_TOP ()
//      REGS_TOP    ()
//M9Jm  :start wt RTL
`ifndef REGS_TOP
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
    `ifndef FPGA_COMPILE
        `include "UART_RX_PARSE.v"
        `include "REGS.v"
    `endif
    `include "../MISC/define.vh"
    `default_nettype none
module REGS_TOP
#(
      `p C_DAT_W = 8
    , `p C_ADR_W = 4
    , `p C_F_CK  = 135_000_000  //MHz
    , `p C_BAUD  =   1_152_000  //minum 5CK
)(
     `in`tri0                           CK_i
    ,`in`tri1                           XARST_i
    ,`in`tri0                           RST_i
    ,`in`tri1                           RXD_i
    ,`out`w                             TXD_o
    ,`out`w[(2**C_ADR_W)*C_DAT_W-1:0]   REGss_o
    ,`out`w[C_ADR_W-1:0]                ADRs_o
    ,`out`w                             RD_REQ_o
    ,`in`tri0[(2**C_ADR_W)*C_DAT_W-1:0] RDATss_i
    ,`in`tri1                           RD_ACK_i
    ,`out`w[ 7:0]                       BUS_R9DATs_o
    ,`out`w[ 7:0]                       BUS_R8DATs_o
    ,`out`w[31:0]                       BUS_TIMESTAMPs_o
    ,`out`w[31:0]                       BUS_VERSIONs_o
) ;
    `w[C_DAT_W-1:0]WDATs ;
    `w[C_ADR_W-1:0]ADRs ;
    `w  WT_REQ ;
    `w[C_DAT_W-1:0] TX_Dat_s ;
    UART_RX_PARSE
        #(
             .C_F_CK    ( C_F_CK )
            ,.C_BAUD    ( C_BAUD )
            ,.C_DAT_W   ( C_DAT_W )
            ,.C_ADR_W   ( C_ADR_W )
        )UART_RX_PARSE
        (
             .CK_i                      ( CK_i      )
            ,.XARST_i                   ( XARST_i   )
            ,.RXD_i                     ( RXD_i     )
            ,.ADRs_o                    ( ADRs      )
            ,.WDATs_o                   ( WDATs     )
            ,.WT_REQ_o                  ( WT_REQ    )
            ,.RDATs_i                   ( TX_Dat_s  )
            ,.RD_REQ_o                  ( RD_REQ_o  )
            ,.RD_ACK_i                  ( RD_ACK_i  )
            ,.TXD_o                     ( TXD_o     )
        )
    ;
    `a ADRs_o = ADRs ;

    REGS
        #(
             .C_DAT_W   ( C_DAT_W )
            ,.C_ADR_W   ( C_ADR_W )
        )REGS
        (
             .CK_i                      ( CK_i      )
            ,.XARST_i                   ( XARST_i   )
            ,.RST_i                     ( RST_i     )
            ,.ADRs_i                    ( ADRs      )
            ,.WDATs_i                   ( WDATs     )
            ,.WT_i                      ( WT_REQ    )
            ,.RD_i                      ( RD_REQ_o  )
            ,.REGss_o                   ( REGss_o   )
            ,.RDATss_i                  ( RDATss_i  )
            ,.TX_Dat_s_o                ( TX_Dat_s   )
        )
    ;
    `a BUS_R9DATs_o         = REGss_o[ 9*8+0 +: 8] ;
    `a BUS_R8DATs_o         = REGss_o[ 8*8+0 +: 8] ;
    `a BUS_TIMESTAMPs_o     = REGss_o[ 4*8+0 +:32] ;
    `a BUS_VERSIONs_o       = REGss_o[ 0*8+0 +:32] ;
endmodule
    `define REGS_TOP
    `default_nettype wire
`endif


`ifndef FPGA_COMPILE
    `ifndef TB_REGS_TOP
        `include "../MISC/define.vh"
        `default_nettype none
        `timescale 1ns/1ns
module TB_REGS_TOP
#(
    parameter C_C=10.0
    ,`p C_F_CK  = 50
    ,`p C_BAUD  = 10
    ,`p C_ADR_W = 8
    ,`p C_DAT_W = 8
)(
) ;
    // log2() for calc bit width from data N
    // constant function on Verilog 2001
    `func `int log2 ;
        `in `int value ;
    `b
        value = value - 1 ;
        for(log2=0 ; value>0 ; log2=log2+1)
            value = value>>1 ;
    `eefunc
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


    // TV: Test Vector
    `r[7:0] TV_TX_BYTEs ;
    `r      TV_TX_REQ ;
    `w      TV_TX_STB ;
    `w      RXD_i ;
    UART_TX_CORE
        #(
              .C_F_CK       ( C_F_CK     )
            , .C_BAUD       ( C_BAUD      )
        )TV_UART_TX_CORE
        (
              .CK_i         ( CK_i          )
            , .XARST_i      ( XARST_i       )
            , .BYTEs_i      ( TV_TX_BYTEs   )
            , .REQ_i        ( TV_TX_REQ     )
            , .TXD_o        ( RXD_i         )
            , .STB_o        ( TV_TX_STB     )
        )
    ;//TV_UART_TX_CORE

    `lp C_TV_DATss = {
        {128{8'h00}}
        ,8'h0C
        ,"\n"
        ,"8"
        ,"0"
        ,"R"
        ,"\n"
        ,"A"
        ,"4"
        ,"W"
        ,"\n"
        ,"B"
        ,"3"
        ,"8"
        ,"0"
        ,"W"
        ,"\n"
        ,"B"
        ,"3"
        ,"8"
        ,"0"
        ,"W"
    } ;
    `r[7:0] TV_WORD_CTRs ;
    `r TV_TX_STB_D ;
    `ack`xar
    `b                                  TV_WORD_CTRs <= 0 ;
                                        TV_TX_REQ <= 1'b0 ;
                                        TV_TX_BYTEs <= 0 ;
                                        TV_TX_STB_D <= 1'b0 ;
    `e else
    `b
                                        TV_TX_STB_D <= TV_TX_STB ;
        if( TV_TX_STB & ~TV_TX_STB_D )
        `b                              TV_TX_REQ <= 1'b1 ;
        `eelif( ~TV_TX_STB & TV_TX_STB_D)
        `b                              TV_TX_REQ <= 1'b0 ;
                                        TV_TX_BYTEs <= 
                                            C_TV_DATss
                                            >>(TV_WORD_CTRs*8)
                                        ;
                                        `inc( TV_WORD_CTRs ) ;
        `e
    `e

    `w[2**C_ADR_W*C_DAT_W-1:0]  REGss_o     ;
    `w[C_ADR_W-1:0]             ADRs_o      ;
    `r                          RD_REQ      ;
    `w[2**C_ADR_W*C_DAT_W-1:0]  RDATss_i    ;
    `w                          RD_REQ_o ;
    `a `slice( RDATss_i , 15,C_DAT_W) = (RD_REQ_o) ? 8'hBC :8'h00 ;
    `r[1:0]                     RD_REQ_Ds ;
    `r                          RD_ACK_i    ;
    `r[2:0]                     RD_STATEs ;
    `ack`xar
    `b  RD_ACK_i <= 1'b1 ;
        RD_STATEs <= 0 ;
        RD_REQ_Ds <= 0 ;
    `eelse
    `b                          `sfl( RD_REQ_Ds , RD_REQ_o)  ;
        case( RD_STATEs )
            0:`b
                if(RD_REQ_Ds[1])
                `b              RD_ACK_i <= 1'b0 ;
                                `inc( RD_STATEs ) ;
                `e
            `e 
            1:                  `inc(RD_STATEs ) ;
            2:                  `inc(RD_STATEs ) ;
            3:`b
                                RD_ACK_i <= 1'b1 ;
                                `inc(RD_STATEs ) ;
            `e
            4:`b
                if(~RD_REQ_Ds[1])
                `b              RD_ACK_i <= 1'b0 ;
                                RD_STATEs <= 0 ;
                `e
            `e
        `ecase
    `e
    `w TXD_o ;
    REGS_TOP
        #(
             .C_DAT_W   ( C_DAT_W   )
            ,.C_ADR_W   ( C_ADR_W   )
            ,.C_F_CK    ( C_F_CK    )
            ,.C_BAUD    ( C_BAUD    )
        )REGS_TOP
        (
             .CK_i      ( CK_i     )
            ,.XARST_i   ( XARST_i  )
//            ,.RST_i     ( RST_i    )
            ,.RXD_i     ( RXD_i    )
            ,.TXD_o     ( TXD_o    )
            ,.REGss_o   ( REGss_o  )
            ,.ADRs_o    ( ADRs_o   )
            ,.RD_REQ_o  ( RD_REQ_o )
            ,.RDATss_i  ( RDATss_i )
            ,.RD_ACK_i  ( RD_ACK_i )
        ) 
    ;
    // TP : test Probe
    `w[7:0] TP_RX_BYTEs ;
    `w      TP_RX_DONE ;
    UART_RX_CORE
        #(
              .C_F_CK       ( C_F_CK      )
            , .C_BAUD       ( C_BAUD      )
        ) TP_UART_RX_CORE
        (
              .CK_i         ( CK_i          )
            , .XARST_i      ( XARST_i       )
            , .RXD_i        ( TXD_o         )
            , .BYTEs_o      ( TP_RX_BYTEs  )
            , .DONE_o       ( TP_RX_DONE   )
        )
    ;//TP_UART_RX_CORE

    `r[7:0] STRB_BYTEs ;
    `ack`xar    STRB_BYTEs <= ~0 ;
    else
        if( TP_RX_DONE )
            STRB_BYTEs <= TP_RX_BYTEs ;


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
        `define TB_REGS_TOP
        `default_nettype wire
    `endif
`endif
