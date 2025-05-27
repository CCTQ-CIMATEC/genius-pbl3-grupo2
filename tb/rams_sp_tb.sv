`timescale 1ns / 1ps

module top_rams_tb;

    // Sinais de teste
    logic clk;
    logic we;
    logic rd;
    logic [3:0] en;
    logic [9:0] addr;
    logic [31:0] di;
    logic [31:0] dout;

    // Sinal simulado de entrada e saída
    logic  [3:0] o_data_rd_en_ctrl;        // Simula sinal de controle do memory access
    logic [31:0] ex_reg_read_data2;        // simula entrada de dados vindo do memory acess
    logic [31:0] ma_read_data;             // simula saída de dados após processamento do memory access


    bytes_slicer uut (
        .clk(clk),
        .we(we),
        .rd(rd),
        .en(o_data_rd_en_ctrl),  // Conecta o sinal de controle
        .addr(addr),
        .di(di),
        .dout(dout)
    );

    // Geração do clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // clock de 10ns
    end

    initial begin
        // Inicializações
        clk = 0;
        we = 0;
        rd = 0;
        en = 4'b0000;
        addr = 10'd0;
        di = 32'd0;
        dout = 32'd0;
        ma_read_data = 32'd0;              // Inicializa o dado lido do memory access
        o_data_rd_en_ctrl = 4'b0000;       // Inicializa o sinal de controle
        ex_reg_read_data2 = 32'hA5B6C7D8;  // Valor qualquer de 32 bits
        
        // -----------------------
        // Teste 1: Escreve 1 byte
        // -----------------------
        @(posedge clk);

        we = 1;
        rd = 0;
        
        o_data_rd_en_ctrl = 4'b0001;  // Simula recebimento do sinal ctrl
        
        en = o_data_rd_en_ctrl;       // Habilita SRAM0
        addr = 10'd5;                 // Endereço arbitrário

        di = ex_reg_read_data2;       // carrega o dado em di
        
        #10;//@(posedge clk);
        we = 0;

        // -----------------------
        // Teste 1: Lê 1 byte
        // -----------------------
        @(posedge clk);
        rd = 1;
        @(posedge clk);
        rd = 0;

        ma_read_data = dout;
        
        $display("**************************************************");
        $display("*              Resultados do Teste 1              *");
        $display("**************************************************");
        $display("Dado de entrada: %h", ex_reg_read_data2);
        $display("Enable: %b", en);
        $display("Byte escrito: %h", di);
        $display("Byte lido: %h", ma_read_data);
        $display("**************************************************\n");


        // -----------------------
        // Teste 2: Escreve 1 half-word (16 bits)
        // -----------------------
        @(posedge clk);

        we = 1;
        rd = 0;

        o_data_rd_en_ctrl = 4'b0011;  // Habilita SRAM0 e SRAM1
        en = o_data_rd_en_ctrl;
        addr = 10'd10;                // Novo endereço

        di = ex_reg_read_data2;       // Usa o mesmo dado
        
        #10;//@(posedge clk);
        we = 0;

        // -----------------------
        // Teste 2: Lê 1 half-word
        // -----------------------
        @(posedge clk);
        rd = 1;
        @(posedge clk);
        rd = 0;

        ma_read_data = dout;

        $display("**************************************************");
        $display("*              Resultados do Teste 2              *");
        $display("**************************************************");
        $display("Dado de entrada: %h", ex_reg_read_data2);
        $display("Enable: %b", en);
        $display("Half-word escrito: %h", di);
        $display("Half-word lido: %h", ma_read_data);
        $display("**************************************************\n");


        // -----------------------
        // Teste 3: Escreve 1 word (32 bits)
        // -----------------------
        @(posedge clk);

        we = 1;
        rd = 0;

        o_data_rd_en_ctrl = 4'b1111;  // Habilita todas as SRAMs
        en = o_data_rd_en_ctrl;
        addr = 10'd20;                // Novo endereço

        di = ex_reg_read_data2;
        
        #10;//@(posedge clk);
        we = 0;

        // -----------------------
        // Teste 3: Lê 1 word
        // -----------------------
        @(posedge clk);
        rd = 1;
        @(posedge clk);
        rd = 0;

        ma_read_data = dout;

        $display("**************************************************");
        $display("*              Resultados do Teste 3              *");
        $display("**************************************************");
        $display("Dado de entrada: %h", ex_reg_read_data2);
        $display("Enable: %b", en);
        $display("Word escrito: %h", di);
        $display("Word lido: %h", ma_read_data);
        $display("**************************************************\n");

        // Finaliza a simulação
        @(posedge clk);
        $finish;
    end

endmodule
