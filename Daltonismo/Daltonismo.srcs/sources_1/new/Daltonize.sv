`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/22/2017 10:32:20 PM
// Design Name: 
// Module Name: Daltonize
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


module Daltonize(input clk, input [31:0] RedIn, [31:0] GreenIn, [31:0] BlueIn,input MatrixA, output [31:0] RedOut, [31:0] GreenOut, [31:0] BlueOut);

    parameter NUM_WID = 32;
    parameter NUM_DEC = 16;
    
    parameter PROD_WID = 32;
    parameter PROD_DEC = 16;
    
    logic [NUM_WID - 1:0] MatrixA [8:0];

    ThreeByThreeMatrixMultiplier
    #(.NUMBER_WIDTH(NUM_WID), .NUMBER_DECIMALS(NUM_DEC),
    .PRODUCT_WIDTH(PROD_WID), .PRODUCT_DECIMALS(PROD_DEC))
    Daltonismonster(
    clk,
    RedIn, GreenIn, BlueIn,
    
    MatrixA[0], MatrixA[1], MatrixA[2],
    MatrixA[3], MatrixA[4], MatrixA[5],
    MatrixA[6], MatrixA[7], MatrixA[8],
    
    RedOut, GreenOut, BlueOut
    );
    
    //sign MatrixA[0] = A;
    //sign MatrixA[1] = B;
    //sign MatrixA[2] = C;
    //           
    //sign MatrixA[3] = D;
    //sign MatrixA[4] = E;
    //sign MatrixA[5] = F;
    //           
    //sign MatrixA[6] = G;
    //sign MatrixA[7] = H;
    //sign MatrixA[8] = I;
       
endmodule
