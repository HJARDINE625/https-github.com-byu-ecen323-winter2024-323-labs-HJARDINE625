`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/18/2023 11:59:05 PM
// Design Name: 
// Module Name: alu
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


module alu(op1, op2, alu_op, result, zero);
    input wire logic [31:0] op1;
    input wire logic [31:0] op2;
    input wire logic [3:0] alu_op;
    output logic [31:0] result;
    output logic zero;
    
    
    // the following two signals are constants used to asses if the zero flag was raised
    localparam NOT_ZERO = 0;
    localparam YES_ZERO = 1;
    
    //here are all the constants for the ALU operations
	localparam[3:0] ALUOP_AND = 4'b0000;
	localparam[3:0] ALUOP_OR = 4'b0001;
	localparam[3:0] ALUOP_ADD = 4'b0010;
	localparam[3:0] ALUOP_SUB = 4'b0110;
	localparam[3:0] ALUOP_LT = 4'b0111;
	localparam[3:0] ALUOP_SRL = 4'b1000;
	localparam[3:0] ALUOP_SLL = 4'b1001;
	localparam[3:0] ALUOP_SRA = 4'b1010;
	localparam[3:0] ALUOP_XOR = 4'b1101;
	
	// the following code assigns all the result return value to the correct operation 
	always_comb begin
	//here are the case statements
	   case(alu_op)
	       //These should be rather self-explainitory
	       ALUOP_AND: result = op1 & op2;
	       ALUOP_OR: result = op1 | op2;
	       ALUOP_ADD: result = op1 + op2;
	       ALUOP_SUB: result = op1 - op2;
	       ALUOP_LT: result = ($signed(op1) < $signed(op2)) ? 32'd1 : 32'd0;
	       ALUOP_SRL: result = op1 >> op2[4:0]; 
	       ALUOP_SLL: result = op1 << op2[4:0]; 
	       ALUOP_SRA: result = $unsigned($signed(op1) >>> op2[4:0]); 
	       ALUOP_XOR: result = op1 ^ op2; 
	       default: result = op1 + op2;
    endcase
    end;
    
    // We also need this module just to make sure the zero flag is properly raised.
    always_comb begin
    //It seems like we always want to know if we got zero so
        if(result == 32'd0)
        //if so raise the zero flage
            zero = YES_ZERO;
        else
        //it is not zero so
            zero = NOT_ZERO;
//    //first make sure we were working with the comparitior opperation
//        if (alu_op == ALUOP_LT)
//        //now see if it gave a zero or not
//            if(result == 32'd1)
//                zero = NOT_ZERO;
//                //if so raise the zero flag
//            else
//                zero = YES_ZERO;
//         //here we check if we need to have a zero for non-testing functions.
//         else
//            zero = YES_ZERO;
    end
endmodule
