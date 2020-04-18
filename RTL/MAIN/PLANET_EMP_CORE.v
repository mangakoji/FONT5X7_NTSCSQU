// PLANET_EMP_CORE.v
//
// �Q�[��!�f���鍑 (as GAME! Planet Empire.)
// ��l�̍H��ǖ{ 2004�N No.6 �Čf��
// by MATSUMOTO,satoru (���{��)

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
    , `out `w               SOUND_o
    , `out `w [7:0]         DBGs_o
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
    `w EE ;
    `w pcy ;
    RC_DLY
        #( .C_WAIT_N    ( C_PDIV_N ) //??
        ) RC_DLY_CK (
              .CK_i     ( CK_i      )
            , .XARST_i  ( XARST_i   )
            , .CK_EE_i  ( 1'b1      )
            , .RST_i    ( pcy       )
//            , .DAT_i    ()
//            , .QQ_o     () //not clock signal
            , .cy_o     ( pcy       )
            , .CYD_o    ( EE        ) //1us 1pluseH
        ) 
    ;

    // resetter
    // if push psw over 1sec , reset the game system
    `w RST ;
    RC_DLY
        #( .C_WAIT_N    ( C_1SEC_N  )
        ) RC_DLY_RST(
              .CK_i     ( CK_i          )
            , .XARST_i  ( XARST_i       )
            , .CK_EE_i  ( EE            ) //1us 
            , .RST_i    ( XPSW_i        )
            , .DAT_i    ( 1'b1          )
            , .QQ_o     ( RST           )
//            , .cy_o     ()
//            , .CYD_o    ()
        ) 
    ;


    `w STOP ;
    RC_DLY
        #( .C_WAIT_N    ( C_STOP_N  )
        ) RC_DLY_STOP 
        (     .CK_i     ( CK_i      )
            , .XARST_i  ( XARST_i  & ~RST )
            , .CK_EE_i  ( EE        ) //1us 
            , .RST_i    ( RST       )
            , .DAT_i    ( 1'b1      )
            , .QQ_o     ( STOP      )
//            , .CYD_o    ( )
        ) 
    ;

    `w MSL_XCK  ;
    `w MSL_cy   ;
    RC_DLY
        #( .C_WAIT_N    ( C_MSL_CK_HALF_N   ) 
        ) RC_DLY_MSLCK_CTR 
        (
              .CK_i     ( CK_i              )
            , .XARST_i  ( XARST_i & ~RST     )
            , .CK_EE_i  ( EE                ) //1us 
            , .RST_i    ( MSL_cy            )
            , .DAT_i    ( ~(STOP|RST) & MSL_XCK   )
            , .QQ_o     ( MSL_XCK           )
            , .cy_o     ( MSL_cy            )
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



    `w SND ;
    `w SND_cy ;
    RC_DLY
        #( .C_WAIT_N    ( C_SND_CK_HALF_N   )
        ) RC_DLY_SND_CTR 
        (     .CK_i     ( CK_i              )
            , .XARST_i  ( XARST_i &(~RST)    )
            , .CK_EE_i  ( EE & MSL_ck & ~MSL_qs[9] ) //1us 
            , .RST_i    ( SND_cy            )
            , .DAT_i    ( SND               )
            , .QQ_o     ( SND               )
            , .cy_o     ( SND_cy            )
//            , .CYD_o     ()
        ) 
    ;
    `a SOUND_o = SND ;

    `w EMP_CK   ;
    `w EMP_CK_cy ;
    RC_DLY
        #( .C_WAIT_N    ( C_EMP_CK_N        ) //??
        ) RC_DLY_EMP_CK_CTR (
              .CK_i     ( CK_i              )
            , .XARST_i  ( XARST_i & ~RST    )
            , .CK_EE_i  ( EE                ) //1us 
            , .RST_i    ( EMP_CK_cy         )
            , .DAT_i    ( EMP_CK            )
            , .QQ_o     ( EMP_CK            )
            , .cy_o     ( EMP_CK_cy         )
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

    `a DBGs_o[0] = RST          ;
    `a DBGs_o[1] = STOP         ;
    `a DBGs_o[2] = MSL_ck       ;
    `a DBGs_o[3] = MSL_qs[9]    ;
    `a DBGs_o[4] = MSL_qs[8]    ;
    `a DBGs_o[5] = EMP_QQs[7]   ;
    `a DBGs_o[6] = EMP_CK       ; 
    `a DBGs_o[7] = ~XARST_i | RST ;

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
    , `out `w cy_o
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
    `a cy_o = cy ;
    `r QQ ;
    `r CYD ;
    `ack `xar
    `b  CTRs    <= 1'b0 ;
        QQ      <= 1'b0 ;
        CYD     <= 1'b0 ;
    `e else `cke
    `b  if( RST_i )
        `b  CTRs <= 0 ;
            CYD <= 1'b0 ;
            QQ <= ~DAT_i ;
        `e else
        `b
            if( ~ cy )
                CTRs <= CTRs + 1 ;
            else
                CTRs <= CTRs ; // stop
            if( cy & ~CYD )
                QQ <= DAT_i ;
        `e
        CYD <= cy ;
    `e
    `a QQ_o = QQ ;
    `a CYD_o = CYD ;
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

