// This timescale statement indicates that each time tick of the simulator
// is 1 nanosecond and the simulator has a precision of 1 picosecond. This 
// is used for simulation and all of your SystemVerilog files should have 
// this statement at the top. 
`timescale 1 ns / 1 ps 

/***************************************************************************
* 
* File: UpDownButtonCount.sv
*
* Author: Professor Mike Wirthlin
* Class: ECEN 323, Winter Semester 2020
* Date: 12/10/2020
*
* Module: ButtonCount
*
* Description:
*    This module includes a state machine that will provide a one cycle
*    signal every time the top button (btnu) is pressed (this is sometimes
*    called a 'single-shot' filter of the button signal). This signal
*    is used to increment a counter that is displayed on the LEDs. The
*    center button (btnc) is used as an asynchronous reset.
*
*    This module is used to help students review their RTL design skills and
*    get the design tools working.  
*
****************************************************************************/

module UpDownButtonCount(clk, btnc, btnu, btnd, btnl, btnr, sw, led);

	input wire logic clk, btnc, btnu, btnd, btnl, btnr;
	input wire logic [15:0] sw;
	output logic [15:0] led;
	
	// The internal 16-bit count signal. 
	logic [15:0] count_i;
	// The increment counter output from the one shot module
	logic inc_count;
	// reset signal
	logic rst;
	// increment signals (synchronized version of btnu)
	logic btnu_d, btnu_dd, inc;
	
	// The deincrement counter output from the one shot module
	logic de_count;
	// deincrement signals (synchronized version of btnd)
	logic btnd_d, btnd_dd, deinc;
	
    // The more significant deincrement counter output from the one shot module
	logic fast_de_count;
	// large deincrement signals (synchronized version of btnd)
	logic btnl_d, btnl_dd, fast_deinc;
	
	// The more significant increment counter output from the one shot module
	logic fast_count;
	// large increment signals (synchronized version of btnn)
	logic btnr_d, btnr_dd, fast_inc;

	// Assign the 'rst' signal to button c
	assign rst = btnc;

	// The following always block creates a "synchronizer" for the 'btnu' and 'btnd' input.
	// A synchronizer synchronizes the asynchronous inputs to the global
	// clock (when you press a button you are not synchronous with anything!).
	// This particular synchronizer is just two flip-flop in series: 'btnu(d)_d'
	// is the first flip-flop of the synchronizer and 'btnu(d)_dd' is the second
	// flip-flop of the synchronizer. You should always have a synchronizer on
	// [any] button input if they are used in a sequential circuit.
	//Of note:
	always_ff@(posedge clk)
		if (rst) begin
			btnu_d <= 0;
			btnu_dd <= 0;
			btnd_dd <= 0;
			btnd_d <= 0;
			btnl_dd <= 0;
			btnl_d <= 0;
		    btnr_dd <= 0;
			btnr_d <= 0;
		end
		else begin
			btnu_d <= btnu;
			btnu_dd <= btnu_d;
			btnd_d <= btnd;
			btnd_dd <= btnd_d;
			btnl_d <= btnl;
			btnl_dd <= btnl_d;
			btnr_d <= btnr;
			btnr_dd <= btnr_d;    
		end
	assign inc = btnu_dd;
	assign deinc = btnd_dd;
	assign fast_deinc = btnl_dd;
	assign fast_inc = btnr_dd;

	// Instance the OneShot module
	OneShot os (.clk(clk), .rst(rst), .in(inc), .os(inc_count));
	
	// Instancing second OneShot module, to deincrement
	OneShot sos (.clk(clk), .rst(rst), .in(deinc), .os(de_count));
	
	// Instancing the fast increment OneShot module
	OneShot fastinc (.clk(clk), .rst(rst), .in(fast_inc), .os(fast_count));
	
	// Instancing the fast deincrement OneShot module
	OneShot fastneg (.clk(clk), .rst(rst), .in(fast_deinc), .os(fast_de_count));

	// 16-bit Counter. Increments once each time button is pressed. 
	//
	// This is an exmaple of a 'sequential' statement that will synthesize flip-flops
	// as well as the logic for incrementing the count value.
	//
	//  CODING STANDARD: Every "segment/block" of your RTL code must have at least
	//  one line of white space between it and the previous and following block. Also,
	//  ALL always blocks must have a coment.
	always_ff@(posedge clk)
		if (rst)
			count_i <= 0;
		else if (inc_count)
			count_i <= count_i + 1;
		else if (de_count)
		    count_i <= count_i - 1;
		else if (fast_count)
		    count_i <= count_i + sw;
		else if (fast_de_count)
		    count_i <= count_i - sw;
	
	// Assign the 'led' output the value of the internal count_i signal.
	assign led = count_i;

endmodule