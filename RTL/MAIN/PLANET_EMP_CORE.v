// PLANET_EMP_CORE.v
//
// �Q�[��!�f���鍑 (as GAME! Planet Empire.)
// ��l�̍H��ǖ{ 2004�N No.6 �Čf��

`default_nettype none
`include "../MISC/define.vh"
module PLANET_EMP_CORE
#(    
      `p C_F_CK = 135_000_000
    , `p C_DBG_ACC = 0 
    , `p C_LED_N = 18
)(    
      `in `tri1             CK_i
    , `in `tri1             XARST_i
    , `in `tri0             XPSW_i
    , `out `w[C_LED_N-1:0] LEDs_ON_o
    , `out `w              SOUND_o
) ;
    // log2() for calc bit width from data N
    // constant function on Verilog 2001
    `func `int log2 ;
        `in `int value ;
    `b  value = value - 1 ;
        for(log2=0 ; value>0 ; log2=log2+1)
            value = value>>1 ;
    `e `efunc

    `lp C_F_PDIV_CK     = (C_DBG_ACC)? C_F_CK/4 : 1_000_000 ;
    `lp C_STOP_N        = (C_DBG_ACC)? 366_000  : 36_600_000 ; //33e6 us
    `lp C_MSL_CK_HALF_N = (C_DBG_ACC)?   1_500  :    150_000 ;
    `lp C_SND_CK_HALF_N = (C_DBG_ACC)?       4  :        150 ;
    `lp C_EMP_CK_N      = (C_DBG_ACC)?   3_000  :     300_000 ;

    // mastar prescaler
    `lp C_PDIV_N = C_F_CK / C_F_PDIV_CK ;
    `lp C_PDIV_W = log2( C_PDIV_N ) ;
    `r[C_PDIV_W-1:0] PDIV_CTRs ;
    `w PDIV_CTR_cy = &(PDIV_CTRs | ~(C_PDIV_N-1)) ;
    `r EE ;
    `ack `xar
    `b          PDIV_CTRs <= 0 ;
                EE          <= 1'b0 ;
    `e else
    `b          PDIV_CTRs <= (PDIV_CTR_cy)? 0 :(PDIV_CTRs + 1) ;
                EE          <= PDIV_CTR_cy ;
    `e

    `lp C_STOP_W = log2( C_STOP_N) ;
    `r [C_STOP_W-1:0] STOP_CTRs ;
    `w x_STOP_CTR_cy = &(STOP_CTRs| ~(C_STOP_N-1)) ;
    `ack `xar   STOP_CTRs <= 1'b0 ;
    `elif( EE )
        if( ~ x_STOP_CTR_cy )  
                STOP_CTRs <= STOP_CTRs + 1 ;

    `lp C_MSL_CK_CTR_W = log2( C_MSL_CK_HALF_N ) ;
    `r MSL_XCK ;
    `r[C_MSL_CK_CTR_W-1:0] MSL_CK_CTRs ;
    `w MSL_CK_CTR_cy = &(MSL_CK_CTRs | ~ (C_MSL_CK_HALF_N-1)) ;
    `ack `xar
    `b          MSL_CK_CTRs <= 0 ;
                MSL_XCK <= 1'b0 ;
    `e `elif(EE & ~ x_STOP_CTR_cy )
    `b          MSL_CK_CTRs <= (MSL_CK_CTR_cy)? 0 : (MSL_CK_CTRs + 1) ;
                if(MSL_CK_CTR_cy) 
                    MSL_XCK <= ~ MSL_XCK ;
    `e
    `w MSL_ck = ~ MSL_XCK ;
    `w [9:0] MSL_qs ;
    MC14017
        Q1(   .ARST_i       ( ~XARST_i | ~XPSW_i & MSL_qs[9]   )
            , .CK_i         ( MSL_ck            )
            , .XEN_XCK_i    ( MSL_qs[9]             )
            , .qs_o         ( MSL_qs                )
            , .CY_o         ()
        ) 
    ;

    `a LEDs_ON_o[7:0] = MSL_qs[7:0] ;
//     `a LEDs_ON_o[8] = MSL_qs[8] ;
    `a LEDs_ON_o[9] = MSL_qs[9]  ;

    `lp C_SND_CTR_W = log2(C_SND_CK_HALF_N) ;
    `r[C_SND_CTR_W-1:0] SND_CTRs ;
    `w SND_CTR_cy = &(SND_CTRs | ~ (C_SND_CK_HALF_N-1)) ;
    `r SND ;
    `ack `xar
    `b          SND <= 1'b0 ;
                SND_CTRs <= 0 ;
    `e `elif( EE )
        if(MSL_ck & ~MSL_qs[9])
        `b      SND_CTRs <= (SND_CTR_cy)? 0 :(SND_CTRs+1) ;
                if(SND_CTR_cy)  SND <= ~SND ;
        `e
    `a SOUND_o = SND ;

    `lp C_EMP_CTR_W = log2(C_EMP_CK_N) ;
    `r[C_EMP_CTR_W-1:0] EMP_CTRs ;
    `w EMP_CTR_cy = &(EMP_CTRs | ~(C_EMP_CK_N-1)) ;
    `r EMP_CK ;
    `ack `xar 
    `b          EMP_CTRs <= 0 ;
                EMP_CK <= 1'b0 ;
    `e `elif( EE )
    `b          EMP_CTRs <= EMP_CTR_cy ? 0 : (EMP_CTRs+1) ;
                if(EMP_CTR_cy)
                    EMP_CK <= ~ EMP_CK ;
    `e
    `w[7:0] EMP_QQs ;
    MC14015
        Q2_A
        (   
              .CK_i         ( EMP_CK                )
            , .ARST_i       ( ~XARST_i              )
            , .DAT_i        ( EMP_QQs[7] | MSL_qs[8])
            , .QQs_o        ( EMP_QQs[3:0]          )
        ) 
    ;
    MC14015
        Q2_B
        (     
              .CK_i         ( EMP_CK        )
            , .ARST_i       ( ~XARST_i      )
            , .DAT_i        ( EMP_QQs[3]    )
            , .QQs_o        ( EMP_QQs[7:4]  )
        ) 
    ;
    `a LEDs_ON_o[ 8] =   EMP_QQs[7]  ;
    `a LEDs_ON_o[10] = ~ EMP_QQs[0] ;
    `a LEDs_ON_o[11] = ~ EMP_QQs[1] ;
    `a LEDs_ON_o[12] = ~ EMP_QQs[2] ;
    `a LEDs_ON_o[13] = ~ EMP_QQs[3] ;
    `a LEDs_ON_o[14] = ~ EMP_QQs[4] ;
    `a LEDs_ON_o[15] = ~ EMP_QQs[5] ;
    `a LEDs_ON_o[16] = ~ EMP_QQs[6] ;
    `a LEDs_ON_o[17] = ~ EMP_QQs[7] ;
endmodule


// jonson x 1 hot 10state counter
module MC14017
(     
      `in `w ARST_i
    , `in `w CK_i
    , `in `w XEN_XCK_i
    , `out `w[9:0] qs_o
    , `out `w       CY_o
) ;
    `w ck ;
    `a ck = CK_i & ~XEN_XCK_i ;
    `r [4:0] QQs ;
    `w d2 = ~(~QQs[1] & (~QQs[0] | ~QQs[2])) ;
    `al@(`pe ck or `pe ARST_i)
        if(ARST_i)  QQs <= ~0 ;
        else        QQs <= {QQs[3:2] , d2 , QQs[0] , ~QQs[4]} ;
    `a CY_o = QQs[4] ;
    `w[9:0] qs ;
    `a qs[0] =  QQs[0] &  QQs[4] ;
    `a qs[1] =  QQs[1] & ~QQs[0] ;
    `a qs[2] =  QQs[2] & ~QQs[1] ;
    `a qs[3] =  QQs[3] & ~QQs[2] ;
    `a qs[4] =  QQs[4] & ~QQs[3] ;
    `a qs[5] = ~QQs[0] & ~QQs[4] ;
    `a qs[6] = ~QQs[1] &  QQs[0] ;
    `a qs[7] = ~QQs[2] &  QQs[1] ;
    `a qs[8] = ~QQs[3] &  QQs[2] ;
    `a qs[9] = ~QQs[4] &  QQs[3] ;
    `a qs_o = qs ;
endmodule


//4 reg shifter
module MC14015
(     
      `in `w        CK_i
    , `in `w        ARST_i
    , `in `w        DAT_i
    , `out `w[3:0]  QQs_o
) ;
    `r [3:0] QQs ;
    `al@(`pe CK_i or `pe ARST_i)
        if(ARST_i)  QQs <= 0 ;
        else        QQs <= {QQs, DAT_i} ;
    `a QQs_o = QQs ;
endmodule


`timescale 1ns/1ns
module TB_PLANET_EMP_CORE
#(
    `p C_C=10.0
)(
) ;
    `r         CK_EE_i ;
    `r CK_i ;
    `init `b
        CK_EE_i <= 1'b1 ;
        CK_i <= 1'b1 ;
        forever 
        `b  #(C_C/2.0)
                CK_i <= ~ CK_i ;
        `e
    `e
    `r XARST_i ;
    `init 
    `b  XARST_i <= 1'b1 ;
        #(0.1 * C_C)
            XARST_i <= 1'b0 ;
        #(3.1 * C_C)
            XARST_i <= 1'b1 ;
    `e

    `r      XPSW_i      ;
    `w[17:0]LEDs_ON_o   ;
    `w      SOUND_o     ;
    PLANET_EMP_CORE
        #(
             .C_DBG_ACC ( ~0        )
        )PLANET_EMP_CORE
        (
              .CK_i     ( CK_i      )      //8*12.27272MHz
            , .XARST_i  ( XARST_i   )
            , .XPSW_i   ( XPSW_i    )
            , .LEDs_ON_o( LEDs_ON_o )
            , .SOUND_o  ( SOUND_o   )
        ) 
    ;
    `int kk ;
    `int jj ;
    `int ii ;
    `init
    `b  
        ii <= ~0 ;
        jj <= ~0 ;
        kk <= ~0 ;
        XPSW_i <= 1'b1 ;
        repeat(100)@(`pe CK_i) ;
        for(kk=0;kk<(2**0);kk=kk+1)
        `b  for(jj=0;jj<(2**0);jj=jj+1)
            `b  for(ii=0;ii<(2**24);ii=ii+1)
                `b  
                    @(`pe CK_i) ;
        `e  `e  `e
        repeat(100) @(posedge CK_i) ;
        $stop ;
        $finish ;
    `e
`emodule
