`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////////
// Company: DigiPen Institute of Technology
// Engineer: Ben Nollan
//           Cody Anderson
// 
// Module Name: Filter
// Project Name: Daltonismo
// Target Devices: Digilent Nexys Video
// Tool Versions: Vivado 2015.4
// Description: Applies a filter to the video data that is passed in.
// 
// 
///////////////////////////////////////////////////////////////////////////////////


module Filter(
    input clk,
    input clk100Mhz,
    input [2:0]switcher,
    input uart_tx_in,
    output uart_rx_out,
    input [2:0] syncIn,
    input [7:0] redIn,
    input [7:0] greenIn,
    input [7:0] blueIn,
    output logic [2:0] syncOut,
    output logic [7:0] redOut,
    output logic [7:0] greenOut,
    output logic [7:0] blueOut
    );
  logic [2:0]filterStage;
  logic [8:0] frames;

  
    
  
  logic [31:0] HSVred,HSVgreen,HSVblue;
  logic [31:0] CLAMPred,CLAMPgreen,CLAMPblue;
  //RGBtoHSV filt1(clk, redIn, greenIn, blueIn, hue, sat, val);
  //Daltonizer colorCorrect(clk, hue, sat, val, correctedSat, correctedVal);
  
  logic [31:0] matrixOne[16];
  logic [31:0] matrixOneBuffered[16];
  logic [31:0] matrixTwo[16];
  logic [31:0] matrixTwoBuffered[16];
  logic [31:0] matrixThree[16];
  logic [31:0] matrixThreeBuffered[16];
  logic [2:0]matrixDone;
  logic [2:0]matrixBuffedIn = 3'b0;
  MatrixReceiver Jamal(clk100Mhz, uart_tx_in, matrixBuffedIn, matrixDone, uart_rx_out, matrixIn);
  
  always_ff@(posedge clk)
  begin
    if(matrixDone[0] && syncIn[2])
    begin
      matrixBuffedIn[0] <= 1;
      matrixOneBuffered <= matrixOne;
    end
    else
      matrixBuffedIn[0] <= 0;
    if(matrixDone[1] && syncIn[2])
    begin
      matrixBuffedIn[1] <= 1;
      matrixTwoBuffered <= matrixTwo;
    end
    else
      matrixBuffedIn[1] <= 0;
    if(matrixDone[2] && syncIn[2])
    begin
      matrixBuffedIn[2] <= 1;
      matrixThreeBuffered <= matrixThree;
    end
    else
      matrixBuffedIn[2] <= 0;
  end

  logic [7:0] satRGB;
  logic [7:0] valRGB;
  //HSVtoRGB filt2(clk, hueDelayed,satRGB, valRGB, HSVred, HSVgreen, HSVblue);
  //Daltonize filt1(clk, {8'b0,redIn,16'b0}, {8'b0,greenIn,16'b0}, {8'b0,blueIn,16'b0}, HSVred, HSVgreen, HSVblue, matrix);
  parameter NUM_WID = 32;
    parameter NUM_DEC = 16;
    
    parameter PROD_WID = 32;
    parameter PROD_DEC = 16;

    ThreeByThreeMatrixMultiplier
    #(.NUMBER_WIDTH(NUM_WID), .NUMBER_DECIMALS(NUM_DEC),
    .PRODUCT_WIDTH(PROD_WID), .PRODUCT_DECIMALS(PROD_DEC))
    Daltonismonster(
    clk,
    {8'b0,redIn,16'b0}, {8'b0,greenIn,16'b0}, {8'b0,blueIn,16'b0},
    
     matrixOut[0], matrixOut[1], matrixOut[2],
     matrixOut[3], matrixOut[4], matrixOut[5],
     matrixOut[6], matrixOut[7], matrixOut[8],
    // 65536,0,0,
    // 0,65536,0,
    // 0,0,65536,
    
    CLAMPred, CLAMPgreen, CLAMPblue
    );
    
  DelaySignal #(.DATA_WIDTH(3),.DELAY_CYCLES(36)) SyncDelay(clk,syncIn, syncOut);
  logic [2:0]currentFilter;
  always@(posedge clk)
  begin
  
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
  
    case(currentFilter)
      0:begin
        redOut <= HSVred[23:16];
        greenOut <= HSVgreen[23:16];
        blueOut <= HSVblue[23:16];
      end
      1:begin
        redOut <= (HSVred[23:16] + HSVgreen[23:16])/2;
        greenOut <= (HSVred[23:16] + HSVgreen[23:16])/2;
        blueOut <= HSVblue[23:16];
      end
      2:begin
        redOut <= HSVred[23:16];
        greenOut <= HSVgreen[23:16];
        blueOut <= HSVblue[23:16];
      end
      3:begin
        redOut <= (HSVred[23:16] + HSVgreen[23:16])/2;
        greenOut <= (HSVred[23:16] + HSVgreen[23:16])/2;
        blueOut <= HSVblue[23:16];
      end
      4:begin
        redOut <= ~HSVred[23:16];
        greenOut <= ~HSVgreen[23:16];
        blueOut <= ~HSVblue[23:16];
      end
      default:begin
        redOut <= HSVred[23:16];
        greenOut <= HSVgreen[23:16];
        blueOut <= HSVblue[23:16];
      end
      endcase
  end
  
  
  logic [19:0]count;
  logic lSwitchState;
  logic [15:0]hPos;
  logic [15:0]hSize;
  logic [15:0]vPos;
  logic [15:0]vSize;
  always@(posedge clk)
  begin
    if(!syncOut[0])
    begin
      hPos <= hPos + 1;
    end
    if(syncOut[0] && syncOut[1] && hPos)
    begin
      vPos <= vPos + 1;
      hSize <= hPos;
      hPos <= 0;
    end
    if(syncOut[0] && syncOut[2] && vPos)
    begin
      if(frames  >= 9'h17F)
          frames <= 0;
      else
        frames <= frames + 1;
      vSize <= vPos;
      vPos <= 0;
    end
      
    case(switcher)
      0:begin
        currentFilter <= switcher;
      end
      1:begin
        currentFilter <= switcher;
      end
      2:begin
        currentFilter <= switcher;
      end
      3:begin
        currentFilter <= switcher;
      end
      4:begin
        currentFilter[2] <= 0;
        if(hPos < hSize / 2)
          currentFilter[0] <= 0;
        else
          currentFilter[0] <= 1;
          
        if(vPos < vSize / 2)
          currentFilter[1] <= 0;
        else
          currentFilter[1] <= 1;
      end
      6:begin
        currentFilter <= 4;
      end
      default:begin
        currentFilter <= 0;
      end
    endcase
    
  end
    
endmodule


module Daltonizer(
       input clk, 
       input [8:0]hue, 
       input [7:0]sat, 
       input [7:0]val,
       output [7:0]correctedSat,
       output [7:0]correctedVal
       );
       
  logic [7:0]satDivisor;
  logic [7:0]valDivisor;
  always_comb
  begin
    if(hue < 64)
      satDivisor = 128 - hue;
    else if(hue > 320)
      satDivisor = hue - 256;
    else
      satDivisor = 64;
      
    if(hue >= 64 && hue < 128)
      valDivisor = hue;
    else if(hue >= 128 && hue < 192)
      valDivisor = 256 - hue;
    else
      valDivisor = 64;
  end
  Divider #(.DIVIDEND_WIDTH(14), .DIVIDER_WIDTH(8), .QUOTIENT_WIDTH(8)) 
             DaltSatDivide(clk, (sat * 64), satDivisor, correctedSat);
  Divider #(.DIVIDEND_WIDTH(14), .DIVIDER_WIDTH(8), .QUOTIENT_WIDTH(8)) 
             DaltValDivide(clk, (val * 64), valDivisor, correctedVal);
endmodule

module RGBtoHSV(
    input  logic       clk,
    input  logic [7:0] red,
    input  logic [7:0] green,
    input  logic [7:0] blue,
    output logic [8:0] hue,
    output logic [7:0] sat,
    output logic [7:0] val
    );
    
    logic [13:0]hueDividend;
    logic [7:0]hueDivisor;
    logic [6:0]huequotient;
    
    logic [15:0]satDividend;
    logic [7:0]satDivisor;
    logic [7:0]satquotient;
    
    logic [7:0]delayVal;
    logic [2:0]delayedSwitch;
    
    logic [2:0]switcher = 0;
    
  always@(posedge clk)
  begin
    logic [7:0]delta;
    logic [7:0]max;
    logic [7:0]mid;
    logic [7:0]min;
    
    //0-63 red to yellow
    // 320-383 magenta to red
    // 64 - 128 yellow to green
    // 128-192 green to cyan
    // 192-256 cyan to blue
    // 256-320 blue to magenta

    if(red >= green && red >= blue)
    begin
      if(green > blue)
      begin //0-63 red to yellow
        mid = green;
        min = blue;
        switcher <= 0;
      end
      else
      begin // 320-383 magenta to red
        mid = blue;
        min = green;
        switcher <= 1;
      end
      max = red;
    end
    else if(green >= red && green >= blue)
    begin
      if(red > blue)
      begin  // 64 - 128 yellow to green
        min = blue;
        mid = red;
        switcher <= 2;
      end
      else
      begin  // 128-192 green to cyan
        min = red;
        mid = blue;
        switcher <= 3;
      end
      max = green;      
    end
    else
    begin
      if(green > red)
      begin  // 192-256 cyan to blue
        min = red;
        mid = green;
        switcher <= 4;
      end
      else
      begin  // 256-320 blue to magenta
        min = green;
        mid = red;
        switcher <= 5;
      end
      max = blue;
    end
    
    hueDividend <= ((mid - min) * 64);
    hueDivisor <= max-min;
    
    satDividend <= ((max-min) * 255);
    satDivisor <= max;
    
    delayVal <= max;
    
    case(delayedSwitch)
      0:      hue <=       huequotient;//   0- 63 red to yellow
      1:      hue <= 383 - huequotient;// 320-383 magenta to red
      2:      hue <= 127 - huequotient;//  64-127 yellow to green
      3:      hue <= 128 + huequotient;// 128-191 green to cyan
      4:      hue <= 255 - huequotient;// 192-255 cyan to blue
      default:hue <= 256 + huequotient;// 256-319 blue to magenta
    endcase
    
  end
  //hue <= ((mid - min) * 64) / (max-min);
  Divider #(.DIVIDEND_WIDTH(14), .DIVIDER_WIDTH(8), .QUOTIENT_WIDTH(7)) 
      HueDivide(clk ,hueDividend, hueDivisor, huequotient);
  //sat <= ((max-min) * 255) / max;
  Divider #(.DIVIDEND_WIDTH(16), .DIVIDER_WIDTH(8), .QUOTIENT_WIDTH(8)) 
      SatDivide(clk, satDividend, satDivisor, sat);
      
  DelaySignal #(.DATA_WIDTH(8),.DELAY_CYCLES(8)) ValueDelay(clk,delayVal, val);
  DelaySignal #(.DATA_WIDTH(3),.DELAY_CYCLES(7)) SwitchDelay(clk,switcher, delayedSwitch);
  
endmodule

module pipelineRGBtoHSV(
    input  logic       clk,
    input  logic [7:0] red,
    input  logic [7:0] green,
    input  logic [7:0] blue,
    output logic [8:0] hue,
    output logic [7:0] sat,
    output logic [7:0] val
    );
    
  always@(posedge clk)
  begin
  
    logic [7:0]delta;
    
    logic [7:0]offset;
    logic [7:0]color1;
    logic [7:0]color2;
    logic [7:0]color3;
    
    if(red == green && green == blue)
    begin
      hue <= 0;
      sat <= 0;
      val <= red;
    end
    else
    begin
      if(red >= green && red >= blue)
      begin
        offset = 0;
        color1 = red;
        if(green > blue)
        begin
          color2 = green;
          color3 = blue;
          //delta = red - blue;
          //hue <= ((green - blue) * 64) / delta; //0-64 red to yellow
        end
        else
        begin
          color2 = blue;
          color3 = green;
          //delta = red - green;
          //hue <= 383 - ((blue - green) * 64) / delta; // 320-383 magenta to red
        end
         //val <= red;
         //sat <= (delta * 255) / red;
        
      end
      else if(green >= red && green >= blue)
      begin
        offset = 128;
        color1 = green;
        if(red > blue)
        begin
          color2 = red;
          color3 = blue;
          //delta = green - blue;
          //hue <= 128 - ((red - blue) * 64) / delta;	// 64 - 128 yellow to green
        end
        else
        begin
          color2 = blue;
          color3 = red;
          //delta = green - red;
          //hue <= 128 + ((blue - red) * 64) / delta;	// 128-192 green to cyan
        end
        //val <= green;
        //sat <= (delta * 255) / green;
        
      end
      else
      begin
        offset = 256;
        color1 = blue; //Blue is the brightest channel for the cases herin
        if(green > red)
        begin
          color2 = green;
          color3 = red;
          //delta = blue - red;
          //hue <= 256 - ((green - red) * 64) / delta;  // 192-256 cyan to blue
        end
        else
        begin
          color2 = red;
          color3 = green;
          //delta = blue - green;
          //hue <= 256 + ((red - green) * 64) / delta;  // 256-320 blue to magenta
        end
        //val <= blue;
        //sat <= (delta * 255) / blue;
        
      end
      
      delta = color1 - color3;
      hue <= offset + ((color2 - color3) * 64) / delta;
      val <= color1;
      sat <= (delta * 255) / color1;
      
    end
  end
endmodule

module HSVtoRGB(
    input  logic       clk,
    input  logic [8:0] hue,
    input  logic [7:0] sat,
    input  logic [7:0] val,
    output logic [7:0] red,
    output logic [7:0] green,
    output logic [7:0] blue
    );
    
  always@(posedge clk)
  begin
    logic [6:0] f;
    logic [7:0] p;
    logic [7:0] q;
    logic [7:0] t;
    if (sat == 0)
    begin
      // achromatic (grey)
      red <= val;
      green <= val;
      blue <= val;
    end
    else
    begin
      f = hue[5:0];      // factorial part of h
      p = (val * (255 - sat))/256;
      q = (val * (255*64 - sat * f))/(256*64);
      t = (val * (255*64 - sat * (64 - f)))/(256*64);
      case (hue[8:6])
      0:begin
          red <= val;
          green <= t;
          blue <= p;
        end
      1:begin
          red <= q;
          green <= val;
          blue <= p;
        end
      2:begin
          red <= p;
          green <= val;
          blue <= t;
        end
      3:begin
          red <= p;
          green <= q;
          blue <= val;
        end
      4:begin
          red <= t;
          green <= p;
          blue <= val;
        end
      default: begin
          red <= val;
          green <= p;
          blue <= q;
        end
      endcase
    end
  end
    
endmodule