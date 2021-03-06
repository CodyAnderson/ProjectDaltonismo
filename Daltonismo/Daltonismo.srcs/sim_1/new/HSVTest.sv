`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/29/2016 09:44:36 PM
// Design Name: 
// Module Name: HSVTest
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


module HSVTest(

    );
    
    logic [8:0] hue;
    logic [7:0] sat;
    logic [7:0] val;
    logic [7:0] HSVred,HSVgreen,HSVblue;
    logic [7:0] redIn = 200;
    logic [7:0] greenIn = 200;
    logic [7:0] blueIn = 200;
    logic clk = 1;
    logic [3:0]counter = 1;
    always
    begin
    #5 clk = !clk;
    end
    
    always@(posedge clk)
    begin
      counter <= counter + 1;
      if(counter == 0)
        greenIn <= greenIn + 10;
    end
    
      RGBtoHSV filt1(clk, redIn, greenIn, blueIn, hue, sat, val);
      HSVtoRGB filt2(clk, hue,sat, val, HSVred, HSVgreen, HSVblue);
endmodule
