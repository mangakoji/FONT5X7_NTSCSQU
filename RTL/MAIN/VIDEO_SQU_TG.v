//VIDEO_SQU_TG.v
// VIDEO_SQU_TG()
//
//
// non interace ,59.94FPS 263line system
//K31u :1st
`include "../MISC/define.vh"
`default_nettype none
module VIDEO_SQU_TG
(
      `in tri1      CK_i           //12.27272MHz
    , `in tri1      XARST_i
    , `in tri1      CK_EE_i        //12.27272MHz
    , `in tri0      RST_i
    , `out `w[9:0]  HCTRs_o
    , `out `w[8:0]  VCTRs_o
    , `out `w       FCTR_o
    , `out `w       XBLK_o
    , `out `w       COLOR_BAR_NOW_o
    , `out `w       XSYNC_o
    , `out `w[4:0]  COLOR_CTRs_o 

);
    `p C_PX_DLY               = 2         ;
    `p C_H_PX_N                 = 780       ;
    `p C_H_ACT_PX_N             = 640       ;
    `p C_H_SYNC_N               = 58        ;//4.7us
    `p C_H_COLOR_BAR_DLY_N      = 2         ;
    `p C_H_FRONT_COLOR_BAR_N    = 64        ;//19sccycle
    `p C_H_COLOR_BAR_N          = 31        ;//9cycle
    `p C_H_BACK_PORCH_N        = 121       ;//9.4us+6ck from sync ne
//    `p C_H_FRONT_PORCH_N         = 19      ;

    `p C_V_LINE_N               = 263       ;
    `p C_V_ACT_LINE_N           = 240       ;
    `p C_V_SYNC_OFS_N           = 1         ;
    

    `r [9:0] HCTRs      ;
    `r [8:0] VCTRs      ;
    `r       FCTR       ;
    `w Hcy ;
    `a Hcy = &(HCTRs |~(C_H_PX_N-1)) ;
    `w Vcy ;
    `a Vcy = &(VCTRs |~(C_V_LINE_N-1)) ;
    `ack
        `xar
        `b
            HCTRs <= (C_H_PX_N  -2) ;
            VCTRs <= (C_V_LINE_N -1) ;
            FCTR  <= 1'b1 ;
        `e else `cke
        `b
            if( RST_i )
            `b
                HCTRs <= 0 ;
                VCTRs <= 0 ;
                FCTR  <= 1'b0 ;
            `e else
            `b
                if( Hcy )
                `b
                    HCTRs <= 0 ;
                    if( Vcy )
                    `b
                        VCTRs <= 0 ;
                        FCTR <= FCTR + 1 ;
                    `e
                    else
                        VCTRs <= VCTRs + 1 ;
                `e else
                    HCTRs <= HCTRs + 1 ;
            `e
        `e
    `a HCTRs_o  = HCTRs ;
    `a VCTRs_o  = VCTRs ;
    `a FCTR_o  = FCTR ;

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
    `a HSYNC_LONG_H_a = HCTRs==(C_H_PX_N/2 -C_H_BACK_PORCH_N -C_PX_DLY -1) ;
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
                    - C_H_COLOR_BAR_DLY_N
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
                    - C_H_COLOR_BAR_DLY_N
                    - 1
                )
            )
                COLOR_BAR_NOW <= 1'b1 ;
    `a XSYNC_o = XSYNC ;
    `a COLOR_BAR_NOW_o = COLOR_BAR_NOW ;
    //24clock -> 7fsc
    `r[4:0]COLOR_CTRs ;
    `w COLOR_CTR_cy ;
    `a COLOR_CTR_cy = &(COLOR_CTRs[2:0] | (~(6-1))) ;
    `ack
        `xar
        `b
            COLOR_CTRs <= 1'b1 ;
        `e else `cke
        `b
            if( RST_i )
                COLOR_CTRs <= 1 ;
            else
                if( COLOR_CTR_cy)
                    COLOR_CTRs <= {COLOR_CTRs[4:3]+1, 3'd1} ;
                else
                    COLOR_CTRs <= COLOR_CTRs + 1 ;
//            case(COLOR_CTRs)
//                4'b00_000 : COLOR_CTRs <= 
/*            case( COLOR_CTRs )
                 0 : {CQs,CIs} <= {,} ;
                 1 : {CQs,CIs} <= {,} ;
                 2 : {CQs,CIs} <= {,} ;
                3 :  {CQs,CIs} <= {,} ;
                4 :  {CQs,CIs} <= {,} ;
                5 :  {CQs,CIs} <= {,} ;
                6 :  {CQs,CIs} <= {,} ;
                7 :  {CQs,CIs} <= {,} ;
                8 :  {CQs,CIs} <= {,} ;
                9 :  {CQs,CIs} <= {,} ;
               10 :  {CQs,CIs} <= {,} ;
               11 :  {CQs,CIs} <= {,} ;
               12 :  {CQs,CIs} <= {,} ;
               13 :  {CQs,CIs} <= {,} ;
               14 :  {CQs,CIs} <= {,} ;
               15 :  {CQs,CIs} <= {,} ;
               16 :  {CQs,CIs} <= {,} ;
               17 :  {CQs,CIs} <= {,} ;
               18 :  {CQs,CIs} <= {,} ;
               19 :  {CQs,CIs} <= {,} ;
               20 :  {CQs,CIs} <= {,} ;
               21 :  {CQs,CIs} <= {,} ;
               22 :  {CQs,CIs} <= {,} ;
               23 :  {CQs,CIs} <= {,} ;
                default :
            endcase
*/        `e
    `a COLOR_CTRs_o = COLOR_CTRs ;
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
    `w      FCTR_o              ;
    `w      XBLK_o              ;
    `w      COLOR_BAR_NOW_o     ;
    `w      XSYNC_o             ;
    `w[4:0] COLOR_CTRs_o        ;
    VIDEO_SQU_TG
        VIDEO_SQU_TG
        (
              .CK_i             ( CK_i           )//12.27272MHz
            , .XARST_i          ( XARST_i        )
            , .CK_EE_i          ( CK_EE_i        )//12.27272MHz
            , .RST_i            ( RST_i          )
            , .HCTRs_o          ( HCTRs_o        )
            , .VCTRs_o          ( VCTRs_o        )
            , .FCTR_o           ( FCTR_o         )
            , .XBLK_o           ( XBLK_o         )
            , .COLOR_BAR_NOW_o  ( COLOR_BAR_NOW_o)
            , .XSYNC_o          ( XSYNC_o        )
            , .COLOR_CTRs_o     ( COLOR_CTRs_o   )
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

