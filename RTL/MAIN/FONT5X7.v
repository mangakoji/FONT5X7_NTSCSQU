// FONT5X7.v
//  FONT5X7()
//
//M9Lw :1st

`ifndef FONT5X7
    `include "../MISC/define.vh"
    `default_nettype none
module FONT5X7
#(
     `p C_BAR_MODE = 0
    ,`p C_HMAGs =  7  //1,2,3,4,5,6,7,8
    ,`p C_HST   = 130 
    ,`p C_VMAGs =  3 //1,2,3,4,5,6,7,8
    ,`p C_VST   = 2
)(
     `in`tri1               CK_i
    ,`in`tri1               XARST_i
    ,`in`tri1               PX_CK_EE_i
    ,`in`tri0[5*16*12-1:0]  DATss_i
    ,`in`tri0[10:0]         HCTRs_i
    ,`in`tri0[10:0]         VCTRs_i
    ,`out`w                 HIT_o
    ,`out`w                 XBLK_o
) ;
`p C_FONT_BASEss = {
     {8'b00000_000}
    ,{8'b11111_000}
    ,{8'b10000_000}
    ,{8'b10000_000}
    ,{8'b11110_000}
    ,{8'b10000_000}
    ,{8'b10000_000}
    ,{8'b10000_000}

    ,{8'b00000_000}
    ,{8'b11111_000}
    ,{8'b10000_000}
    ,{8'b10000_000}
    ,{8'b11110_000}
    ,{8'b10000_000}
    ,{8'b10000_000}
    ,{8'b11111_000}

    ,{8'b00000_000}
    ,{8'b11110_000}
    ,{8'b10001_000}
    ,{8'b10001_000}
    ,{8'b10001_000}
    ,{8'b10001_000}
    ,{8'b10001_000}
    ,{8'b11110_000}

    ,{8'b00000_000}
    ,{8'b01110_000}
    ,{8'b10001_000}
    ,{8'b10000_000}
    ,{8'b10000_000}
    ,{8'b10000_000}
    ,{8'b10001_000}
    ,{8'b01110_000}

    ,{8'b00000_000}
    ,{8'b11110_000}
    ,{8'b10001_000}
    ,{8'b10001_000}
    ,{8'b11110_000}
    ,{8'b10001_000}
    ,{8'b10001_000}
    ,{8'b11110_000}

    ,{8'b00000_000}
    ,{8'b00100_000}
    ,{8'b01010_000}
    ,{8'b10001_000}
    ,{8'b10001_000}
    ,{8'b11111_000}
    ,{8'b10001_000}
    ,{8'b10001_000}

    ,{8'b00000_000}
    ,{8'b01110_000}
    ,{8'b10001_000}
    ,{8'b10001_000}
    ,{8'b01111_000}
    ,{8'b00001_000}
    ,{8'b00010_000}
    ,{8'b11100_000}

    ,{8'b00000_000}
    ,{8'b01110_000}
    ,{8'b10001_000}
    ,{8'b10001_000}
    ,{8'b01110_000}
    ,{8'b10001_000}
    ,{8'b10001_000}
    ,{8'b01110_000}

    ,{8'b00000_000}
    ,{8'b11111_000}
    ,{8'b00001_000}
    ,{8'b00010_000}
    ,{8'b00100_000}
    ,{8'b01000_000}
    ,{8'b01000_000}
    ,{8'b01000_000}

    ,{8'b00000_000}
    ,{8'b00111_000}
    ,{8'b01000_000}
    ,{8'b10000_000}
    ,{8'b11110_000}
    ,{8'b10001_000}
    ,{8'b10001_000}
    ,{8'b01110_000}

    ,{8'b00000_000}
    ,{8'b11111_000}
    ,{8'b10000_000}
    ,{8'b11110_000}
    ,{8'b00001_000}
    ,{8'b00001_000}
    ,{8'b10001_000}
    ,{8'b01110_000}

    ,{8'b00000_000}
    ,{8'b00010_000}
    ,{8'b00110_000}
    ,{8'b01010_000}
    ,{8'b10010_000}
    ,{8'b11111_000}
    ,{8'b00010_000}
    ,{8'b00010_000}

    ,{8'b00000_000}
    ,{8'b11111_000}
    ,{8'b00001_000}
    ,{8'b00010_000}
    ,{8'b00110_000}
    ,{8'b00001_000}
    ,{8'b10001_000}
    ,{8'b01110_000}

    ,{8'b00000_000}
    ,{8'b01110_000}
    ,{8'b10001_000}
    ,{8'b00001_000}
    ,{8'b00110_000}
    ,{8'b01000_000}
    ,{8'b10000_000}
    ,{8'b11111_000}

    ,{8'b00000_000}
    ,{8'b00100_000}
    ,{8'b01100_000}
    ,{8'b00100_000}
    ,{8'b00100_000}
    ,{8'b00100_000}
    ,{8'b00100_000}
    ,{8'b01110_000}

    ,{8'b00000_000}
    ,{8'b01110_000}
    ,{8'b10001_000}
    ,{8'b10001_000}
    ,{8'b10001_000}
    ,{8'b10001_000}
    ,{8'b10001_000}
    ,{8'b01110_000}
} ;
    `w [7:0] FONTs_s [0:8*16] ;
    `gen
        `gv gc;
        `gv gv;
        `gv gh;
        `fori(gc, 16)
        `b :g_char
            `fori(gv,8)
            `b :g_v
                `fori(gh,8)
                `b:g_h
                    `a FONTs_s[8*gc+gv][gh]
                        =`slice(C_FONT_BASEss,8*gc+(7-gv),8)>>(7-gh);
                `e
            `e
        `e
    `egen
    
    `r[2:0]HI_CTRs ; // 1,2,3,4,5,6,7,8
    `r[2:0]HP_CTRs ; // 6
    `r[3:0]HC_CTRs ; //16
    `r[2:0]VI_CTRs ; // 1,2,3,4,5,6,7,8
    `r[2:0]VP_CTRs ; // 8
    `r[3:0]VC_CTRs ; //12

    `w Hst = ((C_HST-1)==HCTRs_i) ;
    `w HI_CTRcy = `cy(HI_CTRs,(C_HMAGs-1)) ;
    `w HP_CTRcy = `cy(HP_CTRs,(6-1)) ;
    `w HC_CTRcy = `cy(HC_CTRs,(16-1)) ;
    `w Hcy = HI_CTRcy & HP_CTRcy & HC_CTRcy ;

    `w Vst = ((C_VST-1) == VCTRs_i) ;
    `w VI_CTRcy = `cy(VI_CTRs,(C_VMAGs-1)) ;
    `w VP_CTRcy = `cy(VP_CTRs,(8-1)) ;
    `w VC_CTRcy = `cy(VC_CTRs,(12-1)) ;
    `w Vcy = VI_CTRcy & VP_CTRcy & VC_CTRcy ;

    `w[4:0] DATs_s [0:16*12-1] ;
    `gen
        `gv gV,gH ;
        `fori(gV,12)
        `b:VChar
            `fori(gH,16)
            `b:HChar
                `a DATs_s[16*gV+gH] = `slice( DATss_i ,(16*gV+gH),(1+4)) ;
            `e
        `e
    `egen
    `r[3:0] HEXs    ;
    `r      DISP_ON ;
    `r      HI_CTR_IS0_D ;
    `r      HP_CTR_IS0_D ;
    `r[5:0]CHARs ;
    `r      VBLK ;
    `r      HBLK ;
    `r      XBLK ;
    `r      HIT ;
    `ack`xar
    `b  HI_CTRs<= 0 ;
        HP_CTRs<= 0 ;
        HC_CTRs<= 0 ;
        HBLK <= 1'b0 ;
        VI_CTRs<= 0 ;
        VP_CTRs<= 0 ;
        VC_CTRs<= 0 ;
        VBLK <= 1'b0 ;
        XBLK <= 1'b1 ;
        HEXs <= 0 ;
        DISP_ON <= 1'b0 ;
        HI_CTR_IS0_D <= 1'b0 ;
        HP_CTR_IS0_D <= 1'b0 ;
        HIT <= 1'b0 ;
    `eelif( PX_CK_EE_i )
    `b
                                        XBLK <= ~(HBLK & VBLK) ;
                                        HIT <=  CHARs[0] & ~XBLK ;
        if(Hst)
        `b                              HI_CTRs <= 0 ;
                                        HP_CTRs <= 0 ;
                                        HC_CTRs <= 0 ;
                                        HBLK    <= 1'b1 ;
        `eelif(Hcy)
        `b                              HBLK    <= 1'b0 ;
        `eelse
        `b  if(HI_CTRcy)
            `b                          HI_CTRs <= 0 ;
                                        `inc( HP_CTRs ) ;
                if( HP_CTRcy )
                `b                      HP_CTRs <=0 ;
                                        `inc( HC_CTRs ) ;
                `eelse                  `inc( HP_CTRs ) ;
            `eelse                      `inc( HI_CTRs ) ;
        `e
                                        HI_CTR_IS0_D <= `is0(HI_CTRs) ;
                                        HP_CTR_IS0_D <= `is0(HP_CTRs) ;
        if(`is0(HI_CTRs))               {DISP_ON,HEXs}<=
                                            DATs_s[{VC_CTRs,HC_CTRs}] 
                                        ;
        if( HI_CTR_IS0_D )
        `b  if( ~ HP_CTR_IS0_D )         CHARs <= {1'b1,CHARs[5:0]}>>1 ;
            else
            
            `b  if( DISP_ON )           CHARs <=FONTs_s[{HEXs,VP_CTRs}] ;
                else
                `b  if(C_BAR_MODE)      CHARs <=
                                            (13'b000000_1111111 << HEXs)>>7
                                        ;
                    else                CHARs <= (HEXs)? ~0: 0 ;
                `e
            `e
        `e
        if(Vst)
        `b                              VI_CTRs <= 0 ;
                                        VP_CTRs <= 0 ;
                                        VC_CTRs <= 0 ;
                                        VBLK    <= 1'b1 ;
        `eelif( Vcy )
        `b
            if( Hcy )                   VBLK    <= 1'b0 ;
        `eelse
        `b  if(Hst)
            `b  if(VI_CTRcy)
                `b
                                        VI_CTRs <= 0 ;
                                        `inc( VP_CTRs ) ;
                    if(VP_CTRcy)
                    `b
                                        VP_CTRs <= 0 ;
                                        `inc( VC_CTRs ) ;
                    `eelse
                                        `inc( VP_CTRs ) ;
                `eelse                      
                                        `inc( VI_CTRs ) ;
            `e
        `e
    `e
    `a HIT_o = HIT ;
    `a XBLK_o = XBLK ;
`emodule
    `define FONT5X7
    `default_nettype none
`endif


`ifndef TC_FONT5X7
    `include "../MISC/define.vh"
    `default_nettype none
module TC_FONT5X7
#(
     `p C_HMAGs =  6  //1,2,3,4,5,6,7,8
    ,`p C_HST   = 30 
    ,`p C_VMAGs =  6  //1,2,3,4,5,6,7,8
    ,`p C_VST   = 10 
)(
     `in`tri1               CK_i
    ,`in`tri1               XARST_i
    ,`in`tri1               XSS_i
    ,`in`tri1               COPI_i
    ,`in`tri1               SEE_i
    ,`out`w                 CIPO_o
    ,`in`tri0[10:0]         HCTRs_i
    ,`in`tri0[10:0]         VCTRs_i
    ,`out`w                 HIT_o
    ,`out`w                 XBLK_o
) ;
    `r[5*16*12-1:0]DATss ;
    `ack`xar    DATss <= 0 ;
    else
        if( ~ XSS_i )
            if( SEE_i )                 `sfl(DATss,COPI_i) ;
    `a CIPO_o = DATss[5*16*12-1] ;

    FONT5X7
        #(
             .C_HMAGs ( C_HMAGs)
            ,.C_HST   ( C_HST  )
            ,.C_VMAGs ( C_VMAGs)
            ,.C_VST   ( C_VST  )
        ) FONT5X7 
        (                     
             .CK_i              ( CK_i      )
            ,.XARST_i           ( XARST_i   )
            ,.DATss_i           ( DATss     )
            ,.HCTRs_i           ( HCTRs_i   )
            ,.VCTRs_i           ( VCTRs_i   )
            ,.HIT_o             ( HIT_o     )
            ,.XBLK_o            ( XBLK_o    )
        ) 
    ;
`emodule
    `default_nettype wire
    `define TC_FONT5X7
`endif
