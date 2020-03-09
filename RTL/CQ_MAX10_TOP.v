// CQ_MAX10_TOP.v
//      CQ_MAX10_TOP()
//
//
//J3Gu : I2C DAC MCP4726 Bridge
//J14g
//  IA : ULTRA_SONIC try1

`include "RTL/SUPER_SONIC_OSC.v"
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
    , input     P29     //CLK1_p
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
    parameter C_F_CK = 100_000_000  ;//100MHz
    always@(posedge CK or negedge pll_locked)
        if( ~ pll_locked )
            PLL_LOCKED_Ds <= 0 ;
        else
            PLL_LOCKED_Ds <= {PLL_LOCKED_Ds , 1'b1 } ;
    assign XARST = PLL_LOCKED_Ds[1] ;
    wire CK_i = CK ;
    wire XARST_i = XARST ;

//        , .A_IN_i       ( P59       )
//        , .B_IN_i       ( P57       )
//    assign P58 = 1'b0 ;

    wire    DSDAC_o     ;
    wire    XDSDAC_o    ;
    wire[7:0]   BUS_WAVE_CYCLEs_i    ;
    wire        BUS_WAVE_IS_SAW_i   ;
    wire[11:0]  WAVEs_o ;
    SUPER_SONIC_OSC
        #( 
            .C_F_CK     (   C_F_CK  )
        ) SUPER_SONIC_OSC
        (
              .CK_i                 ( CK_i              )
            , .XARST_i              ( XARST_i           )
//            , .CK_EE_i              ()
            , .BUS_WAVE_CYCLEs_i    ( BUS_WAVE_CYCLEs_i )
            , .BUS_WAVE_IS_SAW_i    ( BUS_WAVE_IS_SAW_i )
            , .DSDAC_o              ( DSDAC_o           )
            , .XDSDAC_o             ( XDSDAC_o          )
            , .WAVEs_o              ( WAVEs_o           )
        ) 
    ; // SUPER_SONIC_OSC
    

    
    wire [63:0] BJO_DBGOs ;
    wire [23:0] BJ_DBGs ;
    JTAG_DBGER 
    JTAG_DBGER 
    (
          .probe    ( BJO_DBGOs  )
        , .source   ( BJ_DBGs    )
    ) ;
    `include "./MISC/TIMESTAMP.v"
    assign BJO_DBGOs[31:0] = 
        (BJ_DBGs[22]) ?
            C_TIMESTAMP
        :
            WAVEs_o
    ;
    assign BUS_WAVE_CYCLEs_i = BJ_DBGs[7:0] ;
    assign BUS_WAVE_IS_SAW_i = BJ_DBGs[8] ;

//    assign P41 = DAC_DONE_o ;
    assign P43 = XDSDAC_o ;
    assign P44 = DSDAC_o ;
    assign XLED_R_o         = ~ BJ_DBGs[ 23 ] ;
    assign XLED_G_o         = ~ BJ_DBGs[ 23 ] ;
    assign XLED_B_o         = ~ BJ_DBGs[ 23 ] ;


/*    assign P17 ;//NG
    assign P14 = DAC_P_o ;//NG
    assign P13 = DAC_P_o ;//NG
    assign P12 = DAC_P_o ;//NG
*/
endmodule //CQ_MAX10_TOP
