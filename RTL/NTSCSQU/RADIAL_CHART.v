//RADIAL_CHART.v
// RADIAL_CHART()
//
//
//M9Nf :split part of Radial test chart from VIDEO_SQU.v


`ifndef RADIAL_CHART
    `include "../MISC/define.vh"
    `default_nettype none
module RADIAL_CHART
(
     `in`tri1       CK_i           //n x 12.27272MHz
    ,`in`tri1       XARST_i
    ,`in`tri1       PX_CK_EE_i        //12.27272MHz
    ,`in`tri0[ 9:0] HCTRs_i
    ,`in`tri0[ 8:0] VCTRs_i
    ,`out`w[ 5:0]   YYs_o
    ,`out`w[ 2:0]   CPHs_o
);
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

    `w[6:0]  XX =  HCTRs_i[7:1] ;
    `w[6:0] xXX = ~HCTRs_i[7:1] ;
    `w[6:0]  YY = ~VCTRs_i[6:0] ;
    `w[6:0] xYY =  VCTRs_i[6:0] ;
    `r[2:0] CPHs_AD ;
    `r[4:0] YYs_ADs[0:7] ;
    `r[2:0] CPHs    ;
    `r[4:0] YYs     ;
    `ack`xar
    `b
            CPHs_AD         <= 0 ;
            YYs_ADs [0]     <= 0 ;
            YYs_ADs [1]     <= 0 ;
            YYs_ADs [2]     <= 0 ;
            YYs_ADs [3]     <= 0 ;
            YYs_ADs [4]     <= 0 ;
            YYs_ADs [5]     <= 0 ;
            YYs_ADs [6]     <= 0 ;
            YYs_ADs [7]     <= 0 ;
            CPHs            <= 0 ;
            YYs             <= 0 ;
    
    `eelif( PX_CK_EE_i )
    `b
        YYs_ADs[0] <= f_clip30( XX       ) ;
        YYs_ADs[1] <= f_addXY(  XX ,  YY ) ;
        YYs_ADs[2] <= f_clip30(       YY ) ;
        YYs_ADs[3] <= f_addXY( xXX ,  YY ) ;
        YYs_ADs[4] <= f_clip30(      xXX ) ;
        YYs_ADs[5] <= f_addXY( xXX , xYY ) ;
        YYs_ADs[6] <= f_clip30(      xYY ) ;
        YYs_ADs[7] <= f_addXY(  XX , xYY ) ;
        case({VCTRs_i[7],~HCTRs_i[8]})
            2'b00:
                if(YY < {1'b0,XX[6:1]}) 
                                    CPHs_AD <= 0 ;
                `elif({1'b0,YY[6:1]} < XX)
                                    CPHs_AD <= 1 ;
                else 
                                    CPHs_AD <= 2 ;
            2'b01:
                if({1'b0,YY[6:1]} > xXX)
                                    CPHs_AD <= 2 ;
                `elif(YY > {1'b0,xXX[6:1]})
                                    CPHs_AD <= 3 ;
                else
                                    CPHs_AD <= 4 ;
            2'b11:
                if(xYY < {1'b0,xXX[6:1]})
                                    CPHs_AD <= 4 ;
                `elif({1'b0,xYY[6:1]} < xXX)
                                    CPHs_AD <= 5 ;
                else
                                    CPHs_AD <= 6 ;
            2'b10:
                if({1'b0,xYY[6:1]} > XX)
                                    CPHs_AD <= 6 ;
                `elif(xYY > {1'b0,XX[6:1]})
                                    CPHs_AD <= 7 ;
                else
                                    CPHs_AD <= 0 ;
        `ecase
        CPHs <= CPHs_AD ;
        YYs <= YYs_ADs[CPHs_AD] ;
    `e
    `a CPHs_o = CPHs ;
    `a YYs_o = YYs ;

//    `r[3:0] MV_RAMPs ;
//    `w[7:0] MV_RAMPs_a ;
//    `a MV_RAMPs_a = HCTRs_i[9:1] + VCTRs_i + FCTRs ;
//    `ack
//        `xar
//            MV_RAMPs <= 0 ;
//        else `cke
//            MV_RAMPs <= MV_RAMPs_a[7:5] ;
endmodule
    `default_nettype wire
    `define RADIAL_CHART
`endif


`ifndef FPGA_COMPILE
    `ifndef RADIAL_CHART
        `include "../MISC/define.v"
        `default_nettype none
        `timescale 1ns/1ns
module TB_RADIAL_CHART
#(
    parameter C_C=10.0
)(
) ;
    reg         PX_CK_EE_i ;
    reg CK_i ;
    initial `b
        PX_CK_EE_i <= 1'b1 ;
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
            , .PX_CK_EE_i  ( PX_CK_EE_i   )        //12.27272MHz
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
        `define TB_RADIAL_CHART
    `endif
`endif
