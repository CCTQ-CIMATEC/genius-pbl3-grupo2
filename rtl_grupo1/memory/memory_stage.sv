/**
 * PBL3 - RISC-V Pipelined Processor
 * Memory Stage Module
 * 
 * File name: memory_stage.v
 * 
 * Objective:
 *     Implements the memory access stage of a pipelined RISC-V processor.
 *     Handles memory read/write and selects the correct result to forward.
 * 
 * Description:
 *     - Writes data to memory if enabled
 *     - Reads data from memory
 *     - Selects between memory read result or PC+4 as final result
 * 
 * Functional Diagram:
 * 
 *                       +-------------------------+
 *                       |      MEMORY STAGE       |
 *                       |                         |
 *  i_memwrite --->      |                         |
 *  i_result_m ---->     |      DATA MEMORY        |--> o_read_data_w
 *  i_rs2_data_m -->     |                         |
 *                       |                         |
 *                       |   +-----------------+   |
 *  i_resultsrc_m -->    |                         |
                         |                         |--> o_result_w
 *  i_pc4_m -------->    |                         |   
 *                       +-------------------------+
 */

module memory_stage #(
    parameter P_DATA_WIDTH = 32,
    parameter P_ADDR_WIDTH = 8
)(
    input  logic                      i_clk,                 // clock
    input  logic                      i_rst_n,
    
    input  logic                      i_regwrite_m,
    input  logic [1:0]                i_resultsrc_m,
    input  logic                      i_memwrite_m,

    input  logic [P_DATA_WIDTH-1:0]   i_alu_result_m,
    input  logic [P_DATA_WIDTH-1:0]   i_write_data_m,
    input  logic [4:0]                i_rd_addr_m,
    input  logic [P_ADDR_WIDTH-1:0]   i_pc4_m, 
    
    output logic [P_DATA_WIDTH-1:0]   o_read_data_w,         // data read from memory (to be used in the WB stage)
    output logic                      o_regwrite_w,         //TODO -> OLHA TEU REGFILE CORNO
    output logic [1:0]                o_resultsrc_w,
    output logic [4:0]                o_rd_addr_w,
    output logic [P_ADDR_WIDTH-1:0]   o_pc4_w,
    output logic [P_DATA_WIDTH-1:0]   o_alu_result_w
);

    logic [P_DATA_WIDTH-1:0] l_read_data_m;

    // data memory instance
    data_memory #(
        .P_ADDR_WIDTH(P_ADDR_WIDTH),
        .P_DATA_WIDTH(P_DATA_WIDTH)
    ) u_datamemory (
        .i_clk   (i_clk),
        .i_we    (i_memwrite_m),
        .i_addr  (i_alu_result_m[P_ADDR_WIDTH-1:0]),  
        .i_wdata (i_write_data_m),
        .o_rdata (l_read_data_m)
    );

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_regwrite_w  <= 0;
            o_resultsrc_w <= 0;
            o_read_data_w <= 0;
            o_rd_addr_w <= 0;
            o_pc4_w     <= 0;
            o_alu_result_w <= 0;
        end else begin
            o_regwrite_w <= i_regwrite_m;
            o_resultsrc_w <= i_resultsrc_m;
            o_alu_result_w <= i_alu_result_m;
            o_read_data_w <=  l_read_data_m;
            o_rd_addr_w <= i_rd_addr_m;
            o_pc4_w <= i_pc4_m;
        end
    end

endmodule

