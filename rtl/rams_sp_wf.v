`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/23/2025 10:23:23 AM
// Design Name: 
// Module Name: rams_sp_wf
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

module rams_sp_wf (clk, we, rd, en, addr, di, dout);

    input         clk;
    input         we;
    input         rd;
    input         en;
    input   [9:0] addr;
    input  [31:0] di;
    output [31:0] dout;
    reg    [31:0] RAM [1023:0];
    reg    [31:0] dout;

always @(posedge clk)

  begin
    if (en)begin
        
    if (we)
        begin
            RAM[addr] <= di;
            dout <= di;
        end

    else if(rd)
        begin
            dout <= RAM[addr];
        end
    end
  end
endmodule
