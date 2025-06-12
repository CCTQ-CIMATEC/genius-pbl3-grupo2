/**
 * PBL3 - RISC-V Pipelined Processor
 * Memory Stage Module with External Memory Interface
 *
 * File name: memory_stage.sv
 *
 * Objective:
 *     Implements the memory access stage of a pipelined RISC-V processor.
 *     Interfaces with external data memory and forwards pipeline data.
 *
 * Description:
 *     - Provides interface signals to external data memory
 *     - Handles memory read/write control
 *     - Manages MEM/WB pipeline register
 *     - No internal memory instantiation
 */

`timescale 1ns/1ps

module memory_stage #(
    parameter P_DATA_WIDTH = 32,
    parameter P_DMEM_ADDR_WIDTH = 8
)(
    input logic i_clk,
    input logic i_rst_n,
    
    // Pipeline inputs from EX stage
    input logic i_regwrite_m,
    input logic [1:0] i_resultsrc_m,
    input logic i_memwrite_m,
    input logic [P_DATA_WIDTH-1:0] i_alu_result_m,
    input logic [P_DATA_WIDTH-1:0] i_write_data_m,
    input logic [4:0] i_rd_addr_m,
    input logic [P_DATA_WIDTH-1:0] i_pc4_m,
    
    // External Data Memory Interface
    output logic                          o_dmem_we,
    output logic [P_DMEM_ADDR_WIDTH-1:0]  o_dmem_addr,
    output logic [P_DATA_WIDTH-1:0]       o_dmem_wdata,
    input  logic [P_DATA_WIDTH-1:0]       i_dmem_rdata,
    
    // Pipeline Outputs to WB stage
    output logic [P_DATA_WIDTH-1:0] o_read_data_w,
    output logic o_regwrite_w,
    output logic [1:0] o_resultsrc_w,
    output logic [4:0] o_rd_addr_w,
    output logic [P_DATA_WIDTH-1:0] o_pc4_w,
    output logic [P_DATA_WIDTH-1:0] o_alu_result_w
);

    //=========================================================================
    // External Data Memory Interface Logic
    //=========================================================================
    
    // Connect memory control signals to external data memory
    assign o_dmem_we    = i_memwrite_m;                              // Write enable
    assign o_dmem_addr  = i_alu_result_m[P_DMEM_ADDR_WIDTH-1:0];     // Address from ALU
    assign o_dmem_wdata = i_write_data_m;                            // Write data

    //=========================================================================
    // MEM/WB Pipeline Register
    //=========================================================================
    
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            // Reset all outputs to safe values
            o_regwrite_w   <= '0;
            o_resultsrc_w  <= '0;
            o_read_data_w  <= '0;
            o_rd_addr_w    <= '0;
            o_pc4_w        <= '0;
            o_alu_result_w <= '0;
        end else begin
            // Forward control signals and data to WB stage
            o_regwrite_w   <= i_regwrite_m;
            o_resultsrc_w  <= i_resultsrc_m;
            o_alu_result_w <= i_alu_result_m;
            o_read_data_w  <= i_dmem_rdata;     // Data read from external memory
            o_rd_addr_w    <= i_rd_addr_m;
            o_pc4_w        <= i_pc4_m;
        end
    end

endmodule