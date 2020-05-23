//VIDEO_SQU.v
// VIDEO_SQU()
//
//
// non interace ,59.94FPS 263line system
//
//K38u :1st
`default_nettype none
`include "../MISC/define.vh"
`ifndef FPGA_COMPILE
    `include "./VIDEO_LED_JDG.v"
    `include "./VIDEO_SQU_TG.v"
`endif
module VIDEO_SQU
#(
    `p C_XCBURST_SHUF     = 1'b0 
)(
      `in `tri1         CK_i           //12.27272MHz
    , `in `tri1         XARST_i
    , `in `tri1         CK_EE_i        //12.27272MHz
    , `in `tri0         RST_i
    , `in `tri0[17:0]   LEDs_ON_i
    , `out `w[5:0]      VIDEOs_o
    , `out `w           HVcy_o
//    , `out `w         VIDEO_o
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



    `func[4:0] f_clip30 ;
        `in[7:0] XXs ;
        `b
            f_clip30 = ((0+XXs) >= 120)? 30 : (0+XXs) / 4 ;
        `e
    `efunc
    `func[4:0]f_addXY ;
        `in[6:0] XXs ;
        `in[6:0] YYs ;
        `int tmp ;
        `b
            tmp = 32'd0 + XXs + YYs ;
            tmp = (3 * tmp)  / 4 ;
            f_addXY = f_clip30( tmp[7:0]  ) ;
        `e
    `efunc

    `w[6:0]  XX =  HCTRs[7:1] ;
    `w[6:0] xXX = ~HCTRs[7:1] ;
    `w[6:0]  YY = ~VCTRs[6:0] ;
    `w[6:0] xYY =  VCTRs[6:0] ;
    `r[2:0] DPHs_AD ;
    `r[4:0] DYs_ADs[0:7] ;
    `r[2:0] DPHs    ;
    `r[4:0] DYs     ;
    `ack
        `xar
        `b
        `e else `cke
        `b
            DYs_ADs[0] <= f_clip30( XX       ) ;
            DYs_ADs[1] <= f_addXY(  XX ,  YY ) ;
            DYs_ADs[2] <= f_clip30(       YY ) ;
            DYs_ADs[3] <= f_addXY( xXX ,  YY ) ;
            DYs_ADs[4] <= f_clip30(      xXX ) ;
            DYs_ADs[5] <= f_addXY( xXX , xYY ) ;
            DYs_ADs[6] <= f_clip30(      xYY ) ;
            DYs_ADs[7] <= f_addXY(  XX , xYY ) ;
            case({VCTRs[7],~HCTRs[8]})
                2'b00:
                    if(YY < {1'b0,XX[6:1]}) 
                                        DPHs_AD <= 0 ;
                    `elif({1'b0,YY[6:1]} < XX)
                                        DPHs_AD <= 1 ;
                    else 
                                        DPHs_AD <= 2 ;
                2'b01:
                    if({1'b0,YY[6:1]} > xXX)
                                        DPHs_AD <= 2 ;
                    `elif(YY > {1'b0,xXX[6:1]})
                                        DPHs_AD <= 3 ;
                    else
                                        DPHs_AD <= 4 ;
                2'b11:
                    if(xYY < {1'b0,xXX[6:1]})
                                        DPHs_AD <= 4 ;
                    `elif({1'b0,xYY[6:1]} < xXX)
                                        DPHs_AD <= 5 ;
                    else
                                        DPHs_AD <= 6 ;
                2'b10:
                    if({1'b0,xYY[6:1]} > XX)
                                        DPHs_AD <= 6 ;
                    `elif(xYY > {1'b0,XX[6:1]})
                                        DPHs_AD <= 7 ;
                    else
                                        DPHs_AD <= 0 ;
            `ecase
            DPHs <= DPHs_AD ;
            DYs <= DYs_ADs[DPHs_AD] ;
        `e


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
                case( DPHs) //LED_COLOR_PHs )
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
    `a VIDEOs_a = C_PEDE + DYs+ $signed( COLORs ) ;
/*    `a VIDEOs_a = 
        ( LED_HIT)
        ?
            ( 10 + C_PEDE)
            + $signed
            ( 
                ( LED_COLOR_ON )
                ?   
                    $signed( COLORs )
                :   
                    0
            )
        :
            ( 0 + C_PEDE)
    ;
*/
//    `a VIDEOs_a = 
//        (LED_HIT)
//            ?
//                (24 + C_PEDE) + $signed( COLORs )
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
                VIDEOs <= C_PEDE + `Ds( {{4{COLORs[3]}},COLORs[3:1]});
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
    `al@(`pe CK_i or `ne XARST_i)
        if( ~XARST_i)
            LEDs_ON_i   <= ~ 0 ;
        else if(VIDEO_SQU.HVcy_o)
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

