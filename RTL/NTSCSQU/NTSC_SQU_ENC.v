//NTSC_SQU.v
// NTSC_SQU()
//
//
// non interace ,59.94FPS 263line system
//
//K38u :1st
`ifndef NTSC_SQU_ENC
    `include "../MISC/define.vh"
    `default_nettype none
module NTSC_SQU_ENC
#(
    `p C_XCBURST_SHUF     = 1'b0 
)(
     `in`tri1       CK_i           //n x 12.27272MHz
    ,`in`tri1       XARST_i
    ,`in`tri1       PX_CK_EE_i      //12.272727MHz
    ,`in`tri0[2:0]  CBURST_CPHs_i          //str
    ,`in`tri0       CBURST_NOW_i
    ,`in`tri0       XSYNC_i
    ,`in`tri0       XBLK_i
    ,`in`tri0[2:0]  CPHs_i          //str
    ,`in`tri0[5:0]  YYs_i           //str
    ,`out`w[5:0]    VIDEOs_o
);
    `r[2:0] CPHs_NOW ;
    `r `s [3:0] COLORs ; //2s
    `ack
        `xar
        `b
            CPHs_NOW <= 0 ;
            COLORs <= 0 ;
        `eelif( PX_CK_EE_i )
        `b
            if( ~ XBLK_i )
                CPHs_NOW <= CBURST_CPHs_i + 4 ;
            else 
                case( CPHs_i )
                    0 : CPHs_NOW <= CBURST_CPHs_i + 0 ;
                    1 : CPHs_NOW <= CBURST_CPHs_i + 1 ;
                    2 : CPHs_NOW <= CBURST_CPHs_i + 2 ;
                    3 : CPHs_NOW <= CBURST_CPHs_i + 3 ;
                    4 : CPHs_NOW <= CBURST_CPHs_i + 4 ;
                    5 : CPHs_NOW <= CBURST_CPHs_i + 5 ;
                    6 : CPHs_NOW <= CBURST_CPHs_i + 6 ;
                    7 : CPHs_NOW <= CBURST_CPHs_i + 7 ;
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
    // VIDEO out level
    // 10IRE : 3
    // sync :0
    // pede :`d12
    // Wh100:`d12+`d30=42 ;
    `lp C_PEDE = 5'd12  ;
    `r[5:0] VIDEOs ; //6
    `r[2:0]XBLK_Ds ;
    `w[7:0] VIDEOs_a ;//2s
    `a VIDEOs_a = C_PEDE + YYs_i + $signed( COLORs ) ;
    `ack
        `xar
        `b
            XBLK_Ds <= ~0 ;
            VIDEOs <= C_PEDE ;
       `eelif( PX_CK_EE_i )
        `b
            `sfl( XBLK_Ds,XBLK_i) ;
            if( ~ XSYNC_i )
                VIDEOs <= 0 ;
            else if( CBURST_NOW_i )
                VIDEOs <= C_PEDE + `Ds( {{4{COLORs[3]}},COLORs[3:1]});
            else if( ~ XBLK_Ds[2] )
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
    `default_nettype wire
    `define NTSC_SQU_ENC
`endif


`ifndef FPGA_COMPILE
    `ifndef TB_NTSC_SQU_ENC
        `timescale 1ns/1ns
        `include "../MISC/define.vh"
        `default_nettype none
module TB_NTSC_SQU_ENC
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
        `define TB_NTSC_SQU_ENC
        `default_nettype wire
    `endif
`endif
