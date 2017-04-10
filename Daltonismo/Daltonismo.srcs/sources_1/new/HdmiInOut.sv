`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: DigiPen Institute of Technology
// Engineer: Ben Nollan
//           Cody Anderson
// 
// Module Name: HdmiInputChannel
// Project Name: Daltonismo
// Target Devices: Digilent Nexys Video
// Tool Versions: Vivado 2015.4
// Description: Handles the reception of one of the channels of HDMI
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module HdmiInputChannel(
    input clk100,
    input clk,
    input clkx5,
    input hdmi_rx_p,
    input hdmi_rx_n,
    input reset,
    output logic dataValid,
    output logic [2:0] syncOut,
    output [7:0] dataOut
    );
    
      ///////////////
     // Input Buffer
    ///////////////
    logic SerIn;
    IBUFDS #(.IOSTANDARD("TMDS_33")) 
        SerialBufIn  (  .O(serIn),   .I(hdmi_rx_p),  .IB(hdmi_rx_n));
        
      ///////////////////////////
     //  InputDelay/Deserializer
    ///////////////////////////
    logic slip;
    logic [4:0]autoDelay;
    logic [9:0]symbol;
    Deserializer Deserial(clk100,clk,clkx5,reset,slip,autoDelay,serIn,symbol);
    
      ///////////////////////
     //  TMDS Symbol Decoder
    ///////////////////////
    logic symbolGood;
    TmdsDecoder Decode(clk,symbol,symbolGood,dataOut,syncOut);
    
      //////////////////////////////
     //  Automatic Symbol Alignment
    //////////////////////////////
    AutoAlign SymbolAlign(clk, reset, symbolGood, slip, autoDelay, dataValid);

    
    
endmodule



//////////////////////////////////////////////////////////////////////////////////
// Company: DigiPen Institute of Technology
// Engineer: Ben Nollan
//           Cody Anderson
// 
// Module Name: HdmiInputChannel
// Project Name: Daltonismo
// Target Devices: Digilent Nexys Video
// Tool Versions: Vivado 2016.4
// Description: Handles alignment and delay of one of the HDMI signals.
// 
// 
//////////////////////////////////////////////////////////////////////////////////
module AutoAlign(input clk, reset, symbolGood, output logic slip, [4:0]delay, logic dataValid);
  logic [23:0]goodCount;
  logic [3:0]bitSlips;
  logic [2:0]validWait;
  logic oneExtra;
  
  always@(posedge clk)
  begin
    if(reset)
    begin
      delay <= 0;
      bitSlips <= 0;
    end

    if(bitSlips == 11) //If all alignments have been tried, increase signal delay.
    begin
      delay <= delay + 1;
      bitSlips <= 0;
    end
    if(validWait == 0) //If waited for things to settle.
    begin
      if(symbolGood == 0) //If the current symbol is invalid.
      begin
        slip <= 1; //Perform one bitslip.
        bitSlips <= bitSlips + 1; //Increase the count of bitslips.
      end
    end //if(validWait == 0)
    else 
      slip <= 0;
    validWait <= validWait + 1;
    
    if(symbolGood) //Count the number of good symbols.
    begin
      if(goodCount < 24'hFFFFFF)
        goodCount <= goodCount + 1;
      else
        dataValid <= 1; // Assume the data is valid if 16 million symbols are valid.
    end
    else //If symbol is invalid
    begin
      dataValid <= 0; //Data isn't valid
      goodCount <= 0;
      oneExtra <= 0;
    end

    if(dataValid && !oneExtra && !validWait) //Adds one more delay to fix some instability.
    begin
      delay <= delay + 1;
      oneExtra <= 1;
    end

    
  end //always@(posedge clk)
endmodule



//////////////////////////////////////////////////////////////////////////////////
// Company: DigiPen Institute of Technology
// Engineer: Ben Nollan
//           Cody Anderson
// 
// Module Name: HdmiOutputChannel
// Project Name: Daltonismo
// Target Devices: Digilent Nexys Video
// Tool Versions: Vivado 2015.4
// Description: Handles the process of outputting one HDMI channel.
// 
// 
//////////////////////////////////////////////////////////////////////////////////

module HdmiOutputChannel(
    input clk,
    input clkx5,
    output hdmi_tx_p,
    output hdmi_tx_n,
    input reset,
    input [2:0] syncs,
    input [7:0] dataIn
    );
    
    ///////////////
   // Tmds Encoder
  ///////////////
  logic [9:0]encodedSym;
  TmdsEncoder EncodeBlue(clk,dataIn,encodedSym,syncs);
  

    /////////////
   // Serializer
  /////////////
  Serializer SerialOut(clk,clkx5,encodedSym,reset,serOut);


    ////////////////
   // Output Buffer
  ////////////////  
  OBUFDS #(.IOSTANDARD("TMDS_33"),.SLEW("FAST")) 
    SerialBufOut  (.O(hdmi_tx_p), .OB(hdmi_tx_n), .I(serOut));  
    
endmodule
