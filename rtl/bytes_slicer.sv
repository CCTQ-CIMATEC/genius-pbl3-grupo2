`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/27/2025
// Design Name: bytes_slicer
// Module Name: bytes_slicer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Fatiamento de 32 bits em 4 fatias de 8 bits baseado no enable
//////////////////////////////////////////////////////////////////////////////////

module bytes_slicer #(

    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 10
)(
    input                       clk,
    input                       we,
    input                       rd,
    input      [3:0]            en,   // Recebe o valor de o_data_rd_en_ctrl
    input      [ADDR_WIDTH-1:0] addr,
    input                [31:0] di,
    output reg           [31:0] dout
);

reg [DATA_WIDTH-1:0] RAM [ (1<<ADDR_WIDTH)-1 : 0 ];

always @(posedge clk) begin

            if (we && !rd) begin
                
                if (en[0]) RAM[addr][7:0]    <=   di[7:0]; //dout <= RAM[addr][7:0];    // SRAM0
                if (en[1]) RAM[addr][15:8]   <=  di[15:8]; //dout <= RAM[addr][15:8];   // SRAM1
                if (en[2]) RAM[addr][23:16]  <= di[23:16]; //dout <= RAM[addr][23:16];  // SRAM2
                if (en[3]) RAM[addr][31:24]  <= di[31:24]; //dout <= RAM[addr][31:24];  // SRAM3

            end
            else if (!we && rd) begin
                
                /*if (en[0]) dout <= RAM[addr][7:0];
                if (en[1]) dout <= RAM[addr][15:8];
                if (en[2]) dout <= RAM[addr][23:16];
                if (en[3]) dout <= RAM[addr][31:24];*/

                dout <= { (en[3] ? RAM[addr][31:24] : 8'h00),
                          (en[2] ? RAM[addr][23:16] : 8'h00),
                          (en[1] ? RAM[addr][15:8]  : 8'h00),
                          (en[0] ? RAM[addr][7:0]   : 8'h00) };
            end

    end


endmodule
