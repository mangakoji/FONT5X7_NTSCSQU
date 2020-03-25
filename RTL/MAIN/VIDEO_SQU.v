//VIDEO_SQU.v
// VIDEO_SQU()
//
//
// non interace ,59.94FPS 263line system
//
//K38u :1st
`include "../MISC/define.vh"
`include "./VIDEO_LED_JDG.v"
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
    , `in tri0[17:0] LEDs_ON_i
    , `out `w[5:0] VIDEOs_o
    , `out `w       HVcy_o
//    , `out `w       VIDEO_o
);

    `w [9:0] HCTRs      ;
    `w [8:0] VCTRs      ;
    `w [7:0] FCTRs      ;
    `w      XBLK_AD     ;
    `w      CBURST_NOW  ;
    `w      XSYNC       ;
//    `w[1:0]  CCTRs            ;
    `w[2:0]  CPHs             ;
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
            , .CBURST_NOW_o     ( CBURST_NOW )
            , .XSYNC_o          ( XSYNC         )
            , .CPHs_o           ( CPHs          )
        )
    ;
    `a HVcy_o = (VCTRs==(240-1)) & (HCTRs==(640-1)) & CK_EE_i ;

    `r[3:0] MV_RAMPs ;
    `w[7:0] MV_RAMPs_a ;
    `a MV_RAMPs_a = HCTRs[9:1] + VCTRs + FCTRs ;
    `ack
        `xar
            MV_RAMPs <= 0 ;
        else `cke
            MV_RAMPs <= MV_RAMPs_a[7:5] ;

    `w          LED_HIT         ;
    `w          LED_COLOR_ON    ;
    `w [2:0]    LED_COLOR_PHs   ;
    VIDEO_LED_JDG
        VIDEO_LED_JDG
        (
              .CK_i             ( CK_i          )
            , .XARST_i          ( XARST_i       )
            , .CK_EE_i          ( CK_EE_i       )
            , .LEDs_ON_i        ( LEDs_ON_i     )
            , .HCTRs_i          ( HCTRs[9:1]    )//0-319-787/2
            , .VCTRs_i          ( VCTRs         )//0-239-242
            , .LED_HIT_o        ( LED_HIT       ) //no_use
            , .LED_COLOR_ON_o   ( LED_COLOR_ON  )
            , .LED_COLOR_PHs_o  ( LED_COLOR_PHs )
        ) 
    ;
//    `a LED_COLOR_PHs = 3 ;
    `r[2:0] CPHs_NOW ;
    `r `s [3:0] COLORs ; //2s
    `ack
        `xar
        `b
            CPHs_NOW <= 0 ;
            COLORs <= 0 ;
        `e else `cke
        `b
            if( ~ XBLK_AD )
                CPHs_NOW <= CPHs + 4 ;
            else 
                case( LED_COLOR_PHs )
                    0 : CPHs_NOW <= CPHs + 0 ;
                    1 : CPHs_NOW <= CPHs + 1 ;
                    2 : CPHs_NOW <= CPHs + 2 ;
                    3 : CPHs_NOW <= CPHs + 3 ;
                    4 : CPHs_NOW <= CPHs + 4 ;
                    5 : CPHs_NOW <= CPHs + 5 ;
                    6 : CPHs_NOW <= CPHs + 6 ;
                    7 : CPHs_NOW <= CPHs + 7 ;
                endcase
            case( CPHs_NOW )
                0 : COLORs <=  3 ;
                1 : COLORs <=  6 ;
                2 : COLORs <=  6 ;
                3 : COLORs <=  3 ;
                4 : COLORs <= -3 ;
                5 : COLORs <= -6 ;
                6 : COLORs <= -6 ;
                7 : COLORs <= -3 ;
            endcase
        `e
    `p C_PEDE = 5'd12  ;
    `r[5:0] VIDEOs ; //6
    `r      XBLK ;
    `r      XBLK_AD2 ;
    `w[7:0] VIDEOs_a ;//2s
    `a VIDEOs_a = 
        (
            ( LED_HIT)
            ?
                (30 + C_PEDE)
            :
                ( 0 + C_PEDE)
        )+ $signed
        ( 
            ( LED_COLOR_ON )
            ?
                $signed( COLORs )
            :
                0
        )
    ;
//    `a VIDEOs_a = 
//        (LED_HIT)
//            ?
//                (30 + C_PEDE) + $signed( COLORs )
//            :
//                ( 0 + C_PEDE)
//    ;
//
//    `a VIDEOs_a = 30 + C_PEDE ;
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
            else if( CBURST_NOW )
                VIDEOs <= C_PEDE + `Ds( {{4{COLORs[3]}},COLORs[3:0]});
            else if( ~ XBLK )
                VIDEOs <= C_PEDE ;
            else
                VIDEOs <= 
                     (VIDEOs_a[7]) ? 0 
                    : (VIDEOs_a[6]) ? ~0
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
    wire[4:0]   VIDEOs_o ;
    `r[17:0] LEDs_ON_i ;
    VIDEO_SQU
        VIDEO_SQU
        (
              .CK_i     ( CK_i      )      //8*12.27272MHz
            , .XARST_i  ( XARST_i   )
            , .CK_EE_i  ( CK_EE_i   )        //12.27272MHz
            , .RST_i    ( RST_i     )
            , .LEDs_ON_i( LEDs_ON_i )
            , .VIDEOs_o ( VIDEOs_o    )
        )
    ;

    `int ii ;
    initial
    `b
        RST_i <= 1'b1 ;
        LEDs_ON_i   <= ~ 0 ;
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

