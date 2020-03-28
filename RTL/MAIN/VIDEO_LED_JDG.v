
`default_nettype none
`include "../MISC/define.vh"
module VIDEO_LED_JDG
#(
      `p C_LED_N = 18
    , `p C_LOCsss    = 
        {
             {24'h018_058} //LED11
            ,{24'h018_018} //LED10
            ,{24'h038_008} //LED0F
            ,{24'h008_038} //LED0E

            ,{24'h058_018} //LED0D
            ,{24'h038_068} //LED0C
            ,{24'h058_058} //LED0B
            ,{24'h068_038} //LED0A

            ,{24'h0E8_138} //LED09
            ,{24'h038_078} //LED08

            ,{24'h038_088} //LED07
            ,{24'h038_098} //LED06
            ,{24'h040_0B8} //LED05
            ,{24'h050_0D8} //LED04

            ,{24'h068_0F8} //LED03
            ,{24'h088_118} //LED02
            ,{24'h0A8_128} //LED01
            ,{24'h0C8_138} //LED00
        }
    , `p C_LEDs_COLOR_ON = 18'b0111_1111_1_1_1111_1111
    , `p C_LEDs_COLORs   = 72'h1076_5432_1_0_7654_3210
)(
      `in `w            CK_i
    , `in `w            XARST_i
    , `in `w            CK_EE_i
    , `in`w[C_LED_N-1:0]    LEDs_ON_i
    , `in `w[8:0]       HCTRs_i //0-319-787/2
    , `in `w[7:0]       VCTRs_i //0-239-242
    , `out `w           LED_HIT_o
    , `out `w           LED_COLOR_ON_o
    , `out `w[2:0]      LED_COLOR_PHs_o
) ;
    `func `int log2;
        `in `int value ;
    `b
        value = value-1;
        for (log2=0; value>0; log2=log2+1)
            value = value>>1;
    `e `efunc
    `lp C_LED_NW = log2( C_LED_N +1) ;

    `func f_LED_hit ;
        `in[8:0]HCTRs ; //0-320
        `in[7:0]VCTRs ; //0-240
        `in[8:0]LOC_Xs ;
        `in[7:0]LOC_Ys ;
        `int Xs ;
        `int Ys ;
    `b
        Xs = {32'b0,HCTRs} - {32'b0,LOC_Xs} ;
        Xs = Xs[31]?(~Xs):Xs ;
        Ys = {32'b0,VCTRs} - {32'b0,LOC_Ys} ;
        Ys = Ys[31]?(~Ys):Ys ;
        f_LED_hit = (Xs <= 7) ;
        f_LED_hit = f_LED_hit & (Ys <= 7) ;
        f_LED_hit = f_LED_hit & ~(({1'b0 , Xs[2:0]}+{1'b0,Ys[2:0]})>=11) ;
    `e `efunc

    `func [31:0] f_HIT_LED_idx_s ;
        `in[8:0] HCTRs_i ;
        `in[7:0] VCTRs_i ;
        `int ii ;
    `b
        f_HIT_LED_idx_s = ~0 ;
        for(ii=C_LED_N-1;ii>=0;ii=ii-1)
            if(
                f_LED_hit
                (
                      HCTRs_i
                    , VCTRs_i
                    , C_LOCsss[ii*24    +:12]
                    , C_LOCsss[ii*24+12 +:12]
                )
            )
                f_HIT_LED_idx_s = ii ;
    `e `efunc

    `r[C_LED_NW-1:0] HIT_LED_IDXs ;//use ++1bit
    `r      LED_HIT     ;
    `r      LED_COLOR_ON;
    `r[2:0] LED_COLOR_PHs  ;
    `ack
        `xar
        `b 
            HIT_LED_IDXs <= ~0 ;
            LED_HIT <= 1'b0 ;
            LED_COLOR_ON <= 1'b0 ;
            LED_COLOR_PHs <= 0 ;
        `e else `cke
        `b
            HIT_LED_IDXs <= f_HIT_LED_idx_s(HCTRs_i,VCTRs_i) ;
//            LED_HIT <= (~(& HIT_LED_IDXs)) & LEDs_ON_i[ HIT_LED_IDXs ] ;
            LED_HIT <= LEDs_ON_i[ HIT_LED_IDXs ]  & ~(&HIT_LED_IDXs) ;
            LED_COLOR_ON <= C_LEDs_COLOR_ON[ HIT_LED_IDXs] & ~(&HIT_LED_IDXs) ;
            LED_COLOR_PHs <=
                C_LEDs_COLORs[ HIT_LED_IDXs*4 +:3]
                &(
                    (&HIT_LED_IDXs)
                    ?
                        0
                    :~0
                )
            ;
        `e
    `a LED_HIT_o = LED_HIT ;
    `a LED_COLOR_ON_o = LED_COLOR_ON ;
    `a LED_COLOR_PHs_o = LED_COLOR_PHs ;
endmodule
//
