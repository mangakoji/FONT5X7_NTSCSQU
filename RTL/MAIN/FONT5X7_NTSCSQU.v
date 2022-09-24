// FONT5X7_NTSCSQU.v
//
//
//
// M9Nf : 1st.

`ifndef FPGA_COMPILE
    `include "./NTSC_SQU.v"
    `include "./RADIAL_CHART.v"
    `include "./FONT5X7.v"
`endif
`ifndef FONT5X7_NTSCSQU
    `include "../MISC/define.vh"
    `default_nettype none
module FONT5X7_NTSCSQU
#(    
      `p C_F_CK = 135_000_000
)(    
     `in`tri1       CK_i
    ,`in`tri1       XARST_i
    ,`in`tri0       RST_i
    ,`out`w         PX_CK_EE_o
    ,`in`tri0[31:0] DISP_DATss_i
    ,`in`tri0[31:0] BUS_TIME_STAMPs_i
    ,`in`tri0[ 7:0] DICE_LEDs_i
    ,`in`tri0       XPSW_i
    ,`out`w         VIDEO_o
) ;
    // constant function on Verilog 2001
    `func `int log2 ;
        `in `int value ;
    `b  value = value - 1 ;
        for(log2=0 ; value>0 ; log2=log2+1)
            value = value>>1 ;
    `e `efunc
    `w PX_CK_EE ;
    `w[ 9:0]HCTRs       ;
    `w[ 8:0]VCTRs       ;
    `w[ 7:0]FCTRs      ;
    `r[ 5:0]YYs      ;
    `r[ 2:0]CPHs     ;
    NTSC_SQU
        #(
              .C_PX_DLY         ( 3              )
            , .C_CBURST_DLY_N   ( 2              )
//            , .C_XCBURST_SHUF   ( C_XCBURST_SHUF )
        )NTSC_SQU
       (
              .CK_i             ( CK_i          )//n x 12.27272MHz
            , .XARST_i          ( XARST_i       )
            , .RST_i            ( RST_i         )
            , .PX_CK_EE_o       ( PX_CK_EE      )//12.27272MHz
            , .HCTRs_o          ( HCTRs         )
            , .VCTRs_o          ( VCTRs         )
            , .FCTRs_o          ( FCTRs         )
            ,.YYs_i             ( YYs           )
            ,.CPHs_i            ( CPHs          )
            ,.VIDEO_o           ( VIDEO_o       )
        )
    ;
    `a PX_CK_EE_o = PX_CK_EE ;
    `w[ 5:0] BG_YYs ;
    `w[ 2:0] BG_CPHs ;
    RADIAL_CHART
        RADIAL_CHART
        (
             .CK_i              ( CK_i          )//n x 12.27272MHz
            ,.XARST_i           ( XARST_i       )
            ,.PX_CK_EE_i        ( PX_CK_EE      )//12.27272MHz
            ,.HCTRs_i           ( HCTRs         )
            ,.VCTRs_i           ( VCTRs         )
            ,.YYs_o             ( BG_YYs        )
            ,.CPHs_o            ( BG_CPHs       )
        )
    ;
    `w[5*16*12-1:0]VDISP_DATss ;
    `a`slice(VDISP_DATss,16* 0+ 0 ,5) = {1'b0 , DICE_LEDs_i[0]} ;
    `a`slice(VDISP_DATss,16* 0+ 8 ,5) = {1'b0 , DICE_LEDs_i[0]};
    `a`slice(VDISP_DATss,16* 0+15 ,5) = {1'b0 , DICE_LEDs_i[0]};
    `a`slice(VDISP_DATss,16* 6+ 0 ,5) = {1'b0 , DICE_LEDs_i[0]};
    `a`slice(VDISP_DATss,16* 6+15 ,5) = {1'b0 , DICE_LEDs_i[0]};
    `a`slice(VDISP_DATss,16*11+ 0 ,5) = {1'b0 , DICE_LEDs_i[0]};
    `a`slice(VDISP_DATss,16*11+ 8 ,5) = {1'b0 , DICE_LEDs_i[0]};
    `a`slice(VDISP_DATss,16*11+15 ,5) = {1'b0 , DICE_LEDs_i[0]};

    `a`slice(VDISP_DATss,16* 1+ 1 ,5) = {1'b1 , BUS_TIME_STAMPs_i[4*7+:4]};
    `a`slice(VDISP_DATss,16* 1+ 2 ,5) = {1'b1 , BUS_TIME_STAMPs_i[4*6+:4]};
    `a`slice(VDISP_DATss,16* 1+ 3 ,5) = {1'b1 , BUS_TIME_STAMPs_i[4*5+:4]};
    `a`slice(VDISP_DATss,16* 1+ 4 ,5) = {1'b1 , BUS_TIME_STAMPs_i[4*4+:4]};
    `a`slice(VDISP_DATss,16* 1+ 6 ,5) = {1'b1 , BUS_TIME_STAMPs_i[4*3+:4]};
    `a`slice(VDISP_DATss,16* 1+ 7 ,5) = {1'b1 , BUS_TIME_STAMPs_i[4*2+:4]};
    `a`slice(VDISP_DATss,16* 1+ 8 ,5) = {1'b1 , BUS_TIME_STAMPs_i[4*1+:4]};
    `a`slice(VDISP_DATss,16* 1+ 9 ,5) = {1'b1 , BUS_TIME_STAMPs_i[4*0+:4]};

    `a`slice(VDISP_DATss,16* 3+ 5 ,5) = {1'b1 , DISP_DATss_i[4*7+:4]};
    `a`slice(VDISP_DATss,16* 3+ 6 ,5) = {1'b1 , DISP_DATss_i[4*6+:4]};
    `a`slice(VDISP_DATss,16* 3+ 7 ,5) = {1'b1 , DISP_DATss_i[4*5+:4]};
    `a`slice(VDISP_DATss,16* 3+ 8 ,5) = {1'b1 , DISP_DATss_i[4*4+:4]};
    `a`slice(VDISP_DATss,16* 3+10 ,5) = {1'b1 , DISP_DATss_i[4*3+:4]};
    `a`slice(VDISP_DATss,16* 3+11 ,5) = {1'b1 , DISP_DATss_i[4*2+:4]};
    `a`slice(VDISP_DATss,16* 3+12 ,5) = {1'b1 , DISP_DATss_i[4*1+:4]};
    `a`slice(VDISP_DATss,16* 3+13 ,5) = {1'b1 , DISP_DATss_i[4*0+:4]};
    `w      FONT_HIT    ;
    FONT5X7
        #(
             .C_BAR_MODE    ( 0         )
            ,.C_HMAGs       ( 6         )
            ,.C_HST         ( 16         )
            ,.C_VMAGs       ( 2         )
            ,.C_VST         ( 8         )
        )FONT5X7
        (
             .CK_i              ( CK_i          )
            ,.XARST_i           ( XARST_i       )
            ,.PX_CK_EE_i        ( PX_CK_EE   )
            ,.DATss_i           ( VDISP_DATss   )
            ,.HCTRs_i           ( HCTRs         )
            ,.VCTRs_i           ( VCTRs         )
            ,.HIT_o             ( FONT_HIT      )
        ) 
    ;
    `ack`xar
    `b
        YYs <= 0 ;
        CPHs <= 0 ;
    `eelif( PX_CK_EE )
    `b
                                        YYs <= (FONT_HIT)? 0 : BG_YYs ;
                                        CPHs <= BG_CPHs ;
    `e
endmodule
    `default_nettype none
    `define FONT5X7_NTSCSQU
`endif


`ifndef FPGA_COMPILE
    `ifndef TB_FONT5X7_NTSCSQU
        `include "../MISC/define.vh"
        `default_nettype none
        `timescale 1ns/1ns
module TB_FONT5X7_NTSCSQU
#(
    `p C_C=10.0
)(
) ;
    `r         CK_EE_i ;
    `r CK_i ;
    `init `b
        CK_EE_i <= 1'b1 ;
        CK_i <= 1'b1 ;
        forever 
        `b  #(C_C/2.0)
                CK_i <= ~ CK_i ;
        `e
    `e
    `r XARST_i ;
    `init 
    `b  XARST_i <= 1'b1 ;
        #(0.1 * C_C)
            XARST_i <= 1'b0 ;
        #(3.1 * C_C)
            XARST_i <= 1'b1 ;
    `e

    `r      XPSW_i      ;
    `w[17:0]LEDs_ON_o   ;
    `w      SOUND_o     ;
    FONT5X7_NTSCSQU
        #(
             .C_DBG_ACC ( ~0        )
        )FONT5X7_NTSCSQU
        (
              .CK_i     ( CK_i      )      //8*12.27272MHz
            , .XARST_i  ( XARST_i   )
            , .XPSW_i   ( XPSW_i    )
            , .LEDs_ON_o( LEDs_ON_o )
            , .SOUND_o  ( SOUND_o   )
        ) 
    ;
    `int kk ;
    `int jj ;
    `int ii ;
    `init
    `b  
        ii <= ~0 ;
        jj <= ~0 ;
        kk <= ~0 ;
        XPSW_i <= 1'b1 ;
        repeat(100)@(`pe CK_i) ;
        for(kk=0;kk<(2**0);kk=kk+1)
        `b  for(jj=0;jj<(3);jj=jj+1)
            XPSW_i <= jj[0] ;
            `b  for(ii=0;ii<(2**20);ii=ii+1)
                `b  
                    @(`pe CK_i) ;
        `e  `e  `e
        repeat(100) @(posedge CK_i) ;
        $stop ;
        $finish ;
    `e
`emodule
        `default_nettype none
        `define TB_FONT5X7_NTSCSQU
    `endif
`endif
