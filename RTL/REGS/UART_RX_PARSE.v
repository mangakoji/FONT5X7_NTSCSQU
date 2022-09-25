// UART_RX_PARSE.v
//  
//  UART_RX_PERSE    ()
//  UART_RX_CORE    ()
//  TB_UART_TX_CORE ()
//L38m  :start wt RTL

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
    `include "./UART_CORE.v"
`endif

`ifndef UART_RX_PARSE
    `include "../MISC/define.vh"
    `default_nettype none
module UART_RX_PARSE
#(
     `p C_F_CK      = 135_000_000  //MHz
    ,`p C_BAUD      =      31_250  //bps for MIDI fix
    ,`p C_DAT_W     = 8
    ,`p C_ADR_W     = 4
)(
      input tri0    CK_i
    , input tri1    XARST_i
    , `in`tri0      RXD_i
    ,`out`w[7:0]    ADRs_o
    ,`out`w[7:0]    WDATs_o
    ,`out`w         WT_REQ_o
    // WT(RX_DAT) no ack, expect 1ck wt action

    ,`in`tri0[7:0]  RDATs_i
    ,`out`w         RD_REQ_o
    ,`in`tri1       RD_ACK_i
    ,`out`w         TXD_o
) ;
    `w[7:0] RX_BYTEs        ;
    `w[3:0] HEXs            ;
    `w      CRLF_DET        ;
    `w      W_DET           ;
    `w      R_DET           ;
    `w      RX_BYTE_DONE    ;
    `r[1:0] RXD_Ds ;
    `ack`xar RXD_Ds <= ~0 ;
    else                                `sfl(RXD_Ds,RXD_i) ;
    `w RXD = RXD_Ds[1] ;
    UART_RX_CORE
        #(
              .C_F_CK                   ( C_F_CK      )
            , .C_BAUD                   ( C_BAUD      )
        ) UART_RX_CORE
        (
             .CK_i                      ( CK_i          )
            ,.XARST_i                   ( XARST_i       )
            ,.RXD_i                     ( RXD           )
            ,.BYTEs_o                   ( RX_BYTEs      )
            ,.HEXs_o                    ( HEXs          )
            ,.CRLF_DET_o                ( CRLF_DET      )
            ,.W_DET_o                   ( W_DET         )
            ,.R_DET_o                   ( R_DET         )
            ,.DONE_o                    ( RX_BYTE_DONE  )
        )
    ;
    // log2() for calc bit width from data N
    // constant function on Verilog 2001
    `func `int log2 ;
        `in `int value ;
    `b
        value = value - 1 ;
        for(log2=0 ; value>0 ; log2=log2+1)
            value = value>>1 ;
    `eefunc
    `w TX_STB ;
    `r[ 7:0]R_DET_Ds  ;
    `r[ 7:0]W_DET_Ds  ;
    `r[5*4-1:0] HEXss ;
    `r[1:0] RD_ACK_Ds ;
    `w RD_ACK = RD_ACK_Ds[1] ;
    `r      TX_REQ ;
    `r[C_ADR_W-1:0] ADRs ;
    `r              REG_WT_REQ ;
    `r[1:0]         TX_WORD_CTRs ;
    `r[2:0]         TX_STATEs ;
    `r[C_DAT_W-1:0] TX_BUFs ;
    `r              REG_RD_REQ ;
    `ack`xar
    `b
        R_DET_Ds<= 0 ;
        W_DET_Ds<= 0 ;
        HEXss   <= ~0 ;
        ADRs    <= ~0 ;
        REG_WT_REQ <= 1'b0 ;
        REG_RD_REQ <= 1'b0 ;
        TX_WORD_CTRs  <= 0 ;
        TX_STATEs <= 0 ;
        TX_REQ <= 1'b0 ;
        TX_BUFs <= 0 ;
    `eelse
    `b
                                        `sfl( RD_ACK_Ds  , RD_ACK_i) ;
        if( RX_BYTE_DONE )
        `b
                                        `sfl(R_DET_Ds , R_DET) ;
                                        `sfl(W_DET_Ds , W_DET) ;
                                        `sfl(HEXss   , HEXs) ;
            if(~TX_STB)
            `b                          TX_REQ <= 1'b0 ;
                                        TX_STATEs <= 1 ;
            `eelse
            `b                          TX_REQ <= 1'b1 ;
                                        TX_STATEs <= 2 ;
            `e
        `e
                                        REG_WT_REQ <= 1'b0 ;
        if( RX_BYTE_DONE )
        `b
            if( CRLF_DET )
            `b
                // W0123#
                // 43210-
                if(W_DET_Ds[4])
                `b                      ADRs <= HEXss[4*2+:8] ;
                                        REG_WT_REQ <= 1'b1 ;
                // W01#
                // 210-
                `eelif(W_DET_Ds[2])
                `b                      
                                        `inc( ADRs ) ;
                                        REG_WT_REQ <= 1'b1 ;
                `e
                // R01#
                // 210-
                if(R_DET_Ds[2])
                `b                      ADRs <= HEXss[0+:8];
                                        TX_REQ <= 1'b0 ;
                                        REG_RD_REQ <= 1'b1 ;
                                        TX_WORD_CTRs <= 0 ;
                                        TX_STATEs <= 3 ;
                // R#
                // 0-
                `eelif(R_DET_Ds[0])
                `b                      `inc( ADRs ) ;
                                        REG_RD_REQ <= 1'b0 ;
                                        TX_REQ <= 1'b0 ;
                                        TX_WORD_CTRs <= 1 ;   
                                        TX_STATEs <= 3 ;   
                `e
            `e
        `e
        case( TX_STATEs )
            0:                          TX_WORD_CTRs <= 0 ; //IDLE

            1:`b
                if(~TX_STB)
                `b
                                        TX_REQ <= 1'b1 ;
                                        `inc( TX_STATEs ) ;
                `e
            `e
            
            2:`b
                if( TX_STB )
                `b
                                        TX_REQ <= 1'b0 ;
                                        TX_STATEs <= 0 ;
                `e
            `e

            3:`b
                if(RD_ACK)
                `b
                                        REG_RD_REQ <= 1'b0 ;
                                        TX_BUFs <= RDATs_i ;
                    if(~TX_STB)
                    `b
                                        TX_REQ <= 1'b0 ;
                                        `inc( TX_STATEs ) ;
                    `eelse
                    `b                  
                                        TX_REQ <= 1'b1 ;
                                        TX_STATEs <= TX_STATEs + 2 ;
                    `e
                `e
            `e

            4:`b
                if( TX_STB )            // wait TX_STB 
                `b                      TX_REQ <= 1'b1 ;
                                        `inc( TX_STATEs ) ;
                `e
            `e
            5:`b                        
                if( ~TX_STB )           // wait ~TX_STB
                `b                      TX_REQ <= 1'b0 ;
                                        `inc( TX_STATEs ) ;
                `e
            `e
            6:`b
                                        TX_STATEs <= TX_STATEs ;
                                        TX_REQ <= 1'b0 ;
                if( TX_STB )            // wait TX_STB
                `b 
                    if(TX_WORD_CTRs<1)
                    `b                  ADRs <= HEXss[12+:4] ;
                                        `sfl(TX_BUFs , 4'hF) ;
                                        `inc( TX_WORD_CTRs ) ;
                                        TX_REQ <= 1'b1 ;
                                        TX_STATEs <= 5 ;
                    `eelse
                    `b
                                        TX_WORD_CTRs <= 0 ;
                                        TX_STATEs <= 0 ;
                    `e
                `e
            `e
        `ecase
    `e
    `a ADRs_o = ADRs ;
    `a WDATs_o = HEXss[4+:8] ;
    `a WT_REQ_o = REG_WT_REQ ;
    `a RD_REQ_o = REG_RD_REQ ;
    `w[7:0]TX_word_s = 
        (TX_STATEs <= 2)
        ?                           RX_BYTEs
        :(TX_BUFs[7:4]<10)
        ?                           ( 8'h30 + TX_BUFs[7:4])
        :                           ( 8'h3F + TX_BUFs[6:4])
    ;
    UART_TX_CORE
        #(
              .C_F_CK       ( C_F_CK      )
            , .C_BAUD       ( C_BAUD      )
        )UART_TX_CORE
        (
              .CK_i                     ( CK_i          )
            , .XARST_i                  ( XARST_i       )
            , .BYTEs_i                  ( TX_word_s     )
            , .REQ_i                    ( TX_REQ        )
            , .TXD_o                    ( TXD_o         )
            , .STB_o                    ( TX_STB        )
        )
    ;//UART_TX_CORE
endmodule
    `define UART_RX_PARSE
    `default_nettype wire
`endif


`ifndef FPGA_COMPILE
    `ifndef TB_UART_CORE
        `include "../MISC/define.vh"
        `default_nettype none
        `timescale 1ns/1ns
module TB_UART_CORE
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
    UART_TX_CORE
        #(
              .C_F_CK       ( 1000      )
            , .C_BAUD       (  100      )
        )UART_TX_CORE
        (
              .CK_i         ( CK_i      )
            , .XARST_i      ( XARST_i   )
            , .BYTEs_i      ( BYTEs     )
            , .REQ_i        ( REQ       )
            , .TXD_o        ( TXD       )
            , .STB_o        ( TX_STB    )
        )
    ;//UART_TX_CORE

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
        `define TB_UART_CORE
        `default_nettype wire
    `endif
`endif
