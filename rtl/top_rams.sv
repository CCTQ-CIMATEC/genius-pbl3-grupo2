`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/26/2025 03:20:59 PM
// Design Name: 
// Module Name: top_rams
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


module top_rams (

    input  logic        clk,
    input  logic        we,             // Único sinal de escrita
    input  logic        rd,             // Único sinal de leitura
    input  logic [3:0]  en,             // Sinal independente para cada banco
    input  logic [9:0]  addr,           // Único endereço compartilhado
    input  logic [31:0] di,             // Entrada completa (32 bits)
    output logic [31:0] dout           // 4 saídas de 8 bits
);

    genvar i;
    generate
        for (i = 0; i < 4; i++) begin : ram_bank
            rams_sp_wf #(
                .DATA_WIDTH(8)
            ) u_ram (
                .clk(clk),
                .we(we),                            
                .rd(rd),                            
                .en(en[i]),                         // Enable independente
                .addr(addr),                        
                .di(di),            
                .dout(dout[i])                      // Saída específica de cada banco
            );
        end
    endgenerate

endmodule
