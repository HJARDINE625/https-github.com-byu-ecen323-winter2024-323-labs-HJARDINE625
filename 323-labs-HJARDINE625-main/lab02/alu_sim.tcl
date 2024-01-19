#############################################################
#Filename: alu_sim.tcl
#
# By Hyrum Jardine
# ECEN 323 Section 2 Winter 2023
# 4/19/2023
#
# This file tests the Alu module by simluating a waveform.
##############################################################


#Set up the simulation and run in an invalid state
restart
run 20 ns
add_force clk {0} -repeat every 10ns
run 20 ns
set force reset 1
run 20 ns
set force reset 0
run 20 ns

# Here we test btnu reset 
set btnd 0
set force btnu 1
run 20 ns
set force btnu 0
run 20 ns

#now we systematically increment up btnl btnc and btnr

#or
set force alu_op 1
set force op2 ffff - radix hex
set force op1 0000 - radix hex
run 20 ns

#And
set force alu_op 0
set force op2 ffff - radix hex
set force op1 0000 - radix hex
run 20 ns

#Add
set force alu_op 2
set force op2 ffff - radix hex
set force op1 0000 - radix hex
run 20 ns

#Sub
set force alu_op 6
set force op2 ffff - radix hex
set force op1 0000 - radix hex
run 20 ns

#XOR
set force alu_op 12
set force op2 ffff - radix hex
set force op1 0000 - radix hex
run 20 ns

#less than
set force alu_op 7
set force op2 ffff - radix hex
set force op1 0000 - radix hex
run 20 ns



# End of simulation


