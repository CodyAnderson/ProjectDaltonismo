`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/28/2017 11:36:00 AM
// Design Name: 
// Module Name: UARTTest
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

module UartTestBench;
logic clk = 0, go = 0,rx, done, newData = 0, readData = 0, ready;
logic [7:0]data = 0, dataOut;
UartTransmit UartUnderTest(clk, newData, data, rx, done);
UartReceive UartTester2(clk, readData, rx, ready, dataOut);
always #5 clk = !clk;
initial #30000 go = 1;
always @(posedge clk)
begin
  if(done && go)
  begin
    if(newData == 0)
      data <= data + 1;
    newData <= 1;
  end
  else
    newData <= 0;
end

endmodule
