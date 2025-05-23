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

module rams_sp_wf (i_ram_clk, i_ram_we, i_ram_rd, i_ram_en, i_ram_addr, i_ram_di, o_ram_dout);

    input         i_ram_clk;
    input         i_ram_we;
    input         i_ram_rd;
    input         i_ram_en;
    input  [9:0]  i_ram_addr;
    input  [31:0] i_ram_di;
    output reg [31:0] o_ram_dout;   

    reg    [31:0] RAM [1023:0];

    always @(posedge i_ram_clk) begin
        if (i_ram_en) begin
            // Rotina para escrita
            if (i_ram_we && !i_ram_rd) begin
                RAM[i_ram_addr] <= i_ram_di;
                o_ram_dout <= i_ram_di;
            end
            // Rotina para leitura
            else if(!i_ram_we && i_ram_rd) begin
                o_ram_dout <= RAM[i_ram_addr];
            end
        end
    end

endmodule