// PLANET_EMP_CORE.v
//
// ƒQ[ƒ€!˜f¯’é‘ (as GAME! Planet Empire.)
// ‘ål‚ÌHì“Ç–{ 2004”N No.6 ÄŒfÚ

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
    `lp C_1SEC_N        = (C_DBG_ACC)? 100_000  : 1_000_000 ;
    `lp C_STOP_N        = (C_DBG_ACC)? 366_000  : 36_600_000 ; //33e6 us
    `lp C_MSL_CK_HALF_N = (C_DBG_ACC)?   1_500  :    150_000 ;
    `lp C_SND_CK_HALF_N = (C_DBG_ACC)?       4  :        150 ;
    `lp C_EMP_CK_N      = (C_DBG_ACC)?   3_000  :     300_000 ;

    


    // mastar prescaler
    `lp C_PDIV_N = C_F_CK / C_F_PDIV_CK ;
//    `lp C_PDIV_W = log2( C_PDIV_N ) ;
//    `r[C_PDIV_W-1:0] PDIV_CTRs ;
//    `w PDIV_CTR_cy = &(PDIV_CTRs | ~(C_PDIV_N-1)) ;
//    `r EE ;
//    `ack `xar
//    `b          PDIV_CTRs <= 0 ;
//                EE          <= 1'b0 ;
//    `e else
//    `b          PDIV_CTRs <= (PDIV_CTR_cy)? 0 :(PDIV_CTRs + 1) ;
//                EE          <= PDIV_CTR_cy ;
//    `e
    `w QEE ;
    `w EE ;
    RC_DLY
        #( .C_WAIT_N    ( C_PDIV_N ) //??
        ) RC_DLY_CK (
              .CK_i     ( CK_i      )
            , .XARST_i  ( XARST_i   )
            , .CK_EE_i  ( 1'b1      ) //1us 
            , .DAT_i    ( ~ QEE     )
            , .QQ_o     ( QEE       ) //not clock signal
            , .CYD_o    ( EE        )
        ) 
    ;


    // resetter
    // if push psw over 1sec , reset the game system
//    `lp C_RST_CTR_W = log2( C_1SEC_N ) ;
//    `r[C_RST_CTR_W-1:0] RST_CTRs ;
//    `w RST_CTR_cy = &(RST_CTRs | ~(C_1SEC_N-1)) ;
//    `r RST ;
//    `ack `xar
//    `b  RST_CTRs <= 1'b0 ;
//        RST <= 1'b0 ;
//    `e `elif( EE )
//    `b  if( XPSW_i )
//            RST_CTRs <= 0 ;
//        `elif( ~RST_CTR_cy )
//            RST_CTRs <= RST_CTRs + 1 ;
//        RST <= RST_CTR_cy ;
//    `e
    `w RST ;
    RC_DLY
        #( .C_WAIT_N    ( C_1SEC_N  )
        ) RC_DLY_RST(
              .CK_i     ( CK_i          )
            , .XARST_i  ( XARST_i       )
            , .CK_EE_i  ( EE            ) //1us 
            , .DAT_i    ( XPSW_i        )
            , .QQ_o     ( RST           )
//            , .CYD_o    ( cy_o          )
        ) 
    ;



//    `lp C_STOP_W = log2( C_STOP_N) ;
//    `r [C_STOP_W-1:0] STOP_CTRs ;
//    `w x_STOP_CTR_cy = &(STOP_CTRs| ~(C_STOP_N-1)) ;
//    `ack `xar   
//        STOP_CTRs <= 1'b0 ;
//    `elif( RST )
//        STOP_CTRs <=  0 ;
//    `elif( EE )
//        if( ~ x_STOP_CTR_cy )  
//                STOP_CTRs <= STOP_CTRs + 1 ;

    `w STOP ;
    RC_DLY
        #( .C_WAIT_N    ( C_STOP_N  )
        ) RC_DLY_STOP 
        (     .CK_i     ( CK_i      )
            , .XARST_i  ( XARST_i   )
            , .CK_EE_i  ( EE        ) //1us 
            , .DAT_i    ( ~ RST     )
            , .QQ_o     ( STOP      )
//            , .CYD_o    ( )
        ) 
    ;



//    `lp C_MSL_CK_CTR_W = log2( C_MSL_CK_HALF_N ) ;
//    `r MSL_XCK ;
//    `r[C_MSL_CK_CTR_W-1:0] MSL_CK_CTRs ;
//    `w MSL_CK_CTR_cy = &(MSL_CK_CTRs | ~ (C_MSL_CK_HALF_N-1)) ;
//    `ack `xar
//    `b          MSL_CK_CTRs <= 0 ;
//                MSL_XCK <= 1'b0 ;
//    `e `elif( RST )
//    `b          MSL_CK_CTRs <= 0 ;
//                MSL_XCK <= 1'b0 ;
//    `e `elif(EE & ~ x_STOP_CTR_cy )
//    `b          MSL_CK_CTRs <= (MSL_CK_CTR_cy)? 0 : (MSL_CK_CTRs + 1) ;
//                if(MSL_CK_CTR_cy) 
//                    MSL_XCK <= ~ MSL_XCK ;
//    `e
//    `w MSL_ck = ~ MSL_XCK ;

    `w MSL_XCK ;
    RC_DLY
        #( .C_WAIT_N    ( C_MSL_CK_HALF_N   ) 
        ) RC_DLY_MSLCK_CTR 
        (
              .CK_i     ( CK_i          )
            , .XARST_i  ( XARST_i       )
            , .RST_i    ( RST           )
            , .CK_EE_i  ( EE  & ~STOP   ) //1us 
            , .DAT_i    ( ~ MSL_XCK     )
            , .QQ_o     ( MSL_XCK       )
//            , .CYD_o    ()
        ) 
    ;
    `w MSL_ck = ~ MSL_XCK ;

    `w [9:0] MSL_qs ;
    MC14017
        IC1(  .ARST_i       ( ~XARST_i | (~XPSW_i & MSL_qs[9])  | RST )
            , .CK_i         ( MSL_ck            )
            , .XEN_XCK_i    ( MSL_qs[9]             )
            , .qs_o         ( MSL_qs                )
//            , .CYD_o        ()
        ) 
    ;

    `a LEDs_ON_o[0] = MSL_qs[9]  ;
    `a LEDs_ON_o[1] = MSL_qs[0]  ;
    `a LEDs_ON_o[2] = MSL_qs[1]  ;
    `a LEDs_ON_o[3] = MSL_qs[2]  ;
    `a LEDs_ON_o[4] = MSL_qs[3]  ;
    `a LEDs_ON_o[5] = MSL_qs[4]  ;
    `a LEDs_ON_o[6] = MSL_qs[5]  ;
    `a LEDs_ON_o[7] = MSL_qs[6]  ;
    `a LEDs_ON_o[8] = MSL_qs[7]  ;

//    `lp C_SND_CTR_W = log2(C_SND_CK_HALF_N) ;
//    `r[C_SND_CTR_W-1:0] SND_CTRs ;
//    `w SND_CTR_cy = &(SND_CTRs | ~ (C_SND_CK_HALF_N-1)) ;
//    `r SND ;
//    `ack `xar
//    `b          SND <= 1'b0 ;
//                SND_CTRs <= 0 ;
//    `e `elif( RST )
//    `b          SND <= 1'b0 ;
//                SND_CTRs <= 0 ;
//    `e `elif( EE )
//        if(MSL_ck & ~MSL_qs[9])
//        `b      SND_CTRs <= (SND_CTR_cy)? 0 :(SND_CTRs+1) ;
//                if(SND_CTR_cy)  SND <= ~SND ;
//        `e
//    `a SOUND_o = SND ;
    `w SND ;
    RC_DLY
        #( .C_WAIT_N    ( C_SND_CK_HALF_N   )
        ) RC_DLY_SND_CTR 
        (     .CK_i     ( CK_i              )
            , .XARST_i  ( XARST_i           )
            , .RST_i    ( RST               )
            , .CK_EE_i  ( EE                ) //1us 
            , .DAT_i    ( ~ SND  & MSL_ck & ~MSL_qs[9])
            , .QQ_o     ( SND               )
//            , .CYD_o     ()
        ) 
    ;
    `a SOUND_o = SND ;

//    `lp C_EMP_CTR_W = log2(C_EMP_CK_N) ;
//    `r[C_EMP_CTR_W-1:0] EMP_CTRs ;
//    `w EMP_CTR_cy = &(EMP_CTRs | ~(C_EMP_CK_N-1)) ;
//    `r EMP_CK ;
//    `ack `xar 
//    `b          EMP_CTRs <= 0 ;
//                EMP_CK <= 1'b0 ;
//    `e `elif( RST )
//    `b          EMP_CTRs <= 0 ;
//                EMP_CK <= 1'b0 ;
//    `e `elif( EE )
//    `b          EMP_CTRs <= EMP_CTR_cy ? 0 : (EMP_CTRs+1) ;
//                if(EMP_CTR_cy)
//                    EMP_CK <= ~ EMP_CK ;
//    `e
    `w EMP_CK ;
    RC_DLY
        #( .C_WAIT_N    ( C_EMP_CK_N ) //??
        ) RC_DLY_EMP_CK_CTR (
              .CK_i     ( CK_i      )
            , .XARST_i  ( XARST_i   )
            , .RST_i    ( RST       )
            , .CK_EE_i  ( EE        ) //1us 
            , .DAT_i    ( ~ EMP_CK )
            , .QQ_o     ( EMP_CK   )
//            , .CYD_o     ()
        ) 
    ;


    `w[7:0] EMP_QQs ;
    MC14015
        IC2_A
        (   
              .CK_i         ( EMP_CK                )
            , .ARST_i       ( ~XARST_i  | RST       )
            , .DAT_i        ( EMP_QQs[7] | MSL_qs[8])
            , .QQs_o        ( EMP_QQs[3:0]          )
        ) 
    ;
    MC14015
        IC2_B
        (     
              .CK_i         ( EMP_CK                )
            , .ARST_i       ( ~XARST_i | RST        )
            , .DAT_i        ( EMP_QQs[3]            )
            , .QQs_o        ( EMP_QQs[7:4]          )
        ) 
    ;
    `a LEDs_ON_o[ 9] =   EMP_QQs[7]  ;
    `a LEDs_ON_o[10] = ~ EMP_QQs[7] ;
    `a LEDs_ON_o[11] = ~ EMP_QQs[4] ;
    `a LEDs_ON_o[12] = ~ EMP_QQs[5] ;
    `a LEDs_ON_o[13] = ~ EMP_QQs[6] ;
    `a LEDs_ON_o[14] = ~ EMP_QQs[3] ;
    `a LEDs_ON_o[15] = ~ EMP_QQs[0] ;
    `a LEDs_ON_o[16] = ~ EMP_QQs[1] ;
    `a LEDs_ON_o[17] = ~ EMP_QQs[2] ;
endmodule



module RC_DLY
#(
      `param C_WAIT_N = 1000
)(
      `in `tri1 CK_i
    , `in `tri1 XARST_i
    , `in `tri1 CK_EE_i //1us 
    , `in `tri0 RST_i
    , `in `tri0 DAT_i
    , `out `w QQ_o
    , `out `w CYD_o
) ;
    // log2() for calc bit width from data N
    // constant function on Verilog 2001
    `func `int log2 ;
        `in `int value ;
    `b  value = value - 1 ;
        for(log2=0 ; value>0 ; log2=log2+1)
            value = value>>1 ;
    `e `efunc

    `lp C_CTR_W = log2( C_WAIT_N ) ;
    `r[C_CTR_W-1:0] CTRs ;
    `w cy = &(CTRs | ~(C_WAIT_N-1)) ;
//    `a cy_o = cy ;
    `r QQ ;
    `r CYD ;
    `ack `xar
    `b  CTRs    <= 1'b0 ;
        QQ      <= 1'b0 ;
        CYD     <= 1'b0 ;
    `e else `cke
    `b  if( cy | RST_i)
        `b  CTRs <= 0 ;
            QQ <= DAT_i ;
        `e `elif( (QQ ^ DAT_i) )
            CTRs <= CTRs + 1 ;
        else
            CTRs <= CTRs ; // stop
        CYD <= cy ;
    `e
    `a QQ_o = QQ ;
    `a CYD_o = cy ;
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
        `b  for(jj=0;jj<(3);jj=jj+1)
            XPSW_i <= jj[0] ;
            `b  for(ii=0;ii<(2**20);ii=ii+1)
                `b  
                    @(`pe CK_i) ;
        `e  `e  `e
        repeat(100) @(posedge CK_i) ;
        $stop ;
        $finish ;
    `e
`emodule

