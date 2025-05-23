`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/21/2025 03:42:48 PM
// Design Name: 
// Module Name: memory_module
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Modificado para integração com rams_sp_wf
// 
//////////////////////////////////////////////////////////////////////////////////

module memory_module(
    input  logic i_clk,
    input  logic i_rst_n,

    input logic ENTRADAS,
    input logic SAIDAS,
    input logic RAM_Signals,

    // Entradas
    input logic        i_clk_en,
    //input logic [31:0] i_data_rd,
    input logic        i_ex_mem_to_reg,
    input logic  [1:0] i_ex_rw_sel,
    input logic        i_ex_reg_wr,
    input logic        i_ex_mem_rd,
    input logic        i_ex_mem_wr,
    input logic [31:0] i_ex_pc_plus_4,
    input logic [31:0] i_ex_alu_result,
    input logic [31:0] i_ex_reg_read_data2,
    input logic  [4:0] i_ex_reg_dest,
    input logic  [2:0] i_ex_funct3,
    input logic  [6:0] i_ex_funct7,

    // Saídas
    output logic  [1:0] o_data_rd_en_ctrl,
    output logic        o_ma_ram_en,
    output logic        o_ma_mem_to_reg,
    output logic  [1:0] o_ma_rw_sel,
    output logic [31:0] o_ma_pc_plus_4,
    output logic [31:0] o_ma_read_data,
    output logic [31:0] o_ma_result,
    output logic  [4:0] o_ma_reg_dest,
    output logic        o_ma_reg_wr
);

    // Sinais internos para a RAM
    logic        i_ram_en;   
    logic        i_ram_we;
    logic        i_ram_rd;
    logic [9:0]  i_ram_addr;
    logic [31:0] i_ram_di;
    logic [31:0] o_ram_dout;
    
    logic        ram_en_wr;
    logic        ram_en_rd;
    logic [31:0] i_data_rd;

    // Instancia a RAM
    rams_sp_wf ram_inst (
        //.i_ram_clk(i_clk),
        //.i_ram_en(i_ram_en),
        //.i_ram_we(i_ram_we),
        //.i_ram_rd(i_ram_rd),
        //.i_ram_en(i_ram_en),
        //.i_ram_addr(i_ram_addr),
        //.i_ram_di(i_ram_di),
        //.o_ram_dout(o_ram_dout)

        .i_ram_clk(i_clk),
        .i_ram_en(o_ma_ram_en),
        .i_ram_we(i_ex_mem_wr),
        .i_ram_rd(i_ex_mem_rd),
        .i_ram_addr(i_ex_alu_result),
        .i_ram_di(i_ex_reg_read_data2),
        .o_ram_dout(i_data_rd)
    );

        assign ram_en_wr = i_ram_en & i_ex_mem_wr;             // Habilita escrita (wr = 1 e en = 1)
        assign ram_en_rd = i_ram_en & i_ex_mem_rd;             // Habilita leitura (rd = 1 e en = 1)
        assign o_ma_read_data = i_data_rd;                     // Dado lido da memória

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
         
            o_ma_mem_to_reg    <= 0;
            o_ma_rw_sel        <= 0;
            o_ma_pc_plus_4     <= 0;
            o_ma_read_data     <= 0;
            o_ma_result        <= 0;
            o_ma_reg_dest      <= 0;
            o_ma_reg_wr        <= 0;
            o_data_rd_en_ctrl  <= 0;
            o_ma_ram_en        <= 1;
        
        end else if (i_clk_en) begin         

            // Propagação dos sinais (Pipeline)
                
            o_ma_mem_to_reg <= i_ex_mem_to_reg;  
            o_ma_rw_sel     <= i_ex_rw_sel;
            o_ma_reg_wr     <= i_ex_reg_wr;
            o_ma_pc_plus_4  <= i_ex_pc_plus_4;
            o_ma_result     <= i_ex_alu_result;
            o_ma_reg_dest   <= i_ex_reg_dest;

            // Configura sinais para a RAM
            //ram_addr    = i_ex_alu_result[9:0];           // Endereço da RAM
            //ram_data_in = i_ex_reg_read_data2[31:0];      // Dado a ser escrito       


            //ram_we = i_ex_mem_wr;


            // Etapa de controle de escrita/leitura da memória

            // Operação de escrita
            if (ram_en_wr) begin
                i_ram_di[i_ex_alu_result[9:0]] <= i_ex_reg_read_data2;
            end

            // Operação de leitura
            if (ram_en_rd) begin
                //o_ma_read_data <= memory_array[i_ex_alu_result[9:0]];
                //i_data_rd <= o_ram_dout[i_ex_alu_result[9:0]]; 
                o_ma_read_data <= o_ram_dout;
            end



            // Controle de tamanho
            case (i_ex_funct3)
                3'b000: o_data_rd_en_ctrl <= 2'b00; // byte
                3'b001: o_data_rd_en_ctrl <= 2'b01; // half-word
                3'b010: o_data_rd_en_ctrl <= 2'b10; // word
               default: o_data_rd_en_ctrl <= 2'b11; // reservado
            endcase
        end
    end
endmodule
