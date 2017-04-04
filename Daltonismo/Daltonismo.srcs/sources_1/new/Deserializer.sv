`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: DigiPen Institute of Technology
// Engineer: Ben Nollan
//           Cody Anderson
// 
// Module Name: Deserializer
// Project Name: Daltonismo
// Target Devices: Digilent Nexys Video
// Tool Versions: Vivado 2015.4
// Description: Turns a serial stream into ten bit parallel data.
// Inputs:
// clk_mgmt   - 100Mhz clock for management.
// clk        - HDMI clock signal, 1/10 the data rate.
// clkx5      - Data clock, 1/2 data rate (uses DDR).
// reset      - Resets stuff.
// bitslip    - Tells the serializer to drop one bit (shifts data by one bit).
// delayCount - amount of delay that gets added to the data signals.
// serial     - HDMI serial data line.
// 
// Outputs:
// parallel   - The 10-bit HDMI symbol.
// 
//////////////////////////////////////////////////////////////////////////////////

module Deserializer(
    input clk_mgmt,
    input clk,
    input clkx5,
    input reset,
    input logic bitslip,
    input [4:0]delayCount,
    input serial,
    output [9:0]parallel
    );
    
    // logic clockDelay = 1;
    // always_ff@(posedge clk)
    // begin
    //   clockDelay <= ~reset;
    // end
    logic shift1;
    logic shift2;
    logic delayed;
    logic ce = 1;
    logic clkx5_inv;
    assign clkx5_inv = !clkx5;
    
    /*always_latch
    begin
      if(clkx5)
        ce = !reset;
    end*/
    always_ff@(posedge clk)
      begin
        ce <= ~reset;
      end
    
    IDELAYE2 #(
              .CINVCTRL_SEL("FALSE"),
              .DELAY_SRC("DATAIN"),
              .HIGH_PERFORMANCE_MODE("TRUE"),
              .IDELAY_TYPE("VAR_LOAD"),
              .IDELAY_VALUE(0),
              .PIPE_SEL("FALSE"),
              .REFCLK_FREQUENCY(200.0),
              .SIGNAL_PATTERN("DATA")
        )
        InputDelay (
              .DATAIN(serial),
              .IDATAIN('b0),
              .DATAOUT(delayed),
              
              .CNTVALUEOUT(),
              .C(clk_mgmt),
              .CE('b0),
              .CINVCTRL('b0),
              .CNTVALUEIN(delayCount),
              .INC('b0),
              .LD('b1),
              .LDPIPEEN('b0),
              .REGRST('b0)
        );
    
  ISERDESE2 #(
          .DATA_RATE("DDR"),
          .DATA_WIDTH(10),
          .DYN_CLKDIV_INV_EN("FALSE"),
          .DYN_CLK_INV_EN("FALSE"),
          .INIT_Q1('b0), 
          .INIT_Q2('b0),
          .INIT_Q3('b0),
          .INIT_Q4('b0),
          .INTERFACE_TYPE("NETWORKING"),
          .IOBDELAY("BOTH"),
          .NUM_CE('b1),
          .OFB_USED("FALSE"),
          .SERDES_MODE("MASTER"),
          .SRVAL_Q1('b0),
          .SRVAL_Q2('b0),
          .SRVAL_Q3('b0),
          .SRVAL_Q4('b0) 
       )
       ISERDESE2_M (
          .O(),
          .Q1(parallel[9]),
          .Q2(parallel[8]),
          .Q3(parallel[7]),
          .Q4(parallel[6]),
          .Q5(parallel[5]),
          .Q6(parallel[4]),
          .Q7(parallel[3]),
          .Q8(parallel[2]),
          .SHIFTOUT1(shift1),
          .SHIFTOUT2(shift2),
          .BITSLIP(bitslip),
          .CE1(ce),
          .CE2('b0),
          .CLKDIVP('b0),
          .CLK(clkx5),
          .CLKB(clkx5_inv),
          .CLKDIV(clk),
          .OCLK('b0), 
          .DYNCLKDIVSEL('b0),
          .DYNCLKSEL('b0),
          .D('b0),
          .DDLY(delayed),
          .OFB('b0),
          .OCLKB('b0),
          .RST(reset),
          .SHIFTIN1('b0),
          .SHIFTIN2('b0) 
       );
              
    ISERDESE2 #(
           .DATA_RATE("DDR"),
           .DATA_WIDTH(10),
           .DYN_CLKDIV_INV_EN("FALSE"),
           .DYN_CLK_INV_EN("FALSE"),
           .INIT_Q1('b0), 
           .INIT_Q2('b0),
           .INIT_Q3('b0),
           .INIT_Q4('b0),
           .INTERFACE_TYPE("NETWORKING"),
           .IOBDELAY("BOTH"),
           .NUM_CE('b1),
           .OFB_USED("FALSE"),
           .SERDES_MODE("SLAVE"),
           .SRVAL_Q1('b0),
           .SRVAL_Q2('b0),
           .SRVAL_Q3('b0),
           .SRVAL_Q4('b0) 
        )
        ISERDESE2_S (
           .O(),
           .Q1(),
           .Q2(),
           .Q3(parallel[1]),
           .Q4(parallel[0]),
           .Q5(),
           .Q6(),
           .Q7(),
           .Q8(),
           .SHIFTOUT1(),
           .SHIFTOUT2(),
           .BITSLIP(bitslip),
           .CE1(ce),
           .CE2('b0),
           .CLKDIVP('b0),
           .CLK(clkx5),
           .CLKB(clkx5_inv),
           .CLKDIV(clk),
           .OCLK('b0), 
           .DYNCLKDIVSEL('b0),
           .DYNCLKSEL('b0),
           .D('b0),
           .DDLY('b0),
           .OFB('b0),
           .OCLKB('b0),
           .RST(reset),
           .SHIFTIN1(shift1),
           .SHIFTIN2(shift2) 
        );
        
endmodule
