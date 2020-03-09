//VIDEO_SQU.v
// VIDEO_SQU()
//
//
// non interace ,59.94FPS 263line system
//
//K38u :1st
`include "../MISC/define.vh"
`include "./VIDEO_SQU_TG.v"
`default_nettype none
module VIDEO_SQU_TG
(
      `in tri1      CK_i           //12.27272MHz
    , `in tri1      XARST_i
    , `in tri1      CK_EE_i        //12.27272MHz
    , `in tri0      RST_i
    , `out `w[9:0] VIDEOs_o
//    , `out `w       VIDEO_o
);

    `w [9:0] HCTRs      ;
    `w [8:0] VCTRs      ;
    `w [7:0] FCTRs      ;
    `w      XBLK_AD l
    `w      COLOR_BAR_NOW   ;
    `w      XSYNC       ;
    `w[5:0]COLOR_CTRs ;
    VIDEO_SQU_TG
        VIDEO_SQU_TG
        (
              .CK_i             ( CK_i          )//12.27272MHz
            , .XARST_i          ( XARST_i       )
            , .CK_EE_i          ( CK_EE_i       )//12.27272MHz
            , .RST_i            ( RST_i         )
            , .HCTRs_o          ( HCTRs         )
            , .VCTRs_o          ( VCTRs         )
            , .FCTR_o           ( FCTR          )
            , .XBLK_o           ( XBLK_AD       )
            , .COLOR_BAR_NOW_o  ( COLOR_BAR_NOW )
            , .XSYNC_o          ( XSYNC         )
            , .COLOR_CTRs_o     ( COLOR_CTRs    )
        )
    ;

    `r[7:0] MV_RAMPs ;
    `ack
        `xar
        else `cke
            MV_RAMPs <= HCTRs[9:1] + VCTRs + FCTRs ;
    `p C_PEDE = 205 ;
    `r[9:0] VIDEOs ;
    `r      XBLK ;
    `ack
        `xar
        `b
            XBLK <= 1'b1 ;
            VIDEOs <= C_PEDE ;
       `e else `cke
        `b
            XBLK <= XBLK_AD ;
            if( ~ XSYNC )
                VIDEOs <= 0 ;
            else if( COL_BAR_NOW )
                VIDEOs <= C_PEDE ;
            else if( ~ XBLK )
                VIDEOs <= C_PEDE ;
            else
                VIDEOs <= {MV_RAMPs,1'b0} + C_PEDE ;
        `e
    `a VIDEOs_o = VIDEOs ;
/*
    `r      VIDEO ;
    `r[11:0] VIDEO_DSs ;
    `ack
        `xar
            VIDEO_DSs <= 0 ;
        else `cke
            VIDEOs_DSs <= {1'b0 , VIDEO_DSs[9:0]} + {1'b0,VIDEOs}; 
    `a VIDEO_o = VIDEO_DSs[11] ;
*/
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

