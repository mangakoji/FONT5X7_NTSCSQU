//VIDEO_SQU.v
// VIDEO_SQU()
//
//
// non interace ,59.94FPS 263line system
//
//K38u :1st

`ifndef FPGA_COMPILE
    `include "./NTSC_SQU_TG.v"
    `include "./NTSC_SQU_ENC.v"
`endif
`ifndef NTSC_SQU
    `include "../MISC/define.vh"
    `default_nettype none
module NTSC_SQU
#(
     `p C_F_CK           = 135_000_000
    ,`p C_PX_DLY         = 3
    ,`p C_CBURST_DLY_N   = 2
    ,`p C_XCBURST_SHUF   = 1'b0 
)(
      `in `tri1     CK_i           //n x 12.27272MHz
    , `in `tri1     XARST_i
    , `in `tri0     RST_i
    ,`out`w         PX_CK_EE_o        //12.27272MHz
    ,`out`w[ 9:0]   HCTRs_o
    ,`out`w[ 9:0]   VCTRs_o
    ,`out`w[ 7:0]   FCTRs_o
    ,`in`tri0[ 5:0] YYs_i
    ,`in`tri0[ 2:0] CPHs_i
    ,`out`w         VIDEO_o
);
    `w      PX_CK_EE    ;
    `w [9:0] HCTRs      ;
    `w [8:0] VCTRs      ;
    `w [7:0] FCTRs      ;
    `w      XBLK        ;
    `w      CBURST_NOW  ;
    `w      XSYNC       ;
    `w[2:0]  BURST_CPHs ;
    NTSC_SQU_TG
        #(
             .C_F_CK            ( C_F_CK            )
            ,.C_PX_DLY          ( C_PX_DLY          )
            ,.C_CBURST_DLY_N    ( C_CBURST_DLY_N    )
//            , .C_XCBURST_SHUF   ( C_XCBURST_SHUF )
        )NTSC_SQU_TG
        (
              .CK_i             ( CK_i          )//n x 12.27272MHz
            , .XARST_i          ( XARST_i       )
            , .PX_CK_EE_o       ( PX_CK_EE      )//12.27272MHz
            , .RST_i            ( RST_i         )
            , .HCTRs_o          ( HCTRs         )
            , .VCTRs_o          ( VCTRs         )
            , .FCTRs_o          ( FCTRs         )
            , .CBURST_NOW_o     ( CBURST_NOW    )
            , .XBLK_o           ( XBLK          )
            , .XSYNC_o          ( XSYNC         )
            , .CPHs_o           ( BURST_CPHs    )
        )
    ;
    `a PX_CK_EE_o = PX_CK_EE ;
    `a HCTRs_o = HCTRs ;
    `a VCTRs_o = VCTRs ;
    `a FCTRs_o = FCTRs ;
    `w HVcy = (VCTRs==(240-1)) & (HCTRs==(640-1)) & PX_CK_EE ;


    `w[5:0]VIDEOs ;
    NTSC_SQU_ENC
//        #(
//              .C_XCBURST_SHUF     ( 1'b1 )
//        )
        NTSC_SQU_ENC
        (
             .CK_i          ( CK_i          )      //8*12.27272MHz
            ,.XARST_i       ( XARST_i       )
            ,.PX_CK_EE_i    ( PX_CK_EE      )        //12.27272MHz
            ,.CBURST_NOW_i  ( CBURST_NOW    )
            ,.CBURST_CPHs_i ( BURST_CPHs    )
            ,.XSYNC_i       ( XSYNC         )
            ,.XBLK_i        ( XBLK          )
            ,.YYs_i         ( YYs_i         )
            ,.CPHs_i        ( CPHs_i        )
            ,.VIDEOs_o      ( VIDEOs        )
        )
    ;
    `r[6:0] DSs ;
    `ack`xar    DSs <= 0 ;
    else                                DSs <= 
                                            {1'b0 , DSs[5:0]} 
                                            + {1'b0,VIDEOs}
                                       ;
    `a VIDEO_o = DSs[6] ;
endmodule
    `default_nettype wire
    `define NTSC_SQU
`endif


`ifndef FPGA_COMPILE
    `ifndef TB_NTSC_SQU
        `timescale 1ns/1ns
        `include "../MISC/define.vh"
        `default_nettype none
module TB_NTSC_SQU
#(
    parameter C_C=10.0
)(
) ;
    reg         CK_EE_i ;
    reg CK_i ;
    initial `b
        CK_EE_i <= 1'b1 ;
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

    `r RST_i ;
    wire[4:0]   VIDEOs_o ;
    `r[17:0] LEDs_ON_i ;
    NTSC_SQU
        NTSC_SQU
        (
              .CK_i     ( CK_i      )      //8*12.27272MHz
            , .XARST_i  ( XARST_i   )
            , .CK_EE_i  ( CK_EE_i   )        //12.27272MHz
            , .RST_i    ( RST_i     )
            , .LEDs_ON_i( LEDs_ON_i )
            , .VIDEOs_o ( VIDEOs_o    )
        )
    ;
    `al@(`pe CK_i or `ne XARST_i)
        if( ~XARST_i)
            LEDs_ON_i   <= ~ 0 ;
        else if(NTSC_SQU.HVcy_o)
            LEDs_ON_i <= ~ LEDs_ON_i ;

    `int ii ;
    initial
    `b
        RST_i <= 1'b1 ;
        repeat(100)@(`pe CK_i) ;
        RST_i <= 1'b0  ;
        for(ii=0;ii<=(2**19);ii=ii+1)
        `b
            @(`pe CK_i) ;
        `e
        repeat(100) @(posedge CK_i) ;
        $stop ;
        $finish ;
    `e
endmodule
        `default_nettype wire
        `define TB_NTSC_SQU
    `endif
`endif
