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
module VIDEO_SQU
#(
    `p C_XCBURST_SHUF     = 1'b0 
)(
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
    `w      XBLK_AD     ;
    `w      COLOR_BAR_NOW   ;
    `w      XSYNC       ;
//    `w[1:0]  CPHs             ;
//    `w[2:0]  CCTRs            ;
    `w[3:0]  sin_s            ;//1 start
    `w[3:0]  cos_s            ;//6 start
    VIDEO_SQU_TG
        #(
              .C_PX_DLY         ( 3              )
            , .C_CBURST_DLY_N   ( 2              )
            , .C_XCBURST_SHUF   ( C_XCBURST_SHUF )
        )VIDEO_SQU_TG
        (
              .CK_i             ( CK_i          )//12.27272MHz
            , .XARST_i          ( XARST_i       )
            , .CK_EE_i          ( CK_EE_i       )//12.27272MHz
            , .RST_i            ( RST_i         )
            , .HCTRs_o          ( HCTRs         )
            , .VCTRs_o          ( VCTRs         )
            , .FCTRs_o          ( FCTRs         )
            , .XBLK_o           ( XBLK_AD       )
            , .COLOR_BAR_NOW_o  ( COLOR_BAR_NOW )
            , .XSYNC_o          ( XSYNC         )
//            , .CPHs_o           ( CPHs_o        )
//            , .CCTRs_o          ( CCTRs_o       )
            , .sin_s_o          ( sin_s         )
            , .cos_s_o          ( cos_s         )
        )
    ;


    `r[7:0] MV_RAMPs ;
    `ack
        `xar
            MV_RAMPs <= 0 ;
        else `cke
            MV_RAMPs <= HCTRs[9:1] + VCTRs + FCTRs ;

    `r `s [4:0] COLORs ; //2s
    `ack
        `xar
            COLORs <= 0 ;
        else `cke
            if( ~ XBLK_AD )
                COLORs <= $signed( -cos_s ) ;
            else 
                case( HCTRs[8:6] )
                    0 : COLORs <=   `Ds( cos_s )                 ;
                    1 : COLORs <=   `Ds( cos_s ) - `Ds( sin_s )  ;
                    2 : COLORs <=                - `Ds( sin_s )  ;
                    3 : COLORs <= - `Ds( cos_s ) - `Ds( sin_s )  ;
                    4 : COLORs <= - `Ds( cos_s )                 ;
                    5 : COLORs <= - `Ds( cos_s ) + `Ds( sin_s )  ;
                    6 : COLORs <=                + `Ds( sin_s )  ;
                    7 : COLORs <=   `Ds( cos_s ) + `Ds( sin_s )  ;
                endcase
    `p C_PEDE = 10'd205 ;
    `r[9:0] VIDEOs ;
    `r      XBLK ;
    `r      XBLK_AD2 ;
    `w[11:0] VIDEOs_a ;//2s
    `a VIDEOs_a = {3'b000,MV_RAMPs,1'b0} 
                    + C_PEDE 
                    + ({{2{COLORs[4]}},COLORs,{5{COLORs[4]}}}) 
    ;
    `ack
        `xar
        `b
            XBLK <= 1'b1 ;
            VIDEOs <= C_PEDE ;
       `e else `cke
        `b
            XBLK_AD2 <= XBLK_AD ;
            XBLK <= XBLK_AD2 ;
            if( ~ XSYNC )
                VIDEOs <= 0 ;
            else if( COLOR_BAR_NOW )
                VIDEOs <= C_PEDE + `Ds( {COLORs, {4{~COLORs[4]}}} );
            else if( ~ XBLK )
                VIDEOs <= C_PEDE ;
            else
                VIDEOs <= 
                     (VIDEOs_a[11]) ? 0 
                    : (VIDEOs_a[10]) ? ~0
                    :                VIDEOs_a 
                ;
        `e
    `a VIDEOs_o = VIDEOs ;
endmodule
//VIDEO_SQU_TG


`timescale 1ns/1ns
module TB_VIDEO_SQU
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
    wire[9:0]   VIDEOs_o ;
    VIDEO_SQU
        VIDEO_SQU
        (
              .CK_i     ( CK_i      )      //8*12.27272MHz
            , .XARST_i  ( XARST_i   )
            , .CK_EE_i  ( CK_EE_i   )        //12.27272MHz
            , .RST_i    ( RST_i     )
            , .VIDEOs_o ( VIDEOs_o    )
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

