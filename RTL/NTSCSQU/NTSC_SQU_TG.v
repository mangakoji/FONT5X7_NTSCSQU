//NTSC_SQU_TG.v
// NTSC_SQU_TG()
//
//
// non interace ,59.94FPS 263line system
//K31u :1st

`ifndef NTSC_SQU_TG
    `default_nettype none
    `include "../MISC/define.vh"
module NTSC_SQU_TG
#(
     `p C_F_CK              = 135_000_00
    , `p C_PX_DLY           = 2
    , `p C_CBURST_DLY_N     = 2
    , `p C_XCBURST_SHUF     = 1'b0 
)(
      `in `tri1      CK_i           //n x 12.27272MHz
    , `in `tri1      XARST_i
    , `in `tri0      RST_i
    , `out`w        PX_CK_EE_o        //12.27272MHz
    , `out `w[9:0]  HCTRs_o
    , `out `w[8:0]  VCTRs_o
    , `out `w[7:0]  FCTRs_o
    , `out `w       XBLK_o
    , `out `w       CBURST_NOW_o
    , `out `w       XSYNC_o
    , `out `w[2:0]  CPHs_o
    , `out `w[1:0]  CCTRs_o 
);
    // constant function on Verilog 2001
    `func `int log2 ;
        `in `int value ;
    `b  value = value - 1 ;
        for(log2=0 ; value>0 ; log2=log2+1)
            value = value>>1 ;
    `e `efunc
    `lp C_F_VCK = 12_272_272 ;
    `lp C_VCK_DIV_N = ( 2*(C_F_CK/C_F_VCK)+1)/2 ;
    `lp C_PCTR_W = log2( C_VCK_DIV_N ) ;
    `r PX_CK_EE ;
    `r[C_PCTR_W-1:0] PCTRs ;
    `w PCTR_cy = `cy(PCTRs,(C_VCK_DIV_N -1)) ;
    `ack`xar    {PX_CK_EE , PCTRs} <= 0 ;
    else
    `b                                  PX_CK_EE <= PCTR_cy ;
        if( PCTR_cy )                   PCTRs <= 0 ;
        else                            PCTRs <= PCTRs + 1 ;
    `e
    `a PX_CK_EE_o = PX_CK_EE ;

    `p C_H_PX_N                 = 780       ;
    `p C_H_ACT_PX_N             = 640       ;
    `p C_H_SYNC_N               = 58        ;//4.7us
    `p C_H_FRONT_CBURST_N    = 64        ;//19sccycle
    `p C_H_CBURST_N          = 31        ;//9cycle
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
        `eelif( PX_CK_EE )
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
        `eelif( PX_CK_EE )
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
    `r  CBURST_NOW ;
    `ack
        `xar
            CBURST_NOW <= 1'b0 ;
        `elif( PX_CK_EE )
        if(
                HCTRs==
                (
                      C_H_PX_N
                    - C_H_BACK_PORCH_N
                    + C_H_FRONT_CBURST_N
                    + C_H_CBURST_N
                    - C_CBURST_DLY_N
                    - 1
                )
            )
            CBURST_NOW <= 1'b0 ;
        else if( V_SYNC_a )
        `b
                CBURST_NOW <= 1'b0 ;
        `e else 
            if( 
                HCTRs==
                (
                      C_H_PX_N
                    - C_H_BACK_PORCH_N
                    + C_H_FRONT_CBURST_N
                    - C_CBURST_DLY_N
                    - 1
                )
            )
                CBURST_NOW <= 1'b1 ;
    `a XSYNC_o = XSYNC ;
    `a CBURST_NOW_o = CBURST_NOW ;


    //24clock -> 7fsc
    `r[1:0]CCTRs ;
    `r[2:0]CPHs ;
    `w Ccy ;
    `ack
        `xar
            {CPHs,CCTRs} <= 0 ;
        `elif( PX_CK_EE )
        `b
            if( RST_i )
                {CPHs,CCTRs} <= 0 ;
            else if( ~C_XCBURST_SHUF & HSYNC_LONG_H_a & VSYNC_L_fast_a)
                CPHs <= CPHs + 2 ;//{FCTRs[1:0],1'b0}  ;
            else
            `b
                CCTRs <= (CCTRs[1])? 0 : CCTRs+1 ;
                CPHs <= CPHs + 2 + CCTRs[1] ;
            `e
        `e
    `a CPHs_o = CPHs ;
    `a CCTRs_o = CCTRs ;
endmodule
//NTSC_SQU_TG
    `define NTSC_SQU_TG
    `default_nettype wire
`endif


`ifndef FPGA_COMPILE
    `ifndef TB_NTSC_SQU_TG
        `timescale 1ns/1ns
        `include "../MISC/define.vh"
        `default_nettype none
module TB_NTSC_SQU_TG
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
    `w      CBURST_NOW_o     ;
    `w      XSYNC_o             ;
    `w[4:0] COLOR_CTRs_o        ;
    `w[2:0]  CPHs_o             ;
    `w[1:0]  CCTRs_o            ;
    NTSC_SQU_TG
        NTSC_SQU_TG
        (
              .CK_i             ( CK_i           )//12.27272MHz
            , .XARST_i          ( XARST_i        )
            , .CK_EE_i          ( CK_EE_i        )//12.27272MHz
            , .RST_i            ( RST_i          )
            , .HCTRs_o          ( HCTRs_o        )
            , .VCTRs_o          ( VCTRs_o        )
            , .FCTRs_o          ( FCTRs_o        )
            , .XBLK_o           ( XBLK_o         )
            , .CBURST_NOW_o  ( CBURST_NOW_o)
            , .XSYNC_o          ( XSYNC_o        )
            , .CPHs_o           ( CPHs_o        )
            , .CCTRs_o          ( CCTRs_o       )
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
        `default_nettype wire
        `define TB_NTSC_SQU_TG
    `endif
`endif

