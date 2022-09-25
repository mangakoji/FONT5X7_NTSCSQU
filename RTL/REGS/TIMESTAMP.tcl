#./RTL/MISC/TIMESTAMP.tcl
#
# FPGA timestamper
#
# usage :
# 1. add this line in qsf.
#     set_global_assignment -name PRE_FLOW_SCRIPT_FILE "quartus_sh:./RTL/MISC/TIMESTAMP.tcl"
# 2. add this line in your Verilog RTL.
#     `include "<relative path>/TIMESTAMP.vh"
#  and you get parameter [31:0] C_TIMESTAMP = <ctime at compile start>
#
#J11t
# C1:   mod dir ./RTL -> ./RTL/MISC
#ICVm 
#    :1st release


set now [clock seconds]
puts $now
set now_fmt [clock format $now]
puts $now_fmt
set now_fmt [clock format $now]
puts $now_fmt
puts [format %08X $now]
if [catch {open "../RTL/REGS/TIMESTAMP.vh" w} fp] {
   error "file cannot open!!!!"
}
puts $fp "// TIMESTAMP.vh"
puts $fp [format "// %s" $now_fmt]
puts $fp [format "// %08X" $now]
puts $fp [format "parameter \[31:0\] C_TIMESTAMP = 32'h%s ;" [format %08X $now] ]
close $fp
