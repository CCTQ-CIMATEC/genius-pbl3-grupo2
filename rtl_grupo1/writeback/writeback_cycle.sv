module write_back #(

    parameter P_WIDTH = 32
)(
    input  logic [P_WIDTH-1:0] i_alu_result_w,
    input  logic [P_WIDTH-1:0] i_mem_data_w,
    input  logic [9:0] i_pc_plus_4_w,
    input  logic [1:0]         i_sel_w,   // LOOK HERE -> i_resultsrc
    output logic [P_WIDTH-1:0] o_result_w
    
);

    logic [31:0] lpc;
    assign lpc = {22'b0, i_pc_plus_4_w};
    
    logic [P_WIDTH-1:0] mux0_out_w;

    // Primeiro mux: ALU result ou memória
    mux2 #(.P_WIDTH(P_WIDTH)) mux0 (
        .i_a    (i_alu_result_w),
        .i_b    (i_mem_data_w),
        .i_sel  (i_sel_w[0]),
        .o_y    (mux0_out_w)
    );

    // Segundo mux: saída do primeiro mux ou PC+4
    mux2 #(.P_WIDTH(P_WIDTH)) mux1 (
        .i_a    (mux0_out_w),
        .i_b   ( lpc),
        .i_sel  (i_sel_w[1]),
        .o_y    (o_result_w)
    );

endmodule
