`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: DigiPen Institute of Technology
// Engineer: Ben Nollan
//           Cody Anderson
// 
// Module Name: HdmiClockGen
// Project Name: Daltonismo
// Target Devices: Digilent Nexys Video
// Tool Versions: Vivado 2015.4
// Description: Generates an x5 clock based on an inputted differential clock signal.
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module HdmiClockGen(
            input logic clkP,
            input logic clkN,
            output logic clk,
            output logic clkx5,
            output logic locked
    );
    
    logic clkFB, inClk, clkx5Raw;
    
  IBUFDS #(.IOSTANDARD("TMDS_33")) 
    ClkIn (    .O(inClk),    .I(clkP), .IB(clkN));
   
    MMCME2_BASE #(
            .BANDWIDTH("OPTIMIZED"),      // Jitter programming (OPTIMIZED, HIGH, LOW)
            .DIVCLK_DIVIDE(1),          // Master division value (1-106)
            .CLKFBOUT_MULT_F(5.0),        // Multiply value for all CLKOUT (2.000-64.000).
            .CLKFBOUT_PHASE(0.0),         // Phase offset in degrees of CLKFB (-360.000-360.000).
            .CLKIN1_PERIOD(1000.0/148.5), // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
            //// CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
            .CLKOUT0_DIVIDE_F(5.0),       // Divide amount for CLKOUT0 (1.000-128.000).
            .CLKOUT1_DIVIDE  (5),
            .CLKOUT2_DIVIDE  (1),
            .CLKOUT3_DIVIDE  (1),
            .CLKOUT4_DIVIDE  (1),
            .CLKOUT5_DIVIDE  (1),
            .CLKOUT6_DIVIDE  (1),
            //// CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
            .CLKOUT0_DUTY_CYCLE(0.5),
            .CLKOUT1_DUTY_CYCLE(0.5),
            .CLKOUT2_DUTY_CYCLE(0.5),
            .CLKOUT3_DUTY_CYCLE(0.5),
            .CLKOUT4_DUTY_CYCLE(0.5),
            .CLKOUT5_DUTY_CYCLE(0.5),
            .CLKOUT6_DUTY_CYCLE(0.5),
            //// CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
            .CLKOUT0_PHASE(0.0),
            .CLKOUT1_PHASE(0.0),
            .CLKOUT2_PHASE(0.0),
            .CLKOUT3_PHASE(0.0),
            .CLKOUT4_PHASE(0.0),
            .CLKOUT5_PHASE(0.0),
            .CLKOUT6_PHASE(0.0),
            .CLKOUT4_CASCADE("FALSE"),  // Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
            .REF_JITTER1(0.0),        // Reference input jitter in UI (0.000-0.999).
            .STARTUP_WAIT("FALSE")      // Delays DONE until MMCM is locked (FALSE, TRUE)
         )
         HDMIClockGen (
            //// Clock Outputs: 1-bit (each) output: User configurable clock outputs
            .CLKOUT0  (),         // 1-bit output: CLKOUT0
            .CLKOUT0B (),         // 1-bit output: Inverted CLKOUT0
            .CLKOUT1  (clk),      // 1-bit output: CLKOUT1
            .CLKOUT1B (),         // 1-bit output: Inverted CLKOUT1
            .CLKOUT2  (clkx5Raw),// 1-bit output: CLKOUT2
            .CLKOUT2B (),         // 1-bit output: Inverted CLKOUT2
            .CLKOUT3  (),         // 1-bit output: CLKOUT3
            .CLKOUT3B (),         // 1-bit output: Inverted CLKOUT3
            .CLKOUT4  (),         // 1-bit output: CLKOUT4
            .CLKOUT5  (),         // 1-bit output: CLKOUT5
            .CLKOUT6  (),         // 1-bit output: CLKOUT6
            //// Feedback Clocks: 1-bit (each) output: Clock feedback ports
            .CLKFBOUT (clkFB),  // 1-bit output: Feedback clock
            .CLKFBOUTB(),         // 1-bit output: Inverted CLKFBOUT
            //// Status Ports: 1-bit (each) output: MMCM status ports
            .LOCKED   (locked),   // 1-bit output: LOCK
            //// Clock Inputs: 1-bit (each) input: Clock input
            .CLKIN1   (inClk), // 1-bit input: Clock
            //// Control Ports: 1-bit (each) input: MMCM control ports
            .PWRDWN   ('b0),      // 1-bit input: Power-down
            .RST      ('b0),      // 1-bit input: Reset
            //// Feedback Clocks: 1-bit (each) input: Clock feedback ports
            .CLKFBIN  (clkFB)   // 1-bit input: Feedback clock
         );
         
         
         ////////////////////////////////////
              //// Force the highest speed clock 
              //// through the IO clock buffer
              //// (this is only rated for 600MHz!)
              ////////////////////////////////////-  
          BUFIO BUFIO_inst(
                 .O(clkx5), .I(clkx5Raw)
              );  
endmodule


//////////////////////////////////////////////////////////////////////////////////
// Company: DigiPen Institute of Technology
// Engineer: Ben Nollan
//           Cody Anderson
// 
// Module Name: ClockDoubler
// Project Name: Daltonismo
// Target Devices: Digilent Nexys Video
// Tool Versions: Vivado 2015.4
// Description: Doubles the 100MHz clock for use in the delay reference module.
// 
// 
//////////////////////////////////////////////////////////////////////////////////

module ClockDoubler(
            input logic clkIn,
            output logic clkOut
    );
    
    logic clkFB;

   
    MMCME2_BASE #(
            .BANDWIDTH("OPTIMIZED"),      // Jitter programming (OPTIMIZED, HIGH, LOW)
            .DIVCLK_DIVIDE(1),          // Master division value (1-106)
            .CLKFBOUT_MULT_F(8.0),        // Multiply value for all CLKOUT (2.000-64.000).
            .CLKFBOUT_PHASE(0.0),         // Phase offset in degrees of CLKFB (-360.000-360.000).
            .CLKIN1_PERIOD(1000.0/100.0), // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
            //// CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
            .CLKOUT0_DIVIDE_F(4.0),       // Divide amount for CLKOUT0 (1.000-128.000).
            .CLKOUT1_DIVIDE  (1),
            .CLKOUT2_DIVIDE  (1),
            .CLKOUT3_DIVIDE  (1),
            .CLKOUT4_DIVIDE  (1),
            .CLKOUT5_DIVIDE  (1),
            .CLKOUT6_DIVIDE  (1),
            //// CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
            .CLKOUT0_DUTY_CYCLE(0.5),
            .CLKOUT1_DUTY_CYCLE(0.5),
            .CLKOUT2_DUTY_CYCLE(0.5),
            .CLKOUT3_DUTY_CYCLE(0.5),
            .CLKOUT4_DUTY_CYCLE(0.5),
            .CLKOUT5_DUTY_CYCLE(0.5),
            .CLKOUT6_DUTY_CYCLE(0.5),
            //// CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
            .CLKOUT0_PHASE(0.0),
            .CLKOUT1_PHASE(0.0),
            .CLKOUT2_PHASE(0.0),
            .CLKOUT3_PHASE(0.0),
            .CLKOUT4_PHASE(0.0),
            .CLKOUT5_PHASE(0.0),
            .CLKOUT6_PHASE(0.0),
            .CLKOUT4_CASCADE("FALSE"),  // Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
            .REF_JITTER1(0.0),        // Reference input jitter in UI (0.000-0.999).
            .STARTUP_WAIT("FALSE")      // Delays DONE until MMCM is locked (FALSE, TRUE)
         )
         ClockDoubler (
            //// Clock Outputs: 1-bit (each) output: User configurable clock outputs
            .CLKOUT0  (),         // 1-bit output: CLKOUT0
            .CLKOUT0B (),         // 1-bit output: Inverted CLKOUT0
            .CLKOUT1  (clkOut),      // 1-bit output: CLKOUT1
            .CLKOUT1B (),         // 1-bit output: Inverted CLKOUT1
            .CLKOUT2  (),// 1-bit output: CLKOUT2
            .CLKOUT2B (),         // 1-bit output: Inverted CLKOUT2
            .CLKOUT3  (),         // 1-bit output: CLKOUT3
            .CLKOUT3B (),         // 1-bit output: Inverted CLKOUT3
            .CLKOUT4  (),         // 1-bit output: CLKOUT4
            .CLKOUT5  (),         // 1-bit output: CLKOUT5
            .CLKOUT6  (),         // 1-bit output: CLKOUT6
            //// Feedback Clocks: 1-bit (each) output: Clock feedback ports
            .CLKFBOUT (clkFB),  // 1-bit output: Feedback clock
            .CLKFBOUTB(),         // 1-bit output: Inverted CLKFBOUT
            //// Status Ports: 1-bit (each) output: MMCM status ports
            .LOCKED   (),   // 1-bit output: LOCK
            //// Clock Inputs: 1-bit (each) input: Clock input
            .CLKIN1   (clkIn), // 1-bit input: Clock
            //// Control Ports: 1-bit (each) input: MMCM control ports
            .PWRDWN   ('b0),      // 1-bit input: Power-down
            .RST      ('b0),      // 1-bit input: Reset
            //// Feedback Clocks: 1-bit (each) input: Clock feedback ports
            .CLKFBIN  (clkFB)   // 1-bit input: Feedback clock
         );
         
endmodule
