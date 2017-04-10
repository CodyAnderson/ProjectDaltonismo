`timescale 1ns / 1ps





module VectorMatrixMultiplier(
      clk,
      vectorIn,
      
      matrix,
      
      vectorOut
      );
    parameter MATRIX_COLUMNS = 4;
    parameter MATRIX_ROWS = 4;
    parameter NUMBER_WIDTH = 16;
    parameter NUMBER_DECIMALS = 8;
    
    parameter PRODUCT_WIDTH = 32;
    parameter PRODUCT_DECIMALS = 16;
    
    //the clk
    input clk;
    
    //The Input Vector
    input [NUMBER_WIDTH - 1:0] vectorIn[MATRIX_COLUMNS];
    
    //The Matrix
    input [NUMBER_WIDTH - 1:0] matrix[MATRIX_ROWS * MATRIX_COLUMNS];
    
    //The Output Vector
    output logic [PRODUCT_WIDTH - 1:0] vectorOut[MATRIX_ROWS];
    
    logic [NUMBER_WIDTH - 1:0] tempValues[MATRIX_ROWS * MATRIX_COLUMNS];

    genvar curRow;
    genvar curCol;

    generate
      for(curRow = 0; curRow < MATRIX_ROWS; curRow++)
      begin
        for(curCol = 0; curCol < MATRIX_COLUMNS; curCol++)
        begin
          SignedFixedPointMultiplier #(.NUMBER_WIDTH(NUMBER_WIDTH), .MULTIPLIER_WIDTH(NUMBER_WIDTH), .PRODUCT_WIDTH(PRODUCT_WIDTH),
          .NUMBER_DECIMALS(NUMBER_DECIMALS), .MULTIPLIER_DECIMALS(NUMBER_DECIMALS), .PRODUCT_DECIMALS(PRODUCT_DECIMALS)) 
          Mult(clk, vectorIn[curCol], matrix[curRow * MATRIX_ROWS + curCol], tempValues[curRow * MATRIX_ROWS + curCol]);
        end
      end
    endgenerate

    always_comb
    begin
      for(integer curRow = 0; curRow < MATRIX_ROWS; curRow++)
      begin
        vectorOut[curRow] = 0;
        for(integer curCol = 0; curCol < MATRIX_COLUMNS; curCol++)
        begin
          vectorOut += tempValues[curRow * MATRIX_ROWS + curCol];
        end
      end
    end
      
endmodule

//////////////////////////////////////////////////////////////////////////////////
// Company: DigiPen Institute of Technology
// Engineer: Ben Nollan
//           Cody Anderson
// 
// Module Name: Multiplier
// Project Name: Daltonismo
// Target Devices: Digilent Nexys Video
// Tool Versions: Vivado 2015.4
// Description: Multiplies a Number by a number.
//
// 
//////////////////////////////////////////////////////////////////////////////////

//Listen here, children:
//Don't code with sleep deprivation



//module Multiplier(
//      clk,
//      number,
//      multiplier,
//      product
//      );
//    
//    parameter NUMBER_WIDTH = 1;
//    parameter MULTIPLIER_WIDTH = 1;
//    parameter PRODUCT_WIDTH = NUMBER_WIDTH;
//    
//    input clk;
//    input [NUMBER_WIDTH - 1:0]number;
//    input [MULTIPLIER_WIDTH - 1:0]multiplier;
//    output logic [PRODUCT_WIDTH - 1:0]product;
//    
//    logic [NUMBER_WIDTH - 1:0]numberTemp;
//    logic [MULTIPLIER_WIDTH - 1:0]multiplierTemp;
//    logic [PRODUCT_WIDTH - 1:0]productTemp;
//    
//    //Counts which bit of the multiplier we're currently operating on
//    logic [8:0] currentBit = 0; 
//    
//    //*This* is where the magic happens
//    always_ff @ (posedge clk)
//        begin
//            if(currentBit < MULTIPLIER_WIDTH - 1)
//                begin
//                
//                    currentBit <= currentBit + 1;
//                    
//                    
//                    if(currentBit == 0)
//                        begin
//                            if(multiplierTemp[0] == 1'b1)
//                                begin
//                                    productTemp <= numberTemp;
//                                end
//                            else
//                                begin
//                                    productTemp <= 0;
//                                end
//                        end
//                        
//                    else
//                        begin
//                            if(multiplierTemp[currentBit] == 1'b1)
//                                begin
//                                    productTemp <= productTemp + (numberTemp <<currentBit);
//                                end
//                            else
//                                begin
//                                    productTemp <= productTemp;
//                                end
//                        end
//                end
//            else //This should be the last bit
//                begin
//                    //so Ima gonna clock in the in data and out clok the out data
//                    numberTemp <= number;
//                    multiplierTemp <= multiplier;
//                    if(multiplierTemp[currentBit] == 1'b1)
//                        begin
//                            product <= productTemp + (numberTemp <<currentBit);
//                        end
//                    else
//                        begin
//                            product <= productTemp;
//                        end
//                
//                    currentBit <= 0;
//                end
//        end
//    
//endmodule

module ThreeByThreeMatrixMultiplier(
      clk,
      Xin, Yin, Zin,
      
      A, B, C,
      D, E, F,
      G, H, I,
      
      Xout, Yout, Zout
      );
      
    parameter NUMBER_WIDTH = 16;
    parameter NUMBER_DECIMALS = 8;
    
    parameter PRODUCT_WIDTH = 32;
    parameter PRODUCT_DECIMALS = 16;
    
    //the clk
    input clk;
    
    //XYZ inputs
    input [NUMBER_WIDTH - 1:0] Xin;
    input [NUMBER_WIDTH - 1:0] Yin;
    input [NUMBER_WIDTH - 1:0] Zin;

    
    
    
    //ABC_DEF_GHI Elements of the matrix multiplication
    input [NUMBER_WIDTH - 1:0] A;
    input [NUMBER_WIDTH - 1:0] B;
    input [NUMBER_WIDTH - 1:0] C;
    //cont'd
    input [NUMBER_WIDTH - 1:0] D;
    input [NUMBER_WIDTH - 1:0] E;
    input [NUMBER_WIDTH - 1:0] F;
    //cont'd
    input [NUMBER_WIDTH - 1:0] G;
    input [NUMBER_WIDTH - 1:0] H;
    input [NUMBER_WIDTH - 1:0] I;
    
    
    
    
    //XYZ outputs
    output logic [PRODUCT_WIDTH - 1:0] Xout;
    output logic [PRODUCT_WIDTH - 1:0] Yout;
    output logic [PRODUCT_WIDTH - 1:0] Zout;
    
    
    
    
    //A temporary place to hold onto the results
        //of the ABC_DEF_GHI operations
    logic [PRODUCT_WIDTH - 1:0] AX;
    logic [PRODUCT_WIDTH - 1:0] BY;
    logic [PRODUCT_WIDTH - 1:0] CZ;
    //cont'd
    logic [PRODUCT_WIDTH - 1:0] DX;
    logic [PRODUCT_WIDTH - 1:0] EY;
    logic [PRODUCT_WIDTH - 1:0] FZ;
    //cont'd
    logic [PRODUCT_WIDTH - 1:0] GX;
    logic [PRODUCT_WIDTH - 1:0] HY;
    logic [PRODUCT_WIDTH - 1:0] IZ;
    
    
    
    
    //Where all the magic happens
    SignedFixedPointMultiplier #(.NUMBER_WIDTH(NUMBER_WIDTH), .MULTIPLIER_WIDTH(NUMBER_WIDTH), .PRODUCT_WIDTH(PRODUCT_WIDTH),
    .NUMBER_DECIMALS(NUMBER_DECIMALS), .MULTIPLIER_DECIMALS(NUMBER_DECIMALS), .PRODUCT_DECIMALS(PRODUCT_DECIMALS)) 
    AMult(clk, Xin, A, AX);
    SignedFixedPointMultiplier #(.NUMBER_WIDTH(NUMBER_WIDTH), .MULTIPLIER_WIDTH(NUMBER_WIDTH), .PRODUCT_WIDTH(PRODUCT_WIDTH),
    .NUMBER_DECIMALS(NUMBER_DECIMALS), .MULTIPLIER_DECIMALS(NUMBER_DECIMALS), .PRODUCT_DECIMALS(PRODUCT_DECIMALS)) 
    BMult(clk, Yin, B, BY);
    SignedFixedPointMultiplier #(.NUMBER_WIDTH(NUMBER_WIDTH), .MULTIPLIER_WIDTH(NUMBER_WIDTH), .PRODUCT_WIDTH(PRODUCT_WIDTH),
    .NUMBER_DECIMALS(NUMBER_DECIMALS), .MULTIPLIER_DECIMALS(NUMBER_DECIMALS), .PRODUCT_DECIMALS(PRODUCT_DECIMALS)) 
    CMult(clk, Zin, C, CZ);
    
    SignedFixedPointMultiplier #(.NUMBER_WIDTH(NUMBER_WIDTH), .MULTIPLIER_WIDTH(NUMBER_WIDTH), .PRODUCT_WIDTH(PRODUCT_WIDTH),
    .NUMBER_DECIMALS(NUMBER_DECIMALS), .MULTIPLIER_DECIMALS(NUMBER_DECIMALS), .PRODUCT_DECIMALS(PRODUCT_DECIMALS)) 
    DMult(clk, Xin, D, DX);
    SignedFixedPointMultiplier #(.NUMBER_WIDTH(NUMBER_WIDTH), .MULTIPLIER_WIDTH(NUMBER_WIDTH), .PRODUCT_WIDTH(PRODUCT_WIDTH),
    .NUMBER_DECIMALS(NUMBER_DECIMALS), .MULTIPLIER_DECIMALS(NUMBER_DECIMALS), .PRODUCT_DECIMALS(PRODUCT_DECIMALS)) 
    EMult(clk, Yin, E, EY);
    SignedFixedPointMultiplier #(.NUMBER_WIDTH(NUMBER_WIDTH), .MULTIPLIER_WIDTH(NUMBER_WIDTH), .PRODUCT_WIDTH(PRODUCT_WIDTH),
    .NUMBER_DECIMALS(NUMBER_DECIMALS), .MULTIPLIER_DECIMALS(NUMBER_DECIMALS), .PRODUCT_DECIMALS(PRODUCT_DECIMALS)) 
    FMult(clk, Zin, F, FZ);
    
    SignedFixedPointMultiplier #(.NUMBER_WIDTH(NUMBER_WIDTH), .MULTIPLIER_WIDTH(NUMBER_WIDTH), .PRODUCT_WIDTH(PRODUCT_WIDTH),
    .NUMBER_DECIMALS(NUMBER_DECIMALS), .MULTIPLIER_DECIMALS(NUMBER_DECIMALS), .PRODUCT_DECIMALS(PRODUCT_DECIMALS)) 
    GMult(clk, Xin, G, GX);
    SignedFixedPointMultiplier #(.NUMBER_WIDTH(NUMBER_WIDTH), .MULTIPLIER_WIDTH(NUMBER_WIDTH), .PRODUCT_WIDTH(PRODUCT_WIDTH),
    .NUMBER_DECIMALS(NUMBER_DECIMALS), .MULTIPLIER_DECIMALS(NUMBER_DECIMALS), .PRODUCT_DECIMALS(PRODUCT_DECIMALS)) 
    HMult(clk, Yin, H, HY);
    SignedFixedPointMultiplier #(.NUMBER_WIDTH(NUMBER_WIDTH), .MULTIPLIER_WIDTH(NUMBER_WIDTH), .PRODUCT_WIDTH(PRODUCT_WIDTH),
    .NUMBER_DECIMALS(NUMBER_DECIMALS), .MULTIPLIER_DECIMALS(NUMBER_DECIMALS), .PRODUCT_DECIMALS(PRODUCT_DECIMALS)) 
    IMult(clk, Zin, I, IZ);
    
    
    
    
    //Let's just clock in the magic...
    always_ff @ (posedge clk)
        begin
            Xout <= AX + BY + CZ;
            Yout <= DX + EY + FZ;
            Zout <= GX + HY + IZ;
        end
      
endmodule

//If there is only one neagtive number, it has to be the first number
module SignedFixedPointMultiplier(
      clk,
      number,
      multiplier,
      product
      );
          
    parameter NUMBER_WIDTH = 4;
    parameter MULTIPLIER_WIDTH = 4;
    parameter PRODUCT_WIDTH = NUMBER_WIDTH + MULTIPLIER_WIDTH;
    
    parameter NUMBER_DECIMALS = 2;
    parameter MULTIPLIER_DECIMALS = 2;
    parameter PRODUCT_DECIMALS = NUMBER_DECIMALS + MULTIPLIER_DECIMALS;
    parameter DECIMAL_WIDTH = NUMBER_DECIMALS + MULTIPLIER_DECIMALS - PRODUCT_DECIMALS;
    parameter TOTAL_PRODUCT_WIDTH = PRODUCT_WIDTH + DECIMAL_WIDTH;
    
    input clk;
    input [NUMBER_WIDTH - 1:0]number;
    input [MULTIPLIER_WIDTH - 1:0]multiplier;
    output logic[TOTAL_PRODUCT_WIDTH - 1:0]product;
    
    //Here's the pipeline, so to speak
    logic [NUMBER_WIDTH - 1:0]numberPipe [MULTIPLIER_WIDTH:0];
    logic [MULTIPLIER_WIDTH - 1:0]multiplierPipe [MULTIPLIER_WIDTH:0];
    logic [TOTAL_PRODUCT_WIDTH - 1:0]productPipe [MULTIPLIER_WIDTH:0];
    logic [0:0]signBitPipe [MULTIPLIER_WIDTH:0];
    
    //Out
    //assign product = productPipe[0] >> (NUMBER_DECIMALS + MULTIPLIER_DECIMALS - PRODUCT_DECIMALS);
    
    //In
    //assign numberPipe[MULTIPLIER_WIDTH + 1] = number;
    //assign multiplierPipe[MULTIPLIER_WIDTH + 1] = multiplier;
    //assign productPipe[MULTIPLIER_WIDTH + 1] = 0;
    
    
    always_ff @ (posedge clk)
    begin
        //Transfer finished data out
        if(signBitPipe[0][0] == 1'b1)
            begin
                product <= -(productPipe[0] >> (DECIMAL_WIDTH));
            end
        else
            begin
                product <= (productPipe[0] >> (DECIMAL_WIDTH));
            end
        
        
        
        //Transfer new data in
        //If the number in is negative
            //and the multiplier in is negative
        if(number[NUMBER_WIDTH - 1] == 1'b1 && multiplier[MULTIPLIER_WIDTH - 1] == 1'b1)
            begin
                numberPipe[MULTIPLIER_WIDTH] <= -number;
                multiplierPipe[MULTIPLIER_WIDTH] <= -multiplier;
                
                productPipe[MULTIPLIER_WIDTH] <= 0;
                
                signBitPipe[MULTIPLIER_WIDTH][0] <= 1'b0;
            end
        else if(number[NUMBER_WIDTH - 1] == 1'b1 && multiplier[MULTIPLIER_WIDTH - 1] == 1'b0)
            begin
                numberPipe[MULTIPLIER_WIDTH] <= -number;
                multiplierPipe[MULTIPLIER_WIDTH] <= multiplier;
                
                productPipe[MULTIPLIER_WIDTH] <= 0;
                
                signBitPipe[MULTIPLIER_WIDTH][0] <= 1'b1;
            end
         else if(number[NUMBER_WIDTH - 1] == 1'b0 && multiplier[MULTIPLIER_WIDTH - 1] == 1'b1)
             begin                                                                            
                 numberPipe[MULTIPLIER_WIDTH] <= number;                                     
                 multiplierPipe[MULTIPLIER_WIDTH] <= -multiplier;                             
                                                                                              
                 productPipe[MULTIPLIER_WIDTH] <= 0;                                          
                 
                 signBitPipe[MULTIPLIER_WIDTH][0] <= 1'b1;
             end
         else
                 begin                                                                            
                     numberPipe[MULTIPLIER_WIDTH] <= number;                                     
                     multiplierPipe[MULTIPLIER_WIDTH] <= multiplier;                             
                                                                                                  
                     productPipe[MULTIPLIER_WIDTH] <= 0;                                          
                                                                                                  
                     signBitPipe[MULTIPLIER_WIDTH][0] <= 1'b0;                                        
                 end                                                                              
        
        
        
        
        //Loop transfer
        
        for(int i = MULTIPLIER_WIDTH; i > 0 ; i = i - 1)
            begin
                //Push each number into the next number down
                //while also doing some multiplication, but only if you wanna
                multiplierPipe[i-1] <= (multiplierPipe[i]);
                numberPipe[i-1] <= (numberPipe[i]);
                signBitPipe[i-1] <= (signBitPipe[i]);
                
                
                //If the multiplier is positive and the current bit is set
                if(multiplierPipe[i][i-1] == 1'b1)
                    begin
                        productPipe[i-1] <= (productPipe[i] << 1) + numberPipe[i];
                    end
                //If the bit isn't in a place that we need to add to the product
                else
                    begin
                        productPipe[i-1] <= (productPipe[i] << 1);
                    end
            end
    end
    
endmodule


module FixedPointMultiplier(
      clk,
      number,
      multiplier,
      product
      );
          
    parameter NUMBER_WIDTH = 4;
    parameter MULTIPLIER_WIDTH = 4;
    parameter PRODUCT_WIDTH = NUMBER_WIDTH;
    
    parameter NUMBER_DECIMALS = 2;
    parameter MULTIPLIER_DECIMALS = 2;
    parameter PRODUCT_DECIMALS = NUMBER_DECIMALS;
    
    input clk;
    input [NUMBER_WIDTH - 1:0]number;
    input [MULTIPLIER_WIDTH - 1:0]multiplier;
    output [PRODUCT_WIDTH - 1:0]product;
    
    logic [NUMBER_WIDTH - 1:0]numberPipe [MULTIPLIER_WIDTH + 1:0];
    logic [MULTIPLIER_WIDTH - 1:0]multiplierPipe [MULTIPLIER_WIDTH + 1:0];
    logic [PRODUCT_WIDTH - 1:0]productPipe [MULTIPLIER_WIDTH + 1:0];
    
    //Out
    assign product = productPipe[0] >> (NUMBER_DECIMALS + MULTIPLIER_DECIMALS - PRODUCT_DECIMALS);
    
    //In
    assign numberPipe[MULTIPLIER_WIDTH + 1] = number;
    assign multiplierPipe[MULTIPLIER_WIDTH + 1] = multiplier;
    assign productPipe[MULTIPLIER_WIDTH + 1] = 0;
    
    
    always_ff @ (posedge clk)
    begin
        //Output
        
        for(int i = MULTIPLIER_WIDTH + 1; i > 0 ; i = i - 1)
            begin
                //Push each number into the next number up
                //while also doing some multiplication
                multiplierPipe[i-1] <= (multiplierPipe[i]);
                numberPipe[i-1] <= (numberPipe[i]);
                if(multiplierPipe[i][i-1] == 1'b1)
                    begin
                        productPipe[i-1] <= (productPipe[i] << 1) + (numberPipe[i]);
                    end
                else
                    begin
                        productPipe[i-1] <= (productPipe[i] << 1);
                    end
            end
    end
    
endmodule


module Multiplier(
      clk,
      number,
      multiplier,
      product
      );
    
    parameter NUMBER_WIDTH = 2;
    parameter MULTIPLIER_WIDTH = 2;
    parameter PRODUCT_WIDTH = NUMBER_WIDTH;
    
    input clk;
    input [NUMBER_WIDTH - 1:0]number;
    input [MULTIPLIER_WIDTH - 1:0]multiplier;
    output [PRODUCT_WIDTH - 1:0]product;
    
    logic [NUMBER_WIDTH - 1:0]numberPipe [MULTIPLIER_WIDTH + 1:0];
    logic [MULTIPLIER_WIDTH - 1:0]multiplierPipe [MULTIPLIER_WIDTH + 1:0];
    logic [PRODUCT_WIDTH - 1:0]productPipe [MULTIPLIER_WIDTH + 1:0];
    
    //Out
    assign product = productPipe[0];
    
    //In
    assign numberPipe[MULTIPLIER_WIDTH + 1] = number;
    assign multiplierPipe[MULTIPLIER_WIDTH + 1] = multiplier;
    assign productPipe[MULTIPLIER_WIDTH + 1] = 0;
    
    
    always_ff @ (posedge clk)
    begin
        //This only needs to loop... wait... all the times
        //Say 4 bits
        
        //Input
        //
        //CLOCK=> shifted by 1
        //
        //CLOCK=> shifted by 2
        //
        //CLOCK=> shifted by 3
        //
        
        
        
        //Output
        
        //This was try #1 which only allowed numbers to be up to the size of the input numbers
            //So the product would be modulo'd by the smallest ammount of bits
                //This is NOT the desired behaviour 
        //for(int i = 0; i < MULTIPLIER_WIDTH + 1; i = i + 1)
        //    begin
        //        //Push each number into the next number up
        //        //while also doing some multiplication
        //        multiplierPipe[i+1] <= (multiplierPipe[i] >> 1);
        //        numberPipe[i+1] <= (numberPipe[i] << 1);
        //        if(multiplierPipe[i][0] == 1'b1)
        //            begin
        //                productPipe[i+1] <= productPipe[i] + (numberPipe[i]);
        //            end
        //        else
        //            begin
        //                productPipe[i+1] <= productPipe[i];
        //            end
        //    end
            
        for(int i = MULTIPLIER_WIDTH + 1; i > 0 ; i = i - 1)
            begin
                //Push each number into the next number up
                //while also doing some multiplication
                multiplierPipe[i-1] <= (multiplierPipe[i]);
                numberPipe[i-1] <= (numberPipe[i]);
                if(multiplierPipe[i][i-1] == 1'b1)
                    begin
                        productPipe[i-1] <= (productPipe[i] << 1) + (numberPipe[i]);
                    end
                else
                    begin
                        productPipe[i-1] <= (productPipe[i] << 1);
                    end
            end
    end
    
endmodule
