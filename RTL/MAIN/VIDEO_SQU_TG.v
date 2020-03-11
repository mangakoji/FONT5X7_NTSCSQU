//VIDEO_SQU_TG.v
// VIDEO_SQU_TG()
//
//
// non interace ,59.94FPS 263line system
//K31u :1st
`include "../MISC/define.vh"
`default_nettype none
module VIDEO_SQU_TG
#(
      `p C_PX_DLY           = 2
    , `p C_CBURST_DLY_N     = 2
    , `p C_XCBURST_SHUF     = 1'b0 
)(
      `in tri1      CK_i           //12.27272MHz
    , `in tri1      XARST_i
    , `in tri1      CK_EE_i        //12.27272MHz
    , `in tri0      RST_i
    , `out `w[9:0]  HCTRs_o
    , `out `w[8:0]  VCTRs_o
    , `out `w[7:0]  FCTRs_o
    , `out `w       XBLK_o
    , `out `w       COLOR_BAR_NOW_o
    , `out `w       XSYNC_o
    , `out `w[1:0]  CPHs_o
    , `out `w[2:0]  CCTRs_o 
    , `out `w[3:0]  sin_s_o //1 start
    , `out `w[3:0]  cos_s_o //6 start
);
    `p C_H_PX_N                 = 780       ;
    `p C_H_ACT_PX_N             = 640       ;
    `p C_H_SYNC_N               = 58        ;//4.7us
    `p C_H_FRONT_COLOR_BAR_N    = 64        ;//19sccycle
    `p C_H_COLOR_BAR_N          = 31        ;//9cycle
    `p C_H_BACK_PORCH_N        = 121       ;//9.4us+6ck from sync ne
//    `p C_H_FRONT_PORCH_N         = 19      ;

    `p C_V_LINE_N               = 263       ;
    `p C_V_ACT_LINE_N           = 240       ;
    `p C_V_SYNC_OFS_N           = 1         ;
    

    `r [9:0] HCTRs      ;
    `r [8:0] VCTRs      ;
    `r [7:0] FCTRs      ;
    `w Hcy ;
    `a Hcy = &(HCTRs |~(C_H_PX_N-1)) ;
    `w Vcy ;
    `a Vcy = &(VCTRs |~(C_V_LINE_N-1)) ;
    `ack
        `xar
        `b
            HCTRs <= (C_H_PX_N  -2) ;
            VCTRs <= (C_V_LINE_N -1) ;
            FCTRs  <= 0 ;
        `e else `cke
        `b
            if( RST_i )
            `b
                HCTRs <= 0 ;
                VCTRs <= 0 ;
                FCTRs  <= 0 ;
            `e else
            `b
                if( Hcy )
                `b
                    HCTRs <= 0 ;
                    if( Vcy )
                    `b
                        VCTRs <= 0 ;
                        FCTRs <= FCTRs + 1 ;
                    `e
                    else
                        VCTRs <= VCTRs + 1 ;
                `e else
                    HCTRs <= HCTRs + 1 ;
            `e
        `e
    `a HCTRs_o  = HCTRs ;
    `a VCTRs_o  = VCTRs ;
    `a FCTRs_o  = FCTRs ;

    `r XBLK ;
    `r  XSYNC ;
    `w VSYNC_L_a ;
    `w VSYNC_L_fast_a ;
    `a VSYNC_L_a = 
        ( 
              VCTRs >=  (C_V_ACT_LINE_N + C_V_SYNC_OFS_N + 3 -1)
            && VCTRs <  (C_V_ACT_LINE_N + C_V_SYNC_OFS_N + 6 -1)
        )
    ;
    `a VSYNC_L_fast_a = 
        ( 
              VCTRs >=  (C_V_ACT_LINE_N + C_V_SYNC_OFS_N + 2 -1)
            && VCTRs <  (C_V_ACT_LINE_N + C_V_SYNC_OFS_N + 5 -1)
        )
    ;
    `w HSYNC_L_a ;
    `w HSYNC_LONG_H_a ;
    `w HSYNC_H_a ;
    `a HSYNC_L_a = HCTRs==(C_H_PX_N -C_H_BACK_PORCH_N -C_PX_DLY -1) ;
//    `a HSYNC_LONG_H_a = HCTRs==(C_H_PX_N/2 -C_H_BACK_PORCH_N -C_PX_DLY -1) ;
    `a HSYNC_LONG_H_a = HCTRs==(C_H_PX_N-2*C_H_BACK_PORCH_N -C_PX_DLY -1) ;
    `a HSYNC_H_a = 
        (   HCTRs == 
            (
                  C_H_PX_N 
                - C_H_BACK_PORCH_N 
                + C_H_SYNC_N
                - C_PX_DLY 
                - 1
            )
        )
    ;
    `ack
        `xar
        `b
            XBLK <= 1'b0 ;
            XSYNC <= 1'b1 ;
        `e else `cke
        `b
            if(
                Hcy
                & ~ 
                (      VCTRs >= (C_V_ACT_LINE_N-1)
                    && VCTRs <  (C_V_LINE_N -1)
                )
            )
                XBLK <= 1'b1 ;
            else if(HCTRs==(C_H_ACT_PX_N -1))
                XBLK <= 1'b0 ;

            if( HSYNC_L_a )
                XSYNC <= 1'b0 ;
            else if(HSYNC_LONG_H_a)
                XSYNC <= 1'b1 ;
            else if( ~VSYNC_L_fast_a )
                if( HSYNC_H_a )
                    XSYNC <= 1'b1 ;
        `e
    `a XBLK_o = XBLK ;

    `w V_SYNC_a ;
    `a V_SYNC_a = 
          (     VCTRs >= (C_V_ACT_LINE_N + C_V_SYNC_OFS_N + 0 -1)
              && VCTRs < (C_V_ACT_LINE_N + C_V_SYNC_OFS_N + 9 -1)
          ) 
    ;
    `r  COLOR_BAR_NOW ;
    `ack
        `xar
            COLOR_BAR_NOW <= 1'b0 ;
        else `cke
        if(
                HCTRs==
                (
                      C_H_PX_N
                    - C_H_BACK_PORCH_N
                    + C_H_FRONT_COLOR_BAR_N
                    + C_H_COLOR_BAR_N
                    - C_CBURST_DLY_N
                    - 1
                )
            )
            COLOR_BAR_NOW <= 1'b0 ;
        else if( V_SYNC_a )
        `b
                COLOR_BAR_NOW <= 1'b0 ;
        `e else 
            if( 
                HCTRs==
                (
                      C_H_PX_N
                    - C_H_BACK_PORCH_N
                    + C_H_FRONT_COLOR_BAR_N
                    - C_CBURST_DLY_N
                    - 1
                )
            )
                COLOR_BAR_NOW <= 1'b1 ;
    `a XSYNC_o = XSYNC ;
    `a COLOR_BAR_NOW_o = COLOR_BAR_NOW ;


    //24clock -> 7fsc
    `r[2:0]CCTRs ;
    `r[1:0]CPHs ;
    `w Ccy ;
    `a Ccy = CCTRs == 6 ;
    `ack
        `xar
            {CPHs,CCTRs} <= 1 ;
        else `cke
        `b
            if( RST_i )
                {CPHs,CCTRs} <= 1 ;
            else if( ~C_XCBURST_SHUF & HSYNC_LONG_H_a & VSYNC_L_fast_a)
                CPHs <= FCTRs[1:0]  ;
            else
            `b
                if( Ccy )
                    CCTRs <= 1  ;
                else
                    CCTRs <= CCTRs + 1 ;
                case( {CPHs,CCTRs} )
                    5'b00_001 : CPHs <= 2'b01 ;
                    5'b01_010 : CPHs <= 2'b11 ;
                    5'b11_011 : CPHs <= 2'b10 ;
                    5'b10_100 : CPHs <= 2'b00 ;
                    5'b00_101 : CPHs <= 2'b01 ;
                    5'b01_110 : CPHs <= 2'b10 ;
                    5'b10_001 : CPHs <= 2'b00 ;
                    5'b00_010 : CPHs <= 2'b01 ;
                    5'b01_011 : CPHs <= 2'b11 ;
                    5'b11_100 : CPHs <= 2'b10 ;
                    5'b10_101 : CPHs <= 2'b00 ;
                    5'b00_110 : CPHs <= 2'b11 ;
                    5'b11_001 : CPHs <= 2'b10 ;
                    5'b10_010 : CPHs <= 2'b00 ;
                    5'b00_011 : CPHs <= 2'b01 ;
                    5'b01_100 : CPHs <= 2'b11 ;
                    5'b11_101 : CPHs <= 2'b10 ;
                    5'b10_110 : CPHs <= 2'b01 ;
                    5'b01_001 : CPHs <= 2'b11 ;
                    5'b11_010 : CPHs <= 2'b10 ;
                    5'b10_011 : CPHs <= 2'b00 ;
                    5'b00_100 : CPHs <= 2'b01 ;
                    5'b01_101 : CPHs <= 2'b11 ;
                    5'b11_110 : CPHs <= 2'b00 ;
                    default : CPHs <= 2'b00 ;
                endcase
            `e
        `e
    `a CPHs_o = CPHs ;
    `a CCTRs_o = CCTRs ;
    `a sin_s_o = {CPHs[1],{3{CPHs[0]}}^CCTRs} ;
    `a cos_s_o = {CPHs[0],{3{CPHs[1]}}^CCTRs} ;
endmodule
//VIDEO_SQU_TG


`timescale 1ns/1ns
module TB_VIDEO_SQU_TG
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

    `r      RST_i               ;
    `w[9:0] HCTRs_o             ;
    `w[8:0] VCTRs_o             ;
    `w[7:0] FCTRs_o              ;
    `w      XBLK_o              ;
    `w      COLOR_BAR_NOW_o     ;
    `w      XSYNC_o             ;
    `w[4:0] COLOR_CTRs_o        ;
    `w[1:0]  CPHs_o             ;
    `w[2:0]  CCTRs_o            ;
    `w[3:0]  sin_s_o            ;//1 start
    `w[3:0]  cos_s_o            ;//6 start
    VIDEO_SQU_TG
        VIDEO_SQU_TG
        (
              .CK_i             ( CK_i           )//12.27272MHz
            , .XARST_i          ( XARST_i        )
            , .CK_EE_i          ( CK_EE_i        )//12.27272MHz
            , .RST_i            ( RST_i          )
            , .HCTRs_o          ( HCTRs_o        )
            , .VCTRs_o          ( VCTRs_o        )
            , .FCTRs_o          ( FCTRs_o        )
            , .XBLK_o           ( XBLK_o         )
            , .COLOR_BAR_NOW_o  ( COLOR_BAR_NOW_o)
            , .XSYNC_o          ( XSYNC_o        )
            , .CPHs_o           ( CPHs_o        )
            , .CCTRs_o          ( CCTRs_o       )
            , .sin_s_o          ( sin_s_o       )
            , .cos_s_o          ( cos_s_o       )
        )
    ;

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

