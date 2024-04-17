`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/19/2023 09:15:19 AM
// Design Name: 
// Module Name: calc
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module calc(
    input wire logic clk,
    input wire logic btnc,
    input wire logic btnl,
    input wire logic btnu,
    input wire logic btnr,
    input wire logic btnd,
    input wire logic [15:0] sw,
    output logic [15:0] led
    );
    
    // the ALU can detect if there is a zero on a comparation or not,
    //but this never needs that value, so this signal soaks it up and
    //does nothing with it.
    logic useless_signal;
    
    logic debounced_alu_control_signal; 
    
    //basic on off signals
    logic ONE = 1'b1;
    logic ZERO = 1'b0;
    
    //here is a starting value for the accumulator
    logic[15:0] NOTHING = 16'h0000;
    
    //this is needed to process our results the way the insturctions ask us to.
    logic[15:0] accumulator;
    //here is a signal to soak up answers before the accumulator in the 32 bit format
    //from the ALU
    logic[31:0] preaccumulator;
    //this signal then holds it until it is needed as proven by the button being clicked
    logic[31:0] postaccumluator;
    
    // here is some logic to combine the signals so we can readily update our data.
    logic [2:0] useable_btnl = btnl? 100 : 000;
    logic [2:0] useable_btnc = btnc? 010 : 000;
    logic [2:0] useable_btnr = btnr? 001 : 000;
    
    logic[3:0] current_alu_op;
    
    wire logic current_alu_op_tracker = current_alu_op;
    
    
	localparam[3:0] ALUOP_AND = 4'b0000;
	localparam[3:0] ALUOP_OR = 4'b0001;
	localparam[3:0] ALUOP_ADD = 4'b0010;
	localparam[3:0] ALUOP_SUB = 4'b0110;
	localparam[3:0] ALUOP_LT = 4'b0111;
	localparam[3:0] ALUOP_SRL = 4'b1000;
	localparam[3:0] ALUOP_SLL = 4'b1001;
	localparam[3:0] ALUOP_SRA = 4'b1010;
	localparam[3:0] ALUOP_XOR = 4'b1101;
	
	
	localparam[2:0] FUNK_ADD = 3'b000;
	localparam[2:0] FUNK_SUB = 3'b001;
	localparam[2:0] FUNK_AND = 3'b010;
	localparam[2:0] FUNK_OR = 3'b011;
	localparam[2:0] FUNK_XOR = 3'b100;
	localparam[2:0] FUNK_LT = 3'b101;
	localparam[2:0] FUNK_SLL = 3'b110;
	localparam[2:0] FUNK_SRA = 3'b111;
	
	//these logical signals help to decide how to sign extend the switches.
	//first we need to know if the last bit is a one or a zero
	logic sw_one_or_zero;
	//here is a smilar signal for the other operation we will have to do this to
	logic op2_one_or_zero;
	//this is the new switch signal
	logic [31:0] extended_sw;
	//here is one for the op2
	logic [31:0] extended_op2;
	//two signals (ore for sign extending 1 and 1 for zero follow).
	logic[31:0] extend_one = 32'hffff0000;
	logic[31:0] extend_zero = 32'h00000000;
	
	//make a useful button signal
	wire logic[2:0] buttons; 
	assign buttons = {btnl, btnc, btnr};
	//here I define it
//	always_comb 
//	begin
//	//now I caculate it
//	buttons = useable_btnl + useable_btnc + useable_btnr;
//	end;
	//here is where we caculate the switches value for op1
	always_comb begin
	   case(sw[15])
	       ONE: extended_sw = sw + extend_one;
	       ZERO: extended_sw = sw + extend_zero;
        endcase
    end;
	
	//here we determine which opperation to prefrom if btnd is pushed.
	always_comb 
	begin
	   //only do this if the output is being looked for.
           //if(btnd)
           //here we have our case statements...
               case(buttons)
               // we need to determine which function to us
                   FUNK_ADD : current_alu_op = ALUOP_ADD;
                   FUNK_SUB : current_alu_op = ALUOP_SUB;
                   FUNK_AND : current_alu_op = ALUOP_AND;
                   FUNK_OR : current_alu_op = ALUOP_OR;
                   FUNK_XOR : current_alu_op = ALUOP_XOR;
                   FUNK_LT : current_alu_op = ALUOP_LT;
                   FUNK_SLL : current_alu_op = ALUOP_SLL;
                   FUNK_SRA : current_alu_op = ALUOP_SRA; 
                   default: current_alu_op = ALUOP_ADD;
               endcase
       end
       
       
     //Instance a oneShot module to make sure that btnd only acticates accumulator
     OneShot down_btn_oneShot(.clk(clk), .rst(btnu), .in(btnd), .os(debounced_alu_control_signal));
     
     //here is the ALU, it should only update something when the accumulator lets it (see below)
     alu math_wiz(.op1(postaccumluator), .op2(extended_sw), .alu_op(current_alu_op), .zero(useless_signal), .result(preaccumulator));
     //alu led_setter(.op1(postaccumluator), .op2(extended_sw), .alu_op(current_alu_op), .zero(useless_signal), .result());
     //alu math_wiz(.op1(postaccumluator), .op2(), .alu_op(current_alu_op), .zero(useless_signal), .result(preaccumulator));
     

       
     //here we have a flipflop to hold the accumulator values and activate the ALU as needed.  
     always_ff@(posedge clk)
     begin 
     // make sure that we are supposed to update right now
        if(btnu)
        //asign two new signals based off of this
        begin
            // only look at the first 15 digits
           accumulator <= NOTHING;
           //now update the LEDs
           led <= NOTHING;
        end   
        else
        //plug in the new signal
            if(debounced_alu_control_signal)
            //asign two new signals based off of this
            begin
            //update the accumluator
            accumulator <= preaccumulator[15:0];
            //update the LEDS
            led <= preaccumulator[15:0];
            end
     end   
     
     //this block exists sole to update the accumulator
     always_comb
     //we need to define the scope.
     begin
     // now we need to look at the end of the accumulator to see what to do
        case(accumulator[15])
        //extend ones or zeros.
	       ONE: postaccumluator = accumulator + extend_one;
	       ZERO: postaccumluator = accumulator + extend_zero;
        endcase
     end
    
    //here we have our case statements...
    
    
    // Instance alu module
    
    
    
    
endmodule
