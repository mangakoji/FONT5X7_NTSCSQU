`ifndef S5851_I2C_MSTR
    `include ".I2C_MSTR_CORE"
    `include "../MISC/define.vh"
    `default_nettype none
module S5851_I2C_MSTR
#(
     `p C_F_CK = 135_000_000
    ,`p C_BPS =   10_000_000
)(
     `in`tri1       CK_i
    ,`in`tri1       XARST_i
    ,`in`tri0       REQ_i

    ,`out`w[11:0] TEMPs_o
    ,`out`w         DONE_o
);
    `r          CORE_REQ        ;
    `r[ 7:0]    CORE_TX_DATs    ;
    `r[ 2:0]    CORE_MODEs      ;
    `w          CORE_DONE       ;
    `w[ 7:0]    CORE_RX_DATs    ;
    `w          CORE_RX_DAT_LT  ;
    `w          CORE_ERR   ;
    I2C_MSTR_CORE
        #(
             .C_F_CK    ( C_F_CK        )
            ,.C_BPS     ( C_BPS         )
        )I2C_MSTR_CORE
        (
             .CK_i              ( CK_i          )
            ,.XARST_i           ( XARST_i       )
            ,.REQ_i             ( CORE_REQ      )
            ,.SDAO_o            ( SDAO_o        )
            ,.SDAI_i            ( SDAI_i        )
            ,.SCLO_o            ( SCLO_o        )
            ,.SCLI_i            ( SCLI_i        )
            ,.TX_DATs_i         ( CORE_TX_DATs  )
            ,.MODEs_i           ( CORE_MODEs    )
            ,.DONE_o            ( CORE_DONE     )
            ,.RX_DATs_o         ( CORE_RX_DATs  )
            ,.RX_DAT_LT_o       ( CORE_RX_DAT_LT)
            ,.ERR_o             ( CORE_ERR      )
        )
    ;
    `r[5:0] PC ;
    `r[7:0] RX_DATs ;
    `r      DONE    ;
    `define PASUE `keep(PC)
    `ack`xar
    `b
        CORE_REQ        <= 1'b0 ;
        CORE_TX_DATs    <= 0 ;
        CORE_MODEs      <= 1'b0 ;
        RX_DATs         <= 0 ;
        DONE            <= 1'b0 ;
        PC <= 0 ;
    `eelse
    `b
        `inc( PC );
        case( PC )
            0:
            `b  DONE <= 1'b0;
                if( REQ_i )
                        ;
                else
                        `PAUSE ;
            `e 1:
            `b  CORE_MODEs <= 3'b010 ; //start
                CORE_REQ <=1'b1 ;
            `e 2:
            `b
                CORE_REQ <= 1'b0 ;
                if( CORE_DONE )
                `b      CORE_TX_DATs <={SLV_ADRs_i,RD_XWT_i} ;
                        CORE_REQ <= 1'b1 ;
                        CORE_MODEs <= 3'b000 ;//WT
                `eelse
                    `PAUSE ;
            `e 3:
            `b  CORE_REQ <= 1'b0 ;
                if( CORE_DONE )
                `b      CORE_TX_DATs <= {SUB_ADRs_i} ;//wt
                        CORE_REQ <= 1'b1 ;
                        CORE_MODEs <= 3'b000 ; //WT
                `eelse
                    `PAUSE ;
            `e 4:
            `b  CORE_REQ <= 1'b0 ;
                if( CORE_DONE )
                `b      CORE_TX_DATs <={SUB_ADRs_i} ;
                        CORE_REQ <= 1'b1 ;
                        CORE_MODEs <= 3'b001 ;
                `eelse
                        `PAUSE ;
            `e 5:
            `b  CORE_REQ <= 1'b0 ;
                if( CORE_DONE )
                `b      CORE_TX_DATs <={TX_DATs_i} ;
                        if(CORE_RX_DAT_LT)
                                RX_DATs <= CORE_RX_DATs ;
                        CORE_REQ <= 1'b1 ;
                        CORE_MODEs <= 3'b001 ;
                `eelse
                        `PAUSE ;
            `e 6:
            `b  CORE_REQ <= 1'b0 ;
                if( CORE_DONE )
                `b      CORE_TX_DATs <= 0  ;
                        if(CORE_RX_DAT_LT)
                                RX_DATs <= CORE_RX_DATs ;
                        CORE_REQ <= 1'b1 ;
                        CORE_MODEs <= 3'b001 ;
                `eelse
                        `PAUSE ;
            `e 7 :
            `b  CORE_REQ <= 1'b0 ;
                if( CORE_DONE )
                `b      if(CORE_RX_DAT_LT)
                            RX_DATs <= CORE_RX_DATs ;
                        CORE_TX_DATs <= 0  ;
                        CORE_REQ <= 1'b1 ;
                        CORE_MODEs <= 3'b100 ;
                `eelse
                    `PAUSE ;
            `e 8 :
            `b  CORE_REQ <= 1'b0 ;
                if( CORE_DONE )
                `b      DONE <= 1'b1 ;
                        PC <= 0 ;
                `eelse
                        `PAUSE ;
            `e
        `ecase
    `e
    `a RX_DATs_o = RX_DATs ;
    `a DONE_o = DONE ;
`emodule
    `define S5851_I2C_MSTR
`endif

`timescale 1ns/1ns
module TB_TB_I2C_MSTR_X
#(
     parameter C_C     = 10.0
    , parameter C_F_CK = 1_000
    , `p C_BPS = 100
)(
) ;
    reg CK_i ;
    reg XARST_i ;
    initial
    begin
        CK_i <= 1'b1 ;
        forever
        begin
            #(C_C/2) CK_i <= ~ CK_i ;
        end
    end
    initial
    begin
        XARST_i <= 1'b1 ;
        #(C_C/2-0.1) XARST_i <= 1'b0 ;
        #(C_C + 0.2 ) XARST_i <= 1'b1 ;
    end
    `r       REQ_i      ;
    `r       RD_XWT_i   ;
    `r[ 7:0] TX_DATs_i  ;
    `w[ 7:0] RX_DATs_o  ;
    `r[ 6:0] SLV_ADRs_i ;
    `r[ 7:0] SUB_ADRs_i ;
    `w       SDAO_o     ;
    `w       SDAI_i     ;
    `w       SCLO_o     ;
    `w       SCLI_i     ;
    TB_I2C_MSTR_X
        #(
             .C_F_CK    ( C_F_CK )
            ,.C_BPS     ( C_BPS  )
        ) TB_I2C_MSTR_X
        (
             .CK_i          ( CK_i       )
            ,.XARST_i       ( XARST_i    )
            ,.REQ_i         ( REQ_i      )
            ,.RD_XWT_i      ( RD_XWT_i     )
            ,.TX_DATs_i     ( TX_DATs_i  )
            ,.RX_DATs_o     ( RX_DATs_o  )
            ,.SLV_ADRs_i    ( SLV_ADRs_i )
            ,.SUB_ADRs_i    ( SUB_ADRs_i )
            ,.SDAO_o        ( SDAO_o     )
            ,.SDAI_i        ( SDAI_i     )
            ,.SCLO_o        ( SCLO_o     )
            ,.SCLI_i        ( SCLI_i     )
        )
    ;
    `w SDA ;
    `a SDAI_i = SDA ;
    `w SCL ;
    `a SCLI_i = SCL ;
    pullup( SDA ) ;
    pullup( SCL ) ;
    `a SDA = SDAO_o ? 1'bz : 1'b0 ;
    `a SCL = SCLO_o ? 1'bz : 1'b0 ;
    `r[ 7:0]SDAIs ;
    `r      SDAI  ;
    `r      SCL_D ;
    `a SDA = SDAI ? 1'bz : 1'b0 ;
    `ack`xar 
    `b
        SCL_D <= 1'b1 ;
        SDAI <= 1'b1 ;
        SDAIs <= 8'hFF ;
    `eelse
    `b
        SCL_D <= SCLO_o ;
        if( TB_I2C_MSTR_X.CORE_DONE )
            case( TB_I2C_MSTR_X.PC)
                0:SDAIs <= 8'hFF ;
                1:SDAIs <= 8'hFF ;
                2:SDAIs <= 8'hFF ;
                3:SDAIs <= 8'hFF ;
                4:SDAIs <= 8'h55 ;
                5:SDAIs <= 8'h66 ;
                6:SDAIs <= 8'h77 ;
                7:SDAIs <= 8'h88 ;
                8:SDAIs <= 8'h99 ;
                default SDAIs <= ~0 ;
            `ecase
        `elif(~SCL & SCL_D) //fall
            `sfl({SDAI,SDAIs},1'b1);
    `e
    initial
    begin
        SLV_ADRs_i <= 7'h3E ;
        SUB_ADRs_i <= 8'h76 ;
        RD_XWT_i <= 1'b0 ;
        TX_DATs_i <= 8'h7E ;
        REQ_i <= 1'b0 ;
        repeat(100) @(posedge CK_i ) ;
        REQ_i <= 1'b1 ;
        repeat(1) @(posedge CK_i ) ;
        REQ_i <= 1'b0 ;
        repeat(1_500) @(posedge CK_i ) ;
        $stop ;
        $finish ;
    end
endmodule
`endif
