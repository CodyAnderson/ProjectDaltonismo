`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/09/2017 09:20:38 PM
// Design Name: 
// Module Name: CVDCompensation
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


module CVDCompensation(
    input clk,
    input enable,
    input [2:0] syncIn,
    input [7:0] redIn,
    input [7:0] greenIn,
    input [7:0] blueIn,
    input [31:0] matrixInOne[16],
    input [31:0] matrixInTwo[16],
    output logic [2:0] syncOut,
    output logic [7:0] redOut,
    output logic [7:0] greenOut,
    output logic [7:0] blueOut
    );
    
    parameter NUM_WID = 32;
    parameter NUM_DEC = 16;
    
    parameter PROD_WID = 32;
    parameter PROD_DEC = 16;
    
    logic [31:0] CLAMPred;
    logic [31:0] CLAMPgreen;
    logic [31:0] CLAMPblue;
  
    logic [31:0] preCLAMPred;
    logic [31:0] preCLAMPgreen;
    logic [31:0] preCLAMPblue;
    
    logic [31:0] delayedRedIn;
    logic [31:0] delayedGreenIn;
    logic [31:0] delayedBlueIn;
  
    logic [31:0] delayedAgainRedIn;
    logic [31:0] delayedAgainGreenIn;
    logic [31:0] delayedAgainBlueIn;
    
    logic [31:0] diffRed;
    logic [31:0] diffGreen;
    logic [31:0] diffBlue;
    
    logic [31:0] delayedDiffRed;
    logic [31:0] delayedDiffGreen;
    logic [31:0] delayedDiffBlue;
    
    logic [31:0] HSVred;
    logic [31:0] HSVgreen;
    logic [31:0] HSVblue;
    
    ThreeByThreeMatrixMultiplier
      #(.NUMBER_WIDTH(NUM_WID), .NUMBER_DECIMALS(NUM_DEC),
      .PRODUCT_WIDTH(PROD_WID), .PRODUCT_DECIMALS(PROD_DEC))
    Daltonismonster(
      clk,
      
      {8'b0,redIn,16'b0},
      {8'b0,greenIn,16'b0},
      {8'b0,blueIn,16'b0},
  
      //matrixOut[0], matrixOut[1], matrixOut[2],
      //matrixOut[3], matrixOut[4], matrixOut[5],
      //matrixOut[6], matrixOut[7], matrixOut[8],
      //7365, 58170, 0,
      //7365, 58170 , 0,
      //262, -262, 65536,
      matrixInOne[0], matrixInOne[1], matrixInOne[2],
      matrixInOne[4], matrixInOne[5], matrixInOne[6],
      matrixInOne[8], matrixInOne[9], matrixInOne[10],
  
      diffRed, diffGreen, diffBlue
      );
    
    ThreeByThreeMatrixMultiplier
      #(.NUMBER_WIDTH(NUM_WID), .NUMBER_DECIMALS(NUM_DEC),
      .PRODUCT_WIDTH(PROD_WID), .PRODUCT_DECIMALS(PROD_DEC))
    CorrectionMatrix(
      clk,
      
      delayedRedIn-diffRed,
      delayedGreenIn-diffGreen,
      delayedBlueIn-diffBlue,
  
      //0, 0, 0,
      //45875, 65536, 0,
      //45875, 0, 65536,
      // 65536,0,0,
      // 0,65536,0,
      // 0,0,65536,
      matrixInTwo[0], matrixInTwo[1], matrixInTwo[2],
      matrixInTwo[4], matrixInTwo[5], matrixInTwo[6],
      matrixInTwo[8], matrixInTwo[9], matrixInTwo[10],
  
      preCLAMPred, preCLAMPgreen, preCLAMPblue
      );
    
    DelaySignal #(.DATA_WIDTH(3),.DELAY_CYCLES(75)) SyncDelay(clk,syncIn, syncOut);
  
    DelaySignal #(.DATA_WIDTH(32),.DELAY_CYCLES(36)) RedDelay(clk,{8'b0,redIn,16'b0}, delayedRedIn);
    DelaySignal #(.DATA_WIDTH(32),.DELAY_CYCLES(36)) GreenDelay(clk,{8'b0,greenIn,16'b0}, delayedGreenIn);
    DelaySignal #(.DATA_WIDTH(32),.DELAY_CYCLES(36)) BlueDelay(clk,{8'b0,blueIn,16'b0}, delayedBlueIn);
    
    DelaySignal #(.DATA_WIDTH(32),.DELAY_CYCLES(36)) RedDelayAGAIN(clk,delayedRedIn, delayedAgainRedIn);
    DelaySignal #(.DATA_WIDTH(32),.DELAY_CYCLES(36)) GreenDelayAGAIN(clk,delayedGreenIn, delayedAgainGreenIn);
    DelaySignal #(.DATA_WIDTH(32),.DELAY_CYCLES(36)) BlueDelayAGAIN(clk,delayedBlueIn, delayedAgainBlueIn);
    
    DelaySignal #(.DATA_WIDTH(32),.DELAY_CYCLES(36)) RedDiffDelay(clk,diffRed, delayedDiffRed);
    DelaySignal #(.DATA_WIDTH(32),.DELAY_CYCLES(36)) GreenDiffDelay(clk,diffGreen, delayedDiffGreen);
    DelaySignal #(.DATA_WIDTH(32),.DELAY_CYCLES(36)) BlueDiffDelay(clk,diffBlue, delayedDiffBlue);
    
    always_ff @(posedge clk)
      begin
      
        if(enable)
          begin
            CLAMPred <= preCLAMPred + delayedAgainRedIn;
            CLAMPgreen <= preCLAMPgreen + delayedAgainGreenIn;
            CLAMPblue <= preCLAMPblue + delayedAgainBlueIn;
          end
        else
          begin
            CLAMPred <= delayedAgainRedIn;
            CLAMPgreen <= delayedAgainGreenIn;
            CLAMPblue <= delayedAgainBlueIn;
          end
        
        ////CLAMP RED
        //If the red number is beigger than 255
        if(CLAMPred[31] != 1'b1 && CLAMPred[31:16] > 255)
            begin
                HSVred[23:16] <= 255;
            end
        //If the red number is negative
        else if(CLAMPred[31])
            begin
                HSVred[23:16] <= 0;
            end
        //Otherwise
        else
            begin
                HSVred <= CLAMPred;
            end
            
        ////CLAMP GREEN
        //If the green number is beigger than 255
        if(CLAMPgreen[31] != 1'b1 && CLAMPgreen[31:16] > 255)
            begin
                HSVgreen[23:16] <= 255;
            end
        //If the green number is negative
        else if(CLAMPgreen[31])
            begin
                HSVgreen[23:16] <= 0;
            end
        //Otherwise
        else
            begin
                HSVgreen <= CLAMPgreen;
            end
            
        ////CLAMP BLUE
        //If the blue number is beigger than 255
        if(CLAMPblue[31] != 1'b1 && CLAMPblue[31:16] > 255)
            begin
                HSVblue[23:16] <= 255;
            end
        //If the blue number is negative
        else if(CLAMPblue[31])
            begin
                HSVblue[23:16] <= 0;
            end
        //Otherwise
        else
            begin
                HSVblue <= CLAMPblue;
            end
            
            
            
        redOut <= HSVred[23:16];
        greenOut <= HSVgreen[23:16];
        blueOut <= HSVblue[23:16];
        
        
        
      end
endmodule


module CVDSimulation(
    input clk,
    input enable,
    input [2:0] syncIn,
    input [7:0] redIn,
    input [7:0] greenIn,
    input [7:0] blueIn,
    input [31:0] matrixIn[16],
    output logic [2:0] syncOut,
    output logic [7:0] redOut,
    output logic [7:0] greenOut,
    output logic [7:0] blueOut
    );
    
    parameter NUM_WID = 32;
    parameter NUM_DEC = 16;
    
    parameter PROD_WID = 32;
    parameter PROD_DEC = 16;
    
    logic [31:0] delayedRedIn;
    logic [31:0] delayedGreenIn;
    logic [31:0] delayedBlueIn;
    
    logic [31:0] CLAMPred;
    logic [31:0] CLAMPgreen;
    logic [31:0] CLAMPblue;
  
    logic [31:0] preCLAMPred;
    logic [31:0] preCLAMPgreen;
    logic [31:0] preCLAMPblue;
    
    logic [31:0] HSVred;
    logic [31:0] HSVgreen;
    logic [31:0] HSVblue;
    
    DelaySignal #(.DATA_WIDTH(3),.DELAY_CYCLES(36)) SyncDelay(clk,syncIn, syncOut);
  
    DelaySignal #(.DATA_WIDTH(32),.DELAY_CYCLES(36)) RedDelay(clk,{8'b0,redIn,16'b0}, delayedRedIn);
    DelaySignal #(.DATA_WIDTH(32),.DELAY_CYCLES(36)) GreenDelay(clk,{8'b0,greenIn,16'b0}, delayedGreenIn);
    DelaySignal #(.DATA_WIDTH(32),.DELAY_CYCLES(36)) BlueDelay(clk,{8'b0,blueIn,16'b0}, delayedBlueIn);
    
    
    ThreeByThreeMatrixMultiplier
      #(.NUMBER_WIDTH(NUM_WID), .NUMBER_DECIMALS(NUM_DEC),
      .PRODUCT_WIDTH(PROD_WID), .PRODUCT_DECIMALS(PROD_DEC))
    CorrectionMatrix(
      clk,
      
      {8'b0,redIn,16'b0},
      {8'b0,greenIn,16'b0},
      {8'b0,blueIn,16'b0},
  
      matrixIn[0], matrixIn[1], matrixIn[2],
      matrixIn[4], matrixIn[5], matrixIn[6],
      matrixIn[8], matrixIn[9], matrixIn[10],
  
      preCLAMPred, preCLAMPgreen, preCLAMPblue
      );
    
    always_ff @(posedge clk)
      begin
      
        if(enable)
          begin
            CLAMPred <= preCLAMPred;
            CLAMPgreen <= preCLAMPgreen;
            CLAMPblue <= preCLAMPblue;
          end
        else
          begin
            CLAMPred <= delayedRedIn;
            CLAMPgreen <= delayedGreenIn;
            CLAMPblue <= delayedBlueIn;
          end
        
        ////CLAMP RED
        //If the red number is beigger than 255
        if(CLAMPred[31] != 1'b1 && CLAMPred[31:16] > 255)
            begin
                HSVred[23:16] <= 255;
            end
        //If the red number is negative
        else if(CLAMPred[31])
            begin
                HSVred[23:16] <= 0;
            end
        //Otherwise
        else
            begin
                HSVred <= CLAMPred;
            end
            
        ////CLAMP GREEN
        //If the green number is beigger than 255
        if(CLAMPgreen[31] != 1'b1 && CLAMPgreen[31:16] > 255)
            begin
                HSVgreen[23:16] <= 255;
            end
        //If the green number is negative
        else if(CLAMPgreen[31])
            begin
                HSVgreen[23:16] <= 0;
            end
        //Otherwise
        else
            begin
                HSVgreen <= CLAMPgreen;
            end
            
        ////CLAMP BLUE
        //If the blue number is beigger than 255
        if(CLAMPblue[31] != 1'b1 && CLAMPblue[31:16] > 255)
            begin
                HSVblue[23:16] <= 255;
            end
        //If the blue number is negative
        else if(CLAMPblue[31])
            begin
                HSVblue[23:16] <= 0;
            end
        //Otherwise
        else
            begin
                HSVblue <= CLAMPblue;
            end
            
            
            
        redOut <= HSVred[23:16];
        greenOut <= HSVgreen[23:16];
        blueOut <= HSVblue[23:16];
        
        
        
      end
    
endmodule