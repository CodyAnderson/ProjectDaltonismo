`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: DigiPen Institute of Technology
// Engineer: Ben Nollan
//           Cody Anderson
// 
// Module Name: Serializer
// Project Name: Daltonismo
// Target Devices: Digilent Nexys Video
// Tool Versions: Vivado 2015.4
// Description: Inputs HDMI, performs color filtering, outputs HDMI.
//
// sw[6]: enables/disables symbol passthrough, useful for setting delay timing.
// sw[5]: starts symbol alignment process.
// sw[4:0]: adjusts delay timing for all three channels.
// btnC: changes current filter.
// led[0]: on if monitor is connected.
// led[1]: on if HDMI clock generator is operating properly.
// led[2]: on if symbols are valid for blue channel.
// led[3]: on if symbols are valid for green channel.
// led[4]: on if symbols are valid for red channel.
// 
//////////////////////////////////////////////////////////////////////////////////


module top_module(
    input logic clk,
    input logic [7:0]sw,
    input logic ja0,
    output logic uart_rx_out,
    //input logic btnC,
    
    //HDMI in
    inout logic hdmi_rx_cec,
    output logic hdmi_rx_hpa,
    inout logic hdmi_rx_scl,
    inout logic hdmi_rx_sda,
    output logic hdmi_rx_txen,
    input logic hdmi_rx_clk_n,
    input logic hdmi_rx_clk_p,
    input logic [2:0]hdmi_rx_n,
    input logic [2:0]hdmi_rx_p,

    // HDMI out
    inout logic hdmi_tx_cec,
    output logic hdmi_tx_clk_n,
    output logic hdmi_tx_clk_p,
    input logic hdmi_tx_hpd,
    inout logic hdmi_tx_rscl,
    inout logic hdmi_tx_rsda,
    output logic [2:0]hdmi_tx_p,
    output logic [2:0]hdmi_tx_n,
    
    output logic [4:0]led
    );

logic uart_tx_in;
assign uart_tx_in = ja0;


  logic clkfb_2;
  logic reset;
  assign reset = !locked;
  assign hdmi_tx_rsda = 'bZ;
  assign hdmi_tx_cec  = 'bZ;
  assign hdmi_tx_rscl = 'b1;
  assign hdmi_rx_hpa = 'b1;
  assign hdmi_rx_txen = 'b1;
  assign led[0] = !hdmi_tx_hpd;
  
  
  edid_rom I2C(clk, hdmi_rx_scl, hdmi_rx_sda);
  
  
  logic HdmiClk;
  logic HdmiClkx5;
  HdmiClockGen HDMIclk(hdmi_rx_clk_p, hdmi_rx_clk_n, HdmiClk, HdmiClkx5, locked);               
  
  assign led[1] = locked;
  
  
  logic clk_200;
  ClockDoubler Mhz200(clk, clk_200 ); //Used as a reference clock for IDELAY Control
  IDELAYCTRL IDELAYCTRL(
            .RDY(),    // 1-bit output: Ready output
            .REFCLK(clk_200), // 1-bit input:  Reference clock input
            .RST('b0)      // 1-bit input:  Active high reset input
        );

  logic redValidSymbol;
  logic greenValidSymbol;
  logic blueValidSymbol;
  assign led[4] = redValidSymbol;
  assign led[3] = greenValidSymbol;
  assign led[2] = blueValidSymbol;
  logic [2:0]syncIn;
  logic [7:0]redDataIn;
  logic [7:0]greenDataIn;
  logic [7:0]blueDataIn; 
  logic [9:0]blueSymbolIn; 
  logic [9:0]greenSymbolIn; 
  logic [9:0]redSymbolIn; 
  HdmiInputChannel BlueInput (clk, HdmiClk, HdmiClkx5, hdmi_rx_p[0], hdmi_rx_n[0], reset, blueValidSymbol, syncIn, blueDataIn , blueSymbolIn);
  
  HdmiInputChannel GreenInput(clk, HdmiClk, HdmiClkx5, hdmi_rx_p[1], hdmi_rx_n[1], reset, greenValidSymbol,      , greenDataIn, greenSymbolIn);
  
  HdmiInputChannel RedInput  (clk, HdmiClk, HdmiClkx5, hdmi_rx_p[2], hdmi_rx_n[2], reset, redValidSymbol,        , redDataIn  , redSymbolIn);
  
  logic [2:0]syncOut;
  logic [7:0]redDataOut;
  logic [7:0]greenDataOut;
  logic [7:0]blueDataOut;  
  Filter SuperFilter(HdmiClk,clk, sw[2:0], uart_tx_in, uart_rx_out, syncIn, redDataIn, greenDataIn, blueDataIn, syncOut, redDataOut, greenDataOut, blueDataOut);
  
  logic useSymbol;
  assign useSymbol = 1'b1; //!sw[6];
  HdmiOutputChannel BlueOutput (HdmiClk, HdmiClkx5, hdmi_tx_p[0], hdmi_tx_n[0], reset, syncOut            , blueDataOut,  blueSymbolIn,  useSymbol);
  
  HdmiOutputChannel GreenOutput(HdmiClk, HdmiClkx5, hdmi_tx_p[1], hdmi_tx_n[1], reset, {2'b00, syncOut[0]}, greenDataOut, greenSymbolIn, useSymbol);
  
  HdmiOutputChannel RedOutput  (HdmiClk, HdmiClkx5, hdmi_tx_p[2], hdmi_tx_n[2], reset, {2'b00, syncOut[0]}, redDataOut,   redSymbolIn,   useSymbol);
  

        
          
      
 
  Serializer SerialClock(HdmiClk,HdmiClkx5,'b1110000011,reset,serOutClock);
  
  
  ////////////////////
  //// Output Buffers
  ////////////////////
  
  OBUFDS #(.IOSTANDARD("TMDS_33"),.SLEW("FAST")) 
    ClkOut   (.O(hdmi_tx_clk_p),.OB(hdmi_tx_clk_n),.I(serOutClock));
endmodule
