`timescale 1ns / 1ps

module memory_module_tb;

    // Sinais de controle
    logic i_clk;
    logic i_rst_n;

    // Separadores de waveform
    logic ENTRADAS;
    logic SAIDAS;
    logic RAM_Signals;

    // Entradas
    logic        i_clk_en;
    logic [31:0] i_data_rd;
    logic        i_ex_mem_to_reg;
    logic  [1:0] i_ex_rw_sel;
    logic        i_ex_reg_wr;
    logic        i_ex_mem_rd;
    logic        i_ex_mem_wr;
    logic [31:0] i_ex_pc_plus_4;
    logic [31:0] i_ex_alu_result;
    logic [31:0] i_ex_reg_read_data2;
    logic  [4:0] i_ex_reg_dest;
    logic  [2:0] i_ex_funct3;
    logic  [6:0] i_ex_funct7;

    // Saídas
    logic  [1:0] o_data_rd_en_ctrl;
    logic        o_ma_mem_to_reg;
    logic  [1:0] o_ma_rw_sel;
    logic [31:0] o_ma_pc_plus_4;
    logic [31:0] o_ma_read_data;
    logic [31:0] o_ma_result;
    logic  [4:0] o_ma_reg_dest;
    logic        o_ma_reg_wr;
    logic        o_ma_ram_en;

    // Instância do DUT
    memory_module dut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_clk_en(i_clk_en),
        .i_ex_mem_to_reg(i_ex_mem_to_reg),
        .i_ex_rw_sel(i_ex_rw_sel),
        .i_ex_reg_wr(i_ex_reg_wr),
        .i_ex_mem_rd(i_ex_mem_rd),
        .i_ex_mem_wr(i_ex_mem_wr),
        .i_ex_pc_plus_4(i_ex_pc_plus_4),
        .i_ex_alu_result(i_ex_alu_result),
        .i_ex_reg_read_data2(i_ex_reg_read_data2),
        .i_ex_reg_dest(i_ex_reg_dest),
        .i_ex_funct3(i_ex_funct3),
        .i_ex_funct7(i_ex_funct7),
        .o_data_rd_en_ctrl(o_data_rd_en_ctrl),
        .o_ma_mem_to_reg(o_ma_mem_to_reg),
        .o_ma_rw_sel(o_ma_rw_sel),
        .o_ma_pc_plus_4(o_ma_pc_plus_4),
        .o_ma_read_data(o_ma_read_data),
        .o_ma_result(o_ma_result),
        .o_ma_reg_dest(o_ma_reg_dest),
        .o_ma_reg_wr(o_ma_reg_wr)
    );

    // Geração do clock
    initial begin
        i_clk = 0;
        forever #5 i_clk = ~i_clk;  // Clock com período de 10 ns
    end

    // Estímulos de teste
    initial begin
        integer i;
        logic [31:0] base_addr;
        logic [31:0] data;

        // Inicialização
        i_rst_n             = 0;
        i_clk_en            = 0;
        i_ex_mem_wr         = 0;
        i_ex_mem_rd         = 0;
        i_ex_mem_to_reg     = 0;
        i_ex_rw_sel         = 0;
        i_ex_reg_wr         = 0;
        i_ex_pc_plus_4      = 0;
        i_ex_alu_result     = 0;
        i_ex_reg_read_data2 = 0;
        i_ex_reg_dest       = 0;
        i_ex_funct3         = 0;
        i_ex_funct7         = 0;

        base_addr = 32'h00000020;

        #12;
        i_rst_n = 1;
        i_clk_en = 1;

        // *** Escrita de 10 valores ***
        for (i = 0; i < 10; i = i + 1) begin
            i_ex_mem_wr         = 1;
            i_ex_mem_rd         = 0;
            i_ex_alu_result     = base_addr + (i * 4);  // endereços sequenciais de 4 bytes
            i_ex_reg_read_data2 = {24'h000000, (8'h41 + i)};  // Só o LSB com a letra

            #10;  // Espera um ciclo para escrita

            i_ex_mem_wr = 0;
            #10;  // Pequeno delay
        end

        // *** Leitura dos mesmos 10 valores ***
        for (i = 0; i < 10; i = i + 1) begin
            i_ex_mem_rd         = 1;
            i_ex_mem_wr         = 0;
            i_ex_alu_result     = base_addr + (i * 4);

            #10;  // Espera um ciclo para leitura

            // Mostra o dado lido
            $display("Endereco: %h, Dado Lido: %h", i_ex_alu_result, o_ma_read_data);

            i_ex_mem_rd = 0;
            #10;  // Pequeno delay
        end

        // Finaliza simulação
        #20;
        $finish;
    end

endmodule
