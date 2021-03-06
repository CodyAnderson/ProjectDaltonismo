`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////
// Company: DigiPen Institute of Technology
// Engineer: Ben Nollan
//           Cody Anderson
// 
// Module Name: UartTransmit
// Project Name: Daltonismo
// Target Devices: Digilent Nexys Video
// Tool Versions: Vivado 2016.4
// Description: Transmits a byte of data using the UART protocol.
// Inputs:
//  clk - internal reference clock
//  newData - set high for at least one clock cycle to start transmission
//  dataIn - byte of data that will be transmitted
//  
// Outputs:
//  tx - the UART transmission pin
//  done - signaling if the data has finished sending
// 
///////////////////////////////////////////////////////////////////////////////

module UartTransmit(input clk, newData, [7:0]dataIn, 
            output logic tx = 1, done
            );

parameter BAUD_RATE = 2_000_000; //Transmitting serial speed (commonly 9600).
parameter CLOCK_SPEED = 100_000_000;  //Internal clock speed (usually 100Mhz).


logic [26:0]divider = 0;
logic transmitting;
logic[9:0] transmitReg = 0;
assign done = !transmitting;
assign transmitting = |(transmitReg);

always_ff@(posedge clk)
begin
  

  //if module is not sending and new data has been loaded in
  if(newData && transmitting == 0)
  begin
      // Loads the transmitter with a UART packet.
    transmitReg <= {1'b1, dataIn, 1'b0};
  end
  //if module is currently transmitting
  if(transmitting && divider < CLOCK_SPEED/BAUD_RATE - 1)
    divider <= divider + 1;
  else
  begin
    divider <= 0;
    if(transmitReg != 0)
    begin
      //Transmit the least significant bit and shift by one.
      tx <= transmitReg[0];
      transmitReg <= transmitReg >> 1;
    end
  end
end

endmodule





///////////////////////////////////////////////////////////////////////////////
// Company: DigiPen Institute of Technology
// Engineer: Ben Nollan
//           Cody Anderson
// 
// Module Name: UartReceive
// Project Name: Daltonismo
// Target Devices: Digilent Nexys Video
// Tool Versions: Vivado 2016.4
// Description: Receives a byte of data using the UART protocol.
// Inputs:
//  clk - internal reference clock
//  readData - Set high to indicate that the current byte has been read.
//  rx - the UART reception pin.
//  
// Outputs:
//  ready - Goes high when a new byte has been read.
//  dataOut - the most current data byte that has been read.
// 
///////////////////////////////////////////////////////////////////////////////

module UartReceive(input clk, readData, rx,  
            output logic ready = 0, [7:0]dataOut
            );

parameter BAUD_RATE = 2_000_000; //Transmitting serial speed (commonly 9600).
parameter CLOCK_SPEED = 100_000_000;  //Internal clock speed (usually 100Mhz).
typedef enum logic[1:0] {LOOK4START,WAIT2READ,READ} ReceptionStages;
logic [26:0]divider = 0;
logic [2:0]prevReceive = ~3'b0;
logic [8:0]internalData;
ReceptionStages stage = LOOK4START;
always_ff@(posedge clk)
begin
  //Keeps track of previous values of rx for detecting the start bit.
  prevReceive <= {prevReceive[1:0],rx};
  if(readData)
    ready <= 0;
  case(stage)
      //checks if the rx line has transitioned from high to low for the start bit.
      //prevReceive used to be one bit wide but was expanded to remove false starts.
    LOOK4START:if(prevReceive == 3'b100 && !rx)
      begin
        stage <= WAIT2READ;
        internalData <= ~8'b0;
          //Delays for half a period to get to the middle of the data bit.
        divider <= (CLOCK_SPEED/BAUD_RATE)/2 + 3;
      end
        //Waits for one period to get to the next bit.
    WAIT2READ:begin
      divider <= divider + 1;
      if(divider > CLOCK_SPEED/BAUD_RATE-3)
        stage <= READ;
    end
      //Reads in one bit, bitshifting the rest
    READ:begin    
      divider <= 0;
        //Data has all been read in when the start bit (0) is the least significant.
      if(internalData[0])
      begin
        internalData <= {rx,internalData[7:1]};
        stage <= WAIT2READ;
      end
      else
      begin
        dataOut <= {rx,internalData[7:1]};
        ready <= 1;
        stage <= LOOK4START;
      end
    end
    default:stage <= LOOK4START;
  endcase
end
endmodule





///////////////////////////////////////////////////////////////////////////////
// Company: DigiPen Institute of Technology
// Engineer: Ben Nollan
//           Cody Anderson
// 
// Module Name: MatrixReceiver
// Project Name: Daltonismo
// Target Devices: Digilent Nexys Video
// Tool Versions: Vivado 2016.4
// Description: Receives a 3x3 matrix using the UART protocol.
// Inputs:
//  clk - internal reference clock
//  rx - the UART reception pin.
//  matrixBuffedIn - Set high to indicate that the current matrix has been read.
//  
// Outputs:
//  matrixDone  - Each bit represents if the corresponding matrix has been updated.
//  tx          - an echo of the data received.
//  matrixOne   - the 1st 4x4 matrix that has been read.
//  matrixTwo   - the 2nd 4x4 matrix that has been read.
//  matrixThree - the 3rd 4x4 matrix that has been read.
// 
///////////////////////////////////////////////////////////////////////////////

module MatrixReceiver(
        input clk, rx, [2:0]matrixBuffedIn,
        output logic [2:0]matrixDone = 0, logic tx,
        logic[NUMBER_OF_BITS-1:0] matrixOne[16] =   {65536,    0,    0,    0,
                                                        0,65536,    0,    0,
                                                        0,    0,65536,    0,
                                                        0,    0,    0,    1},

        logic[NUMBER_OF_BITS-1:0] matrixTwo[16] =   {    0,    0,    0,    0,
                                                        0,    0,    0,    0,
                                                        0,    0,    0,    0,
                                                        0,    0,    0,    0},

        logic[NUMBER_OF_BITS-1:0]matrixThree[16] = {65536,    0,    0,    0,
                                                        0,65536,    0,    0,
                                                        0,    0,65536,    0,
                                                        0,    0,    0,    1}
        );

parameter NUMBER_OF_BITS = 32;

logic [7:0] UARTbyte;
logic readData = 0, ready;
logic [9:0] superCase = 0;
logic [3:0] matrixIterator = 0;
logic [1:0] matrixSelector = 0;
logic validHex;
logic [3:0] hexNum;

  /////////////////
 // UART Reception
/////////////////
UartReceive RX(clk, readData, rx, ready, UARTbyte);

  /////////////////////////
 // UART Echo Transmission
/////////////////////////
UartTransmit TX(clk, ready, UARTbyte, tx, );

  /////////////////////////////////
 // Character to 4-bit Hexadecimal
/////////////////////////////////
Char2Hex HexaConverter(UARTbyte, validHex, hexNum);

always_ff @(posedge clk)
begin
  foreach(matrixBuffedIn[i])
  begin
    if(matrixBuffedIn[i])
      matrixDone[i] <= 0;
  end

  if(ready && readData == 0)
  begin
    readData <= 1;

    casez(superCase)
      0 :begin //Looks for a zero denoting start of hexadecimal
          if(UARTbyte == "0") 
            superCase <= superCase + 1;
          if(UARTbyte == "1")
              matrixSelector <= 0;
          else if(UARTbyte == "2")
            matrixSelector <= 1;
          else if(UARTbyte == "3")
            matrixSelector <= 2;
          else if(UARTbyte == "\r" || UARTbyte == "\n" || UARTbyte == "M")
          begin //Ends matrix reading if a new line or an M is encountered.
            matrixIterator <= 0;
            matrixDone[matrixSelector] <= 1;
          end
        end

      1 :begin // Looks for "x", the next character associated with hexadecimal
          if(UARTbyte == "x") 
          begin
            superCase <= superCase + 1;
            case(matrixSelector)
              0:matrixOne[matrixIterator]   <= 0;
              1:matrixTwo[matrixIterator]   <= 0;
              2:matrixThree[matrixIterator] <= 0;
            endcase
          end
          else 
            superCase <= 0;
        end

      2 :begin // Reads in hexadecimal data, bitshifting into each of the matrix spots.
          if(validHex)
          begin
            case(matrixSelector)
              0:matrixOne[matrixIterator]   <= (matrixOne[matrixIterator]   << 4) | hexNum;
              1:matrixTwo[matrixIterator]   <= (matrixTwo[matrixIterator]   << 4) | hexNum;
              2:matrixThree[matrixIterator] <= (matrixThree[matrixIterator] << 4) | hexNum;
            endcase
          end
          else
          begin // if the character isn't hexadecimal, move on to the next matrix spot.
            superCase <= 0;
            matrixIterator <= matrixIterator + 1;
          end
        end

      default: superCase <= 0;

    endcase

  end
  else
    readData <= 0;
end


endmodule



///////////////////////////////////////////////////////////////////////////////
// Company: DigiPen Institute of Technology
// Engineer: Ben Nollan
//           Cody Anderson
// 
// Module Name: Char2Hex
// Project Name: Daltonismo
// Target Devices: Digilent Nexys Video
// Tool Versions: Vivado 2016.4
// Description: Turns a letter into it's hexadecimal representation
// Inputs:
//  dataIn - Character to convert
//  
// Outputs:
//  validChar - high if character is 0-9 or A-F or a-f.
//  numOut - The converted number (0 to 15).
// 
///////////////////////////////////////////////////////////////////////////////

module Char2Hex (
  input logic[7:0] dataIn,  // Input Character
  output logic validChar,    // If the Character is hex
  output logic[3:0] numOut  // Output Hex number  
);

always_comb
begin
  if(dataIn >= "0" && dataIn <= "9")
  begin
    validChar = 1;
    numOut = dataIn - "0";
  end
  else if(dataIn >= "A" && dataIn <= "F")
  begin
    validChar = 1;
    numOut = dataIn - ("A" - 10);
  end
  else if(dataIn >= "a" && dataIn <= "f")
  begin
    validChar = 1;
    numOut = dataIn - ("a" - 10);
  end
  else
  begin
    validChar = 0;
    numOut = 'hX;
  end
end
endmodule

///////////////////////////////////////////////////////////////////////////////
// Company: DigiPen Institute of Technology
// Engineer: Ben Nollan
//           Cody Anderson
// 
// Module Name: MatrixReceiverBuffered
// Project Name: Daltonismo
// Target Devices: Digilent Nexys Video
// Tool Versions: Vivado 2016.4
// Description: Inputs three matricies from UART and has a buffer for good ones.
// Inputs:
//  clk - internal reference clock
//  rx - the UART reception pin.
//  load - triggers a write to the buffer if a new matrix exists.
//  
// Outputs:
//  tx          - an echo of the data received.
//  matrixOne   - the 1st 4x4 matrix that has been read.
//  matrixTwo   - the 2nd 4x4 matrix that has been read.
//  matrixThree - the 3rd 4x4 matrix that has been read.
// 
///////////////////////////////////////////////////////////////////////////////

module MatrixReceiverBuffered(
        input clk, rx, load,
        output logic tx,
        logic[NUMBER_OF_BITS-1:0] matrixOneBuffered[16] =   {65536,    0,    0,    0,
                                                                 0,65536,    0,    0,
                                                                 0,    0,65536,    0,
                                                                 0,    0,    0,    1},

        logic[NUMBER_OF_BITS-1:0] matrixTwoBuffered[16] =   {    0,    0,    0,    0,
                                                                 0,    0,    0,    0,
                                                                 0,    0,    0,    0,
                                                                 0,    0,    0,    0},
         
        logic[NUMBER_OF_BITS-1:0]matrixThreeBuffered[16] = {65536,    0,    0,    0,
                                                                0,65536,    0,    0,
                                                                0,    0,65536,    0,
                                                                0,    0,    0,    1}
        );
parameter NUMBER_OF_BITS = 32;
logic [31:0] matrixOne[16];
  logic [31:0] matrixTwo[16];
  logic [31:0] matrixThree[16];
  logic [2:0]matrixDone;
  logic [2:0]matrixBuffedIn = 3'b0;

  MatrixReceiver TripleMatrix(clk, rx, matrixBuffedIn, matrixDone, tx, matrixOne, matrixTwo, matrixThree);
  
  always_ff@(posedge clk)
  begin
    if(matrixDone[0] && load)
    begin
      matrixBuffedIn[0] <= 1;
      matrixOneBuffered <= matrixOne;
    end
    else
      matrixBuffedIn[0] <= 0;
    if(matrixDone[1] && load)
    begin
      matrixBuffedIn[1] <= 1;
      matrixTwoBuffered <= matrixTwo;
    end
    else
      matrixBuffedIn[1] <= 0;
    if(matrixDone[2] && load)
    begin
      matrixBuffedIn[2] <= 1;
      matrixThreeBuffered <= matrixThree;
    end
    else
      matrixBuffedIn[2] <= 0;
  end
endmodule