// UART_CORE.v
//  
//  UART_TX_CORE    ()
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
`ifndef UART_RX_CORE
    `include "../MISC/define.vh"
    `default_nettype none
module UART_RX_CORE
#(
      `p C_F_CK     = 135_000_000  //MHz
    , `p C_BAUD  =      31_250  //bps for MIDI fix
)(
      input tri0    CK_i
    , input tri1    XARST_i
    , `in`tri0      RXD_i
    ,`out`w[7:0]    BYTEs_o
    ,`out`w[ 3:0]   HEXs_o
    ,`out`w         CRLF_DET_o
    ,`out`w         W_DET_o
    ,`out`w         R_DET_o
    , `out`w        DONE_o
) ;

    // C_F_CK /27.1 bit
    `lp C_BAUD_N = C_F_CK / C_BAUD ;

    `r[ 7:0]    BUFs ;
    `r          DONE ;
    `r[15:0]    CTRs ;
    `r[ 3:0]    HEXs ;
    `r          CR_D ;
    `r          CRLF_DET ;
    `r          W_DET ;
    `r          R_DET ;
    `w CTR_is_0 = `is0( CTRs) ;
    `r[3:0] PC ;
    `ack`xar
    `b
                                        PC <= 0 ;
                                        DONE <= 1'b0 ;
                                        CTRs <= 0 ;
                                        BUFs <= ~0 ;
                                        HEXs <= ~0 ;
                                        CR_D <= 1'b0 ;
                                        CRLF_DET <= 1'b0 ;
                                        W_DET <= 1'b0 ;
                                        R_DET <= 1'b0 ;
    `e else
    `b
                                        `decc( CTRs ) ;
        case( PC )
            'h0:`b//main
                                        DONE <= 1'b0 ;
                if( CTR_is_0 )
                `b  if( ~ RXD_i )
                    `b                  CTRs <= C_BAUD_N/2-1 ;
                                        `inc( PC ) ;
                    `e
                `e
              `e
            'h1:`b
                if(CTR_is_0)
                `b  if( RXD_i )
                    `b                  CTRs <= C_BAUD_N*2 -1 ;
                                        PC <= 'h000 ; //START_bit NG!wait
                    `eelse
                    `b                  CTRs <= C_BAUD_N-1 ;
                                        `inc( PC );
                    `e
                `e
              `e
            'h2,'h3,'h4,'h5,'h6,'h7,'h8,'h9:
              `b
                if(CTR_is_0)
                `b                      `sfl(BUFs , RXD_i) ;
                                        CTRs <= C_BAUD_N-1;
                                        `inc( PC ) ;
                `e
              `e
            'hA:`b
                if(CTR_is_0)
                `b  if( ~ RXD_i)        // stop_bit NG
                    `b                  CTRs <= C_BAUD_N*2-1 ;
                                        PC <= 'h0 ;
                    `eelse
                    `b                 
                                        HEXs <=
                        (BUFs[7:4]>=4)
                        ?                   (9+{1'b0,BUFs[2:0]})
                        :                   BUFs[3:0]
                                        ;
                                        R_DET <= (BUFs=="R"||BUFs=="r") ;
                                        W_DET <= (BUFs=="W"||BUFs=="w") ;
                                        CR_D <= (BUFs==8'h0D) ;
                                        CRLF_DET <=
                                            (   (   BUFs==8'h0A
                                                )||(
                                                    (~CR_D)
                                                    &(BUFs==8'h0D)
                                                )
                                            )
                                        ;
                                       
                                        DONE <= 1'b1 ;
                                        CTRs <= C_BAUD_N/4-1 ;
                                        PC <= 'h0 ;
                    `e 
                `e
              `e
            'hB:`b
              `e
        `ecase
    `e
    `a BYTEs_o      = BUFs      ;
    `a HEXs_o       = HEXs      ;
    `a CRLF_DET_o   = CRLF_DET  ;
    `a W_DET_o      = W_DET     ;
    `a R_DET_o      = R_DET     ;
    `a DONE_o       = DONE      ;
endmodule
    `define UART_RX_CORE
    `default_nettype wire
`endif


`ifndef UART_TX_CORE
    `include "../MISC/define.vh"
    `default_nettype none
module UART_TX_CORE
#(
      `p C_F_CK = 135_000_000  //MHz
    , `p C_BAUD =     112_500 //bps
)(
      `in`tri0      CK_i
    , `in`tri1      XARST_i
    , `in`tri0[7:0] BYTEs_i
    , `in`tri0      REQ_i
    , `out`w        TXD_o
    , `out`w        STB_o
) ;

    // C_F_CK /27.1 bit
    `lp C_BAUD_N = C_F_CK / C_BAUD ;

    `r          REQ_D   ;
    `r          STB     ;
    `r[ 3:0]    PC      ;
    `r[15:0]    CTRs    ;
    `w CTR_is_0 = `is0(CTRs) ;
    `r[ 7:0]    BUFs    ;
    `r          TXD     ;
    `ack`xar
    `b
                                        STB     <= 1'b0 ;
                                        REQ_D   <= 1'b0 ;
                                        TXD     <= 1'b1 ;
                                        CTRs    <= 0 ;
                                        PC      <= 0 ;
                                        BUFs    <= 0 ;
    `e else
    `b
                                        REQ_D <= REQ_i ;
                                        `decc( CTRs ) ;
        case( PC )
            0:`b
                                        STB <= 1'b1 ;
                    if( REQ_i & ~REQ_D )
                    `b                  STB <= 1'b0 ;
                                        BUFs <= BYTEs_i;
                                        TXD <= 1'b0 ;
                                        CTRs <= C_BAUD_N-1 ;
                                        `inc( PC ) ;
                    `e
              `e
            1,2,3,4,5,6,7,8:
              `b
                if(CTR_is_0)
                `b
                                        `sfl({TXD,BUFs} ,1'b1);
                                        CTRs <= C_BAUD_N-1 ;
                                        `inc( PC ) ;
                `e
              `e
            9:`b
                if(CTR_is_0)
                `b
                                        TXD <= 1'b1 ;
                                        CTRs <= C_BAUD_N-1 ;
                                        `inc( PC ) ;
                `e
            `e
            10:`b
                if(CTR_is_0)
                `b
                                        TXD <= 1'b1 ;
                                        CTRs <= C_BAUD_N-1 ;
                                        STB <= 1'b1 ;
                                        PC <= 0 ;
                `e
              `e
        `ecase
    `e
    `a TXD_o = TXD ;
    `a STB_o = STB ;
endmodule
    `define UART_TX_CORE
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
