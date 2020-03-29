/// PLANET_EMP_TOP.v
//
//
`default_nettype none
`include "./MISC/define.vh"
`ifndef FPGA_COMPILE
    `include "MAIN/PLANET_EMP_CORE.v"
    `include "MAIN/VIDEO_SQU.v"
`endif
module PLANET_EMP_TOP
#(
    parameter C_F_CK = 130_000_000
)(
      `in `tri1     CK_i
    , `in `tri1     XARST_i
    , `in `tri1     XPSW_i
    , `out `w       VIDEO_o
    , `out `w[5:0]  VIDEOs_o
    , `out `w       SOUND_o
    , `out `w[17:0] LEDs_ON_o
) ;
    `func `int log2;
        `in `int value ;
    `b  value = value-1;
        for (log2=0; value>0; log2=log2+1)
            value = value>>1;
    `e `efunc

    `w[5 :0]    VIDEOs  ;
    `w[17:0]    LEDs_ON ;
    PLANET_EMP_CORE
        #(
             .C_F_CK    (  C_F_CK       )
        )PLANET_EMP_CORE
        (
              .CK_i     ( CK_i          )      //8*12.27272MHz
            , .XARST_i  ( XARST_i       )
            , .XPSW_i   ( XPSW_i        )
            , .LEDs_ON_o( LEDs_ON       )
            , .SOUND_o  ( SOUND_o       )
        ) 
    ;
    `a LEDs_ON_o = LEDs_ON ;

    `lp C_F_VCK = 12_272_272 ;
    `lp C_VCK_DIV_N = ( 2*(C_F_CK/C_F_VCK)+1)/2 ;
    `lp C_PCTR_W = log2( C_VCK_DIV_N ) ;
    `r VIDEO_CK_EE ;
    `r[C_PCTR_W-1:0] PCTRs ;
    `w PCTR_cy = &(PCTRs | ~(C_VCK_DIV_N -1)) ;
    `ack
        `xar
            {VIDEO_CK_EE , PCTRs} <= 0 ;
        else
        `b
            VIDEO_CK_EE <= PCTR_cy ;
            if( PCTR_cy )
                PCTRs <= 0 ;
            else
                PCTRs <= PCTRs + 1 ;
        `e
    `a VIDEOs_o = VIDEOs ;
    `w HVcy ;
    VIDEO_SQU
//        #(
//              .C_XCBURST_SHUF     ( 1'b1 )
//        )
        VIDEO_SQU
        (
              .CK_i         ( CK_i      )      //8*12.27272MHz
            , .XARST_i      ( XARST_i   )
            , .CK_EE_i      ( VIDEO_CK_EE     )        //12.27272MHz
//            , .RST_i        ()
            , .LEDs_ON_i    ( LEDs_ON   )
            , .HVcy_o       ( HVcy      )
            , .VIDEOs_o     ( VIDEOs    )
        )
    ;
    `r      VIDEO ;
    `r[6:0] VIDEO_DSs ;
    `ack
        `xar
            VIDEO_DSs <= 0 ;
        else
            if( VIDEOs==0)
                VIDEO_DSs <= 0 ;
            else
                VIDEO_DSs <= {1'b0 , VIDEO_DSs[5:0]} + {1'b0,VIDEOs}; 
    `a VIDEO_o = VIDEO_DSs[6] ;
endmodule
//PLANET_EMP_TOP

