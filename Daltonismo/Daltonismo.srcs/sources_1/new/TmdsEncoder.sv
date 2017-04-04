`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: DigiPen Institute of Technology
// Engineer: Ben Nollan
//           Cody Anderson
// 
// Module Name: TmdsEncoder
// Project Name: Daltonismo
// Target Devices: Digilent Nexys Video
// Tool Versions: Vivado 2015.4
// Description: Encodes 8 bits of data into 10 bit tmds packets
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module TmdsEncoder(
          input logic clk,
          input logic [7:0] dataIn,
          output logic [9:0] tmdsOut,
          input logic [2:0] syncs
          );
           
          
  logic [8:0]xored;
  assign xored[0] = dataIn[0];
  assign xored[1] = dataIn[1] ^ xored[0];
  assign xored[2] = dataIn[2] ^ xored[1];
  assign xored[3] = dataIn[3] ^ xored[2];
  assign xored[4] = dataIn[4] ^ xored[3];
  assign xored[5] = dataIn[5] ^ xored[4];
  assign xored[6] = dataIn[6] ^ xored[5];
  assign xored[7] = dataIn[7] ^ xored[6];
  assign xored[8] = 'b1;
  
  logic [8:0]xnored;
  assign xnored[0] = dataIn[0];
  assign xnored[1] = dataIn[1] ~^ xnored[0];
  assign xnored[2] = dataIn[2] ~^ xnored[1];
  assign xnored[3] = dataIn[3] ~^ xnored[2];
  assign xnored[4] = dataIn[4] ~^ xnored[3];
  assign xnored[5] = dataIn[5] ~^ xnored[4];
  assign xnored[6] = dataIn[6] ~^ xnored[5];
  assign xnored[7] = dataIn[7] ~^ xnored[6];
  assign xnored[8] = 'b0;
  
  logic [4:0]ones;
  always_comb 
  begin
    ones = 0;  
    foreach(dataIn[i]) 
      ones += dataIn[i];
  end
                 
  logic [8:0]minimized;
  always_comb //Figure out whether to keep the xored or xnored data
  begin
    if((ones > 4) || ((ones == 4) && dataIn[0] == 0))
      minimized = xnored;
    else
      minimized = xored;
  end
  
  logic [7:0]dcBalance; //Running sum of balance of ones and zeros
  initial 
  begin
  dcBalance = 127;
  tmdsOut = 0;
  end
  
  logic [4:0]minOnes;
  always_comb
  begin
    minOnes = 0;
    foreach(minimized[i])
      minOnes += minimized[i];
  end
                        
  always@(posedge clk)
  begin
    if(syncs[0]) //if in blank region
    begin
      case(syncs[2:1])
        0: tmdsOut <= 'b1101010100;
        1: tmdsOut <= 'b0010101011;
        2: tmdsOut <= 'b0101010100;
        3: tmdsOut <= 'b1010101011;
      endcase
    end
    else //if not in blank region
    begin
      if(((minOnes > 4)&& dcBalance[7])||((minOnes < 4) && !dcBalance[7])) //if the signal is getting too positive
      begin
        tmdsOut <= {1'b1, minimized[8], ~minimized[7:0]}; //only invert the data bits
        dcBalance <= (dcBalance + (8 - minOnes)) - 4;
      end
      else //if the signal is getting too negative
      begin
        tmdsOut <= {1'b0, minimized[8:0]};
        dcBalance <= (dcBalance + minOnes) - 4;
      end
    end
  end
          
endmodule
