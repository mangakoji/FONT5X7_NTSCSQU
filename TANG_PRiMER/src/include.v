`define FPGA_COMPILE
`define TANG_FPGA
`include "../prj/al_ip/PLL.v"
`include "../prj/al_ip/REGRAM.v"

`include "../../RTL/MAIN/PLANET_EMP_CORE.v"
`include "../../RTL/MAIN/VIDEO_LED_JDG.v"
`include "../../RTL/MAIN/VIDEO_SQU_TG.v"
`include "../../RTL/MAIN/VIDEO_SQU.v"
`include "../../RTL/PLANET_EMP_TOP.v"
`include "./MISC/JTAG_REGS.v"

`include "./TANG_PRiMER.v"
