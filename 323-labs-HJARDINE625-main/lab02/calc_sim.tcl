#############################################################
#Filename: calc_sim.tcl
#
# By Hyrum Jardine
# ECEN 323 Section 2 Winter 2023
# 4/19/2023
#
# This file tests the caculator module  by simluating a waveform.
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
set force btnr 1
set force btnc 1
set force btnl 0
set force sw 1234 -radix hex
set btnd 1
run 20 ns
set btnd 0
run 20 ns

#And
set force btnr 0
set force sw 0ff0 - radix hex
set btnd 1
run 20 ns
set btnd 0
run 20 ns

#Add
set force btnc 0
set force sw 324f - radix hex
set btnd 1
run 20 ns
set btnd 0
run 20 ns

#Sub
set force btnr 1
set force sw 2d31 - radix hex
set btnd 1
run 20 ns
set btnd 0
run 20 ns

#XOR
set force sw ffff - radix hex
set force btnl 1
set btnd 1
run 20 ns
set btnd 0
run 20 ns

#less than
set force sw 7346 - radix hex
set force btnr 1
set btnd 1
run 20 ns
set btnd 0
run 20 ns

#less than
set force sw ffff - radix hex
set force btnd 1
run 20 ns
set btnd 0
run 20 ns

# End of simulation



