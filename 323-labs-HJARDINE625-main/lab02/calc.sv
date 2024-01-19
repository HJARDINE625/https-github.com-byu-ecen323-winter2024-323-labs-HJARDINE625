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
    input clk,
    input btnc,
    input btnl,
    input btnu,
    input btnr,
    input btnd,
    input [15:0] sw,
    output [15:0] led
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
    
    logic[2:0] buttons = useable_btnl + useable_btnc + useable_btnr;
    
    logic[3:0] ALUOP_AND = 4'b0000;
	logic[3:0] ALUOP_OR = 4'b0001;
	logic[3:0] ALUOP_ADD = 4'b0010;
	logic[3:0] ALUOP_SUB = 4'b0110;
	logic[3:0] ALUOP_LT = 4'b0111;
	logic[3:0] ALUOP_SRL = 4'b1000;
	logic[3:0] ALUOP_SLL = 4'b1001;
	logic[3:0] ALUOP_SRA = 4'b1010;
	logic[3:0] ALUOP_XOR = 4'b1101;
	
	logic[3:0] current_alu_op;
	
	
	logic[2:0] FUNK_ADD = 3'b000;
	logic[2:0] FUNK_SUB = 3'b001;
	logic[2:0] FUNK_AND = 3'b010;
	logic[2:0] FUNK_OR = 3'b011;
	logic[2:0] FUNK_XOR = 3'b100;
	logic[2:0] FUNK_LT = 3'b101;
	logic[2:0] FUNK_SLL = 3'b110;
	logic[2:0] FUNK_SRA = 3'b111;
	
	//these logical signals help to decide how to sign extend the switches.
	//first we need to know if the last bit is a one or a zero
	logic sw_one_or_zero;
	//here is a smilar signal for the other operation we will have to do this to
	logic op2_one_or_zero;
	//this is the new switch signal
	logic extended_sw[31:0];
	//here is one for the op2
	logic extended_op2[31:0];
	//two signals (ore for sign extending 1 and 1 for zero follow).
	logic[31:0] extend_one = 32'hffff0000;
	logic[31:0] extend_zero = 32'h00000000;
	
	//here is where we caculate the switches value for op1
	always_comb begin
	   case(sw[15])
	       ONE: extended_sw = accumulator + extend_one;
	       ZERO: extended_sw = accumulator + extend_zero;
        endcase
    end;
	
	//here we determine which opperation to prefrom if btnd is pushed.
	always_comb 
	begin
	   //only do this if the output is being looked for.
           if(btnd)
           //here we have our case statements...
               case(buttons)
               // we need to determine which function to us
                   FUNK_ADD : current_alu_op = ALUOP_AND;
                   FUNK_SUB : current_alu_op = ALUOP_SUB;
                   FUNK_AND : current_alu_op = ALUOP_AND;
                   FUNK_OR : current_alu_op = ALUOP_OR;
                   FUNK_XOR : current_alu_op = ALUOP_XOR;
                   FUNK_LT : current_alu_op = ALUOP_LT;
                   FUNK_SLL : current_alu_op = ALUOP_SLL;
                   FUNK_SRA : current_alu_op = ALUOP_SRA; 
               endcase
       end
       
       
     //Instance a oneShot module to make sure that btnd only acticates accumulator
     OneShot down_btn_oneShot(.clk(clk), .rst(btnu), .in(btnd), .os(debounced_alu_control_signal));
     
     //here is the ALU, it should only update something when the accumulator lets it (see below)
     alu math_wiz(.op1(postaccumluator), .op2(extended_sw), .alu_op(current_alu_op), .zero(useless_signal), .result(preaccumulator));
     

       
     //here we have a flipflop to hold the accumulator values and activate the ALU as needed.  
     always_ff@(posedge clock)
     begin 
     // make sure that we are supposed to update right now
        if(btnu)
            // only look at the first 15 digits
           accumulator <= NOTHING;
        else
            if(debounced_alu_control_signal)
            accumulator <= preaccumulator[15:0];
     end   
     
     //this block exists sole to update the accumulator
     always_comb
     //we need to define the scope.
     begin
     // now we need to look at the end of the accumulator to see what to do
        case(accumulator[15])
	       ONE: postaccumluator = sw + extend_one;
	       ZERO: postaccumluator = sw + extend_zero;
        endcase
     end
    
    //here we have our case statements...
    
    
    // Instance alu module
    
    
    
    
endmodule
