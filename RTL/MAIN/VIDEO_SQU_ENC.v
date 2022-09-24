//VIDEO_SQU.v
// VIDEO_SQU()
//
//
// non interace ,59.94FPS 263line system
//
//K38u :1st
`ifndef VIDEO_SQU_ENC
    `include "../MISC/define.vh"
    `default_nettype none
module VIDEO_SQU_ENC
#(
    `p C_XCBURST_SHUF     = 1'b0 
)(
      `in `tri1     CK_i           //12.27272MHz
    , `in `tri1     XARST_i
    , `in `tri1     CK_EE_i        //12.27272MHz
    ,`in`tri0[2:0]  CPHs_i          //str
    ,`in`tri0[5:0]  YYs_i           //str
    ,`out`w         HVcy_o
    , `out `w[5:0]  VIDEOs_o
);

    `w [9:0] HCTRs      ;
    `w [8:0] VCTRs      ;
    `w [7:0] FCTRs      ;
    `w      XBLK_AD     ;
    `w      CBURST_NOW  ;
    `w      XSYNC       ;
//    `w[1:0]  CCTRs            ;
    `w[2:0]  BURST_CPHs         ;
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
//            , .RST_i            ( RST_i         )
            , .HCTRs_o          ( HCTRs         )
            , .VCTRs_o          ( VCTRs         )
            , .FCTRs_o          ( FCTRs         )
            , .XBLK_o           ( XBLK_AD       )
            , .CBURST_NOW_o     ( CBURST_NOW    )
            , .XSYNC_o          ( XSYNC         )
            , .CPHs_o           ( BURST_CPHs    )
        )
    ;
    `a HVcy_o = (VCTRs==(240-1)) & (HCTRs==(640-1)) & CK_EE_i ;



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
                CPHs_NOW <= BURST_CPHs + 4 ;
            else 
                case( CPHs_i )
                    0 : CPHs_NOW <= BURST_CPHs + 0 ;
                    1 : CPHs_NOW <= BURST_CPHs + 1 ;
                    2 : CPHs_NOW <= BURST_CPHs + 2 ;
                    3 : CPHs_NOW <= BURST_CPHs + 3 ;
                    4 : CPHs_NOW <= BURST_CPHs + 4 ;
                    5 : CPHs_NOW <= BURST_CPHs + 5 ;
                    6 : CPHs_NOW <= BURST_CPHs + 6 ;
                    7 : CPHs_NOW <= BURST_CPHs + 7 ;
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
    `r      XBLK ;
    `r      XBLK_AD2 ;
    `w[7:0] VIDEOs_a ;//2s
    `a VIDEOs_a = C_PEDE + YYs_i + $signed( COLORs ) ;
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
    `default_nettype wire
    `define VIDEO_SQU_ENC
`endif


`ifndef FPGA_COMPILE
    `ifndef TB_VIDEO_SQU_ENC
        `timescale 1ns/1ns
        `include "../MISC/define.vh"
        `default_nettype none
module TB_VIDEO_SQU_ENC
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
        `define TB_VIDEO_SQU_ENC
        `default_nettype wire
    `endif
`endif
