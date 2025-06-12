/**
 * PBL3 - RISC-V Pipelined Processor  
 * Fetch Stage Module with External Memory Interface
 *
 * File name: fetch_stage.sv
 *
 * Objective:
 *     Implement the instruction fetch stage for a RISC-V pipelined processor.
 *     Handles program counter management and interfaces with external instruction memory.
 *
 * Specification:
 *     - Program counter (PC) management with increment logic
 *     - External instruction memory interface
 *     - Pipeline stall and flush control
 *     - Branch target handling
 *     - Configurable address and data widths
 *     - Fully synthesizable with proper timing
 */

`timescale 1ns/1ps

module fetch_stage #(
    parameter P_DATA_WIDTH = 32,
    parameter PC_WIDTH = 9
)(
    // Clock and Reset
    input  logic                     i_clk,
    input  logic                     i_rst_n,
    
    // Control Signals
    input  logic                     i_stall_f,             
    input  logic                     i_stall_d,
    input  logic                     i_flush_d,

    // PC related
    input  logic                     i_pcsrc_e,
    input  logic [PC_WIDTH:0]      i_pctarget_e, 

    // External Instruction Memory Interface
    output logic [PC_WIDTH:0]      o_imem_addr,
    input  logic [P_DATA_WIDTH-1:0]  i_imem_rdata,

    // Pipeline Outputs
    output logic [PC_WIDTH:0]      o_pc_d,
    output logic [PC_WIDTH:0]      o_pc4_d,
    output logic [P_DATA_WIDTH-1:0]  o_instr_d
);

    logic [PC_WIDTH:0] l_pc_f, l_pc4_f, l_pcnext_f; 
    
    // PC incrementer (PC + 4)
    adder #(.P_WIDTH(PC_WIDTH)) u_pcadd4 (
        .i_a (l_pc_f),
        .i_b ({{(PC_WIDTH-2){1'b0}}, 3'b100}),  // 4 in PC_WIDTH bits            
        .o_y (l_pc4_f)
    );
    
    // PC source mux (select: PC+4 or target)
    mux2 #(.P_WIDTH(PC_WIDTH)) u_pcmux (
        .i_a   (l_pc4_f),
        .i_b   (i_pctarget_e),
        .i_sel (i_pcsrc_e),
        .o_y   (l_pcnext_f)
    );

    // PC register (state element)
    flopr #(.P_WIDTH(PC_WIDTH)) u_pcreg (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_en    (!i_stall_f),
        .i_d     (l_pcnext_f),
        .o_q     (l_pc_f)
    );

    // Connect PC to external instruction memory
    assign o_imem_addr = l_pc_f;

    // IF/ID Pipeline Register
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n | i_flush_d) begin
            o_pc_d      <= '0;
            o_pc4_d     <= '0;
            o_instr_d   <= '0;
        end else if(!i_stall_d) begin
            o_pc_d      <= l_pc_f;
            o_pc4_d     <= l_pc4_f;
            o_instr_d   <= i_imem_rdata;  // Instruction from external memory
        end
    end

endmodule