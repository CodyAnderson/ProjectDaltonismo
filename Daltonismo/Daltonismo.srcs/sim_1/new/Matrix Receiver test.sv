`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/29/2017 12:46:26 PM
// Design Name: 
// Module Name: Matrix Receiver test
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


module MatrixReceiverTest();

logic clk = 0;
logic done, newData;
logic [7:0]dataIn;
logic [31:0]matrixOne[16];
logic [31:0]matrixTwo[16];
logic [31:0]matrixThree[16];
always #5 clk = !clk;
string testingString = "       M1 0x1 0x2 0x3 0x4 0x5 0x6 0x7 0x8 0x9 0x10 0x11 0x12 0x13 0x14 0x15 0xB00B135 M3 0x1 0x2 0x3 0x4 0x5 0x6 0x7 0x8 0x9 0x10 0x11 0x12 0x13 0x14 0x15 0xA55FACE1 M2 0x1 0x2 0x3 0x4 0x5 0x6 0x7 0x8 0x9 0x10 0x11 0x12 0x13 0x14 0x15 0xDEADBEEF \n";
logic transmit = 0;
always #30 transmit = 1;
always_ff @(posedge clk)
begin
  static integer i = 0;
  if(done && transmit && !newData)
  begin
    dataIn <= testingString[i++];
    newData <= 1;
  end
  else
  newData <= 0;
end


UartTransmit TX(clk, newData, dataIn, 
            tx, done
            );

  MatrixReceiver Receive(
        clk, tx, matrixBuffedIn,
        , ,
        matrixOne,
        matrixTwo,
        matrixThree
        );
endmodule
