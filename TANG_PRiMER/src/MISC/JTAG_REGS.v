// JTAG_REGS.v
//
//
//
`default_nettype none
`include "../../RTL/MISC/define.vh"
module JTAG_REGS
(
        `in wire            CK_i
      , `in wire            XARST_i
      , `in wire            CK_EE_i
      , `in wire [8*128-1:0] DATss_i
      , `out wire [8*128-1:0]  REGss_o
) ;

    `r [7:0] CTRs ;
    `r [2*8-1:0] CTRs_Ds ;
    `r [7:0] DATs_SELED ;
    `ack
        `xar
        `b
            CTRs <= 0 ;
            CTRs_Ds <= 0 ;
            DATs_SELED <=  0 ;
        `e else `cke
        `b
            CTRs <= CTRs + 1 ;
            CTRs_Ds <= {CTRs_Ds , CTRs} ;
            DATs_SELED <= DATss_i >> (CTRs[6:0] * 8) ;
        `e
        
    `w[7:0] REGs_SELED ;
    REGRAM 
        REGRAM
        ( 
              .clka     ( CK_i          )
            , .rsta     ( ~XARST_i      )
            , .dia      ( DATs_SELED    )
            , .addra    ( CTRs_Ds[7:0]  )
            , .wea      ( CTRs_Ds[7]    ) //upper FPGA to JTAG
            , .doa      ( REGs_SELED    )
        )
    ;
    `r[8*128-1:0]REGss ;
    `al@(`pe CK_i)
        if(~CTRs_Ds[8+7]) // lower JTAG to FPGA
            REGss[CTRs_Ds[8 +:8]] <= REGs_SELED ;
    `a REGss_o = REGss ;
endmodule
//JTAG_REGS
