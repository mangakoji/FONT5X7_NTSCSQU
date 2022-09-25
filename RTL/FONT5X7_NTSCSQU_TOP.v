/// FONT5X7_NTSCSQU_TOP.v
//
// FPGA 2nd layer
//M9Nf : 1st.
//

`ifndef FPGA_COMPILE
    `include "NTSCSQU/NTSCSQU_TOP.v"
`endif
`ifndef FONT5X7_NTSCSQU_TOP
    `default_nettype none
    `include "./MISC/define.vh"
module FONT5X7_NTSCSQU_TOP
#(
    parameter C_F_CK = 130_000_000
)(
      `in `tri1     CK_i
    , `in `tri1     XARST_i
    ,`in`tri0[ 7:0] BUS_R9DATs_i
    ,`in`tri0[ 7:0] BUS_R8DATs_i
    ,`in`tri0[31:0] BUS_TIMESTAMPs_i
    ,`in`tri0[31:0] BUS_VERSIONs_i
    ,`in`tri0       XPSW_i
    ,`out`w         VIDEO_o
    ,`out`w         SOUND_o
) ;
    `func `int log2;
        `in `int value ;
    `b  value = value-1;
        for (log2=0; value>0; log2=log2+1)
            value = value>>1;
    `e `efunc

    `w  PX_CK_EE ;
    `r[32:0] MSEQs ;
    `w[ 6:0] DICE_LEDs ;
    NTSCSQU_TOP
        #(
             .C_F_CK     ( C_F_CK )
        ) NTSCSQU_TOP
        (
              .CK_i             ( CK_i              )//n x 12.27272MHz
            ,.XARST_i           ( XARST_i           )
            ,.PX_CK_EE_o        ( PX_CK_EE          )
//            ,.DISP_DATss_i      ( MSEQs             )
            ,.DISP_DATss_i      ( {BUS_R9DATs_i,BUS_R8DATs_i}      )
            ,.BUS_TIMESTAMPs_i  ( BUS_TIMESTAMPs_i  )
            ,.BUS_VERSIONs_i    ( BUS_VERSIONs_i    )
            ,.DICE_LEDs_i       ( DICE_LEDs         )
            ,.XPSW_i            ( XPSW_i            )
            ,.VIDEO_o           ( VIDEO_o           )
        )
    ;
    `r[20:0]PCTRs ;
    `r[ 4:0]BCTRs ;
    // GP (32,22,2,1)
    `lp C_GPs = 32'h8020_0003 ;
    `w MSEQ_next = ^(C_GPs & MSEQs) ;
    `ack`xar
    `b
        PCTRs <= 0 ;
        MSEQs <= ~0 ;
    `eelif( PX_CK_EE )
    `b
                                        `inc( PCTRs ) ;
        if( `is0(PCTRs ))
        `b                              `sfl(MSEQs,MSEQ_next) ;
            if(BCTRs[3:0]==7)           
            `b
                                        BCTRs[4] <= 1'b1 ;
                                        `dec(BCTRs[3:0]) ;
            `eelif(BCTRs[3:0]==0)
            `b
                                        BCTRs[4] <= 1'b0 ;
                                        `inc(BCTRs[3:0]) ;
            `eelif( BCTRs[4] )          `dec(BCTRs[3:0]) ;
            else                        `inc(BCTRs[3:0]) ;
        `e
    `e
    
    `a DICE_LEDs = MSEQs ; //{7{BCTRs[4]}} ;
    
    // append sounder later. maybe
    `a SOUND_o = PCTRs[16] ;
    
endmodule
    `default_nettype wire
    `define FONT5X7_NTSCSQU_TOP
`endif

