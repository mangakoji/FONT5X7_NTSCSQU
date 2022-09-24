// CQ_MAX10_TOP.v
//      CQ_MAX10_TOP()
//
//
//J3Gu : I2C DAC MCP4726 Bridge
//J14g
//  IA : ULTRA_SONIC try1

`ifndef FPGA_COMPILE
  `ifndef CQ_MAX10_TOP
    `include "../../RTL/FONT5X7_NTSCSQU_TOP.v"
  `endif
`endif
`ifndef CQ_MAX10_TOP
`include "../../RTL/MISC/define.vh"
`default_nettype none
module CQ_MAX10_TOP
#(
    parameter C_F_MCK = 48_000_000
    // 910*525*30/1.001
)(
      input     CK48M_i     //CLK0_p    27
    , input     XPSW_i      //123
    , output    XLED_R_o    //120
    , output    XLED_G_o    //122
    , output    XLED_B_o    //121

    // CN1
    , inout     P62
    , inout     P61
    , inout     P60
    , inout     P59
    , inout     P58
    , inout     P57
    , inout     P56
    , inout     P55
    , inout     P52
    , inout     P50
    , inout     P48
    , inout     P47
    , inout     P46
    , inout     P45
    , inout     P44
    , inout     P43
    , inout     P41
    , inout     P39
    , inout     P38
    // CN2
    , inout     P124
    , inout     P127
    , inout     P130
    , inout     P131
    , inout     P132
    , inout     P134
    , inout     P135
    , inout     P140
    , inout     P141
//    , inout     P3 //analog AD pin
    , inout     P6
    , inout     P7
    , inout     P8
    , inout     P10
    , inout     P11
    , inout     P12
    , inout     P13
    , inout     P14
    , inout     P17

    // CN5
    , input     P28     //CLK1_n
    , inout     P29     //CLK1_p
    , inout     P30     
    , inout     P32
    , inout     P33
    , inout     P54

    // CN6
    , inout     P21
    , inout     P22
    , inout     P24
    , inout     P25
    , input     P26     //CLK0_n

    //SDRAM
    , output[1:0]   SDRAM_BADRs_o
    , output[12:0]  SDRAM_ADRs_o
    , output        SDRAM_CLK_o
    , output        SDRAM_QDML_o
    , output        SDRAM_QDMH_o
    , output        SDRAM_CKE_o
    , output        SDRAM_XCS_o
    , output        SDRAM_XWE_o
    , output        SDRAM_XRAS_o
    , output        SDRAM_XCAS_o
    , inout [15:0]  SDRAM_DATs_io
) ;
    function integer log2;
        input integer value ;
    begin
        value = value-1;
        for (log2=0; value>0; log2=log2+1)
            value = value>>1;
    end endfunction


    // start
    wire            pll_locked      ;
    reg [1:0]       PLL_LOCKED_Ds   ;
    wire            XARST           ;
    wire            CK              ;
    PLL u_PLL(
              .areset       ( 1'b0          )
            , .inclk0       ( CK48M_i       )
            , .c0           ( CK            )
            , .locked       ( pll_locked    )
    ) ;
//    parameter C_F_CK = 48_000_000 *6/7*8  ;
    parameter C_F_CK = 135_000_000 ;
    always@(posedge CK or negedge pll_locked)
        if( ~ pll_locked )
            PLL_LOCKED_Ds <= 0 ;
        else
            PLL_LOCKED_Ds <= {PLL_LOCKED_Ds , 1'b1 } ;
    assign XARST = PLL_LOCKED_Ds[1] ;
    wire CK_i = CK ;
    wire XARST_i = XARST ;

    `w[1:0]  PSWs_i     ;
    `w LED_R_o ;
    `w LED_G_o ;
    `w LED_B_o ;

    `include "./MISC/TIMESTAMP.v"
    `w VIDEO_o ;
    `w SOUND_o ;
    `w[31:0] LEDs_ON ;
    `w[31:0] DBGOs ;
    FONT5X7_NTSCSQU_TOP
        #(  .C_F_CK     ( C_F_CK    )
        )FONT5X7_NTSCSQU_TOP
        (
             .CK_i              ( CK_i                  )//n x 12.27272MHz
            ,.XARST_i           ( XARST_i               )
            ,.BUS_TIME_STAMPs_i ( C_TIMESTAMP           )
            ,.XPSW_i            ( ~ PSWs_i      [0]     )
            ,.VIDEO_o           ( VIDEO_o               )
            ,.SOUND_o           ( SOUND_o               )
        ) 
    ;
    wire [63:0] BJO_DBGOs ;
    wire [23:0] BJ_DBGs ;
    JTAG_DBGER 
    JTAG_DBGER 
    (
          .probe    ( BJO_DBGOs  )
        , .source   ( BJ_DBGs    )
    ) ;
    assign BJO_DBGOs[31:0] = 
        (BJ_DBGs[22]) ?
            C_TIMESTAMP
        :
            {
                  LEDs_ON
                , DBGOs
            } 
    ;

    assign LED_R_o         = BJ_DBGs[ 23 ] ;
    assign LED_G_o         = BJ_DBGs[ 23 ] ;
    assign LED_B_o         = BJ_DBGs[ 23 ] ;
    `w SCLK_o ;
    `w XSS_1_o ;
    `w CIPO_0_i ;
    `w CIPO_1_i ;
    `w COPI_o ;
    `w XSS_2_o ;
    `w XSS_0_o ;
    `w CIPO_2_i ;

    `a LED_R_o = BJ_DBGs[ 23 ] ;
    `a LED_G_o = BJ_DBGs[ 23 ] ;
    `a LED_B_o = BJ_DBGs[ 23 ] ;


    // pin port list
//    `a CK48M_i            ;//27  CLK0_p
//    `a XPSW_i             ;//123
    `a PSWs_i[0] = ~ XPSW_i   ;//123
    `a XLED_R_o = ~LED_R_o  ;//120
    `a XLED_G_o = ~LED_G_o  ;//122
    `a XLED_B_o = ~LED_B_o  ;//121
    // CN1
    `a P62 = 1'bz ;
    `a P61 = 1'bz ;
    `a P60 = 1'bz ;
    `a P59 = 1'bz ;
    `a P58 = 1'bz ;
    `a P57 = 1'bz ;
    `a P56 = 1'bz ;
    `a P55 = 1'bz ;
    `a P52 = 1'bz ;
    `a P50 = 1'bz ;
    `a P48 = 1'bz ;
    `a P47 = 1'bz ;
    `a P46 = 1'bz ;
    `a P45 = 1'bz ;
    `a P44 = 1'bz ;
    `a P43 = 1'bz ;
    `a P41 = 1'bz ;
    `a P39 = 1'bz ;
    `a P38 = 1'bz ; 
    // CN2
    `a P124 = 1'bz ;
    `a CIPO_2_i = P124  ; //10
    `a P127 = XSS_0_o   ; // 9
    `a P130 = XSS_2_o   ; // 8
    `a P131 = COPI_o    ; // 7
    `a P132 = 1'bz ;
    `a CIPO_1_i = P132  ; // 6
    `a P134 = 1'bz ;
    `a CIPO_0_i = P134  ; // 5
    `a P135 = XSS_1_o   ; // 4
    `a P140 = SCLK_o    ; // 3
    `a P141 = 1'bz ;
//      P3 //fix analog AD0 pin
    `a P6  = 1'bz ; //AD1
    `a P7  = 1'bz ; //AD2
    `a P8  = 1'bz ; //AD3
    `a P10 = 1'bz ; //AD4
    `a P11 = SOUND_o ; //AD5
    `a P12 = 1'bz ; //AD6   //NG@#1
    `a P13 = 1'bz ; //AD7   //NG@#1
    `a P14 = VIDEO_o ; //AD8
    `a P17 = 1'bz ;         //NG@#1
    // CN5
//    `a P28 = 1'bz ; //CLK1_n 
    `a P29 = 1'bz ; //CLK1_p 
    `a P30 = 1'bz ;
    `a P32 = 1'bz ;
    `a P33 = 1'bz ;
    `a P54 = 1'bz ;
    // CN6
    `a P21 = 1'bz ;
    `a P22 = 1'bz ;
    `a P24 = 1'bz ;
    `a P25 = 1'bz ;
//    `a P26 ; //CLK0_n
    //SDRAM
    `a SDRAM_BADRs_o = 2'bzz ;
    `a SDRAM_ADRs_o  = {13{1'bz}} ;
    `a SDRAM_CLK_o   = 1'bz ;
    `a SDRAM_QDML_o  = 1'bz ;
    `a SDRAM_QDMH_o  = 1'bz ;
    `a SDRAM_CKE_o   = 1'bz ;
    `a SDRAM_XCS_o   = 1'bz ;
    `a SDRAM_XWE_o   = 1'bz ;
    `a SDRAM_XRAS_o  = 1'bz ;
    `a SDRAM_XCAS_o  = 1'bz ;
    `a SDRAM_DATs_io = {16{1'bz}} ;
endmodule //CQ_MAX10_TOP
    `define CQ_MAX10_TOP
`endif
