/**
 * PBL3 - RISC-V Pipelined Processor
 * Top-level Pipeline Module
 * 
 * File name: pipeline.sv
 * 
 * Objective:
 *     Integrates all pipeline stages (Fetch, Decode, Execute, Memory, Writeback)
 *     and hazard detection unit to create a complete 5-stage RISC-V processor.
 * 
 * Pipeline Stages:
 *     1. Fetch (IF)    - Instruction fetch and PC management
 *     2. Decode (ID)   - Instruction decode and register file access
 *     3. Execute (EX)  - ALU operations and branch resolution
 *     4. Memory (MEM)  - Data memory access
 *     5. Writeback (WB) - Result selection and register writeback
 */

`timescale 1ns/1ps

module pipeline #(
    parameter P_DATA_WIDTH = 32,
    parameter P_ADDR_WIDTH = 10,
    parameter P_REG_ADDR_WIDTH = 5
)(
    input  logic i_clk,
    input  logic i_rst_n
);

    //=========================================================================
    // Inter-stage Signal Declarations
    //=========================================================================
    
    // IF/ID Pipeline Register Signals
    logic [P_ADDR_WIDTH-1:0]  if_id_pc;
    logic [P_ADDR_WIDTH-1:0]  if_id_pc4;
    logic [P_DATA_WIDTH-1:0]  if_id_instr;
    
    // ID/EX Pipeline Register Signals
    logic                     id_ex_regwrite;
    logic [1:0]               id_ex_resultsrc;
    logic                     id_ex_memwrite;
    logic                     id_ex_jump;
    logic                     id_ex_branch;
    logic [2:0]               id_ex_aluctrl;
    logic                     id_ex_alusrc;
    logic [P_DATA_WIDTH-1:0]  id_ex_rs1_data;
    logic [P_DATA_WIDTH-1:0]  id_ex_rs2_data;
    logic [P_DATA_WIDTH-1:0]  id_ex_pc;
    logic [P_REG_ADDR_WIDTH-1:0] id_ex_rs1_addr;
    logic [P_REG_ADDR_WIDTH-1:0] id_ex_rs2_addr;
    logic [P_REG_ADDR_WIDTH-1:0] id_ex_rd_addr;
    logic [P_DATA_WIDTH-1:0]  id_ex_immext;
    logic [P_DATA_WIDTH-1:0]  id_ex_pc4;
    
    // EX/MEM Pipeline Register Signals
    logic [P_DATA_WIDTH-1:0]  ex_mem_alu_result;
    logic [P_DATA_WIDTH-1:0]  ex_mem_write_data;
    logic                     ex_mem_regwrite;
    logic                     ex_mem_memwrite;
    logic [1:0]               ex_mem_resultsrc;
    logic [P_REG_ADDR_WIDTH-1:0] ex_mem_rd_addr;
    logic [P_DATA_WIDTH-1:0]  ex_mem_pc4;
    
    // MEM/WB Pipeline Register Signals
    logic [P_DATA_WIDTH-1:0]  mem_wb_read_data;
    logic                     mem_wb_regwrite;
    logic [1:0]               mem_wb_resultsrc;
    logic [P_REG_ADDR_WIDTH-1:0] mem_wb_rd_addr;
    logic [P_DATA_WIDTH-1:0]  mem_wb_pc4;
    logic [P_DATA_WIDTH-1:0]  mem_wb_alu_result;
    
    // Writeback Stage Signals
    logic [P_DATA_WIDTH-1:0]  wb_result;
    
    // Hazard Unit Signals
    logic                     stall_f, stall_d;
    logic                     flush_d, flush_e;
    logic [1:0]               forward_a, forward_b;
    
    // Branch/Jump Control Signals
    logic                     pcsrc;
    logic [P_ADDR_WIDTH-1:0]  pc_target;
    logic                     zero_flag;
    
    // Forwarding Data
    logic [P_DATA_WIDTH-1:0]  forward_data_mem;
    logic [P_DATA_WIDTH-1:0]  forward_data_wb;
    
    //=========================================================================
    // Stage Instantiations
    //=========================================================================
    
    //-------------------------------------------------------------------------
    // Fetch Stage
    //-------------------------------------------------------------------------
    fetch_stage #(
        .P_DATA_WIDTH(P_DATA_WIDTH)
    ) u_fetch_stage (
        .i_clk          (i_clk),
        .i_rst_n        (i_rst_n),
        .i_stall_f      (stall_f),
        .i_stall_d      (stall_d),
        .i_flush_d      (flush_d),
        .i_pcsrc_e      (pcsrc),
        .i_pctarget_e   (pc_target),
        .o_pc_d         (if_id_pc),
        .o_pc4_d        (if_id_pc4),
        .o_instr_d      (if_id_instr)
    );
    
    //-------------------------------------------------------------------------
    // Decode Stage
    //-------------------------------------------------------------------------
    decode_stage #(
        .DATA_WIDTH(P_DATA_WIDTH),
        .ADDR_WIDTH(P_REG_ADDR_WIDTH)
    ) u_decode_stage (
        .i_clk          (i_clk),
        .i_rst_n        (i_rst_n),
        .i_flush_e      (flush_e),
        .i_instr_d      (if_id_instr),
        .i_pc_d         (if_id_pc),
        .i_pc4_d        (if_id_pc4),
        .i_reg_write_w  (mem_wb_regwrite),
        .i_rd_addr_w    (mem_wb_rd_addr),
        .i_result_w     (wb_result),
        .i_zero_e       (zero_flag),
        .o_regwrite_e   (id_ex_regwrite),
        .o_resultsrc_e  (id_ex_resultsrc),
        .o_memwrite_e   (id_ex_memwrite),
        .o_jump_e       (id_ex_jump),
        .o_branch_e     (id_ex_branch),
        .o_aluctrl_e    (id_ex_aluctrl),
        .o_alusrc_e     (id_ex_alusrc),
        .o_rs1_data_e   (id_ex_rs1_data),
        .o_rs2_data_e   (id_ex_rs2_data),
        .o_pc_e         (id_ex_pc),
        .o_rs1_addr_e   (id_ex_rs1_addr),
        .o_rs2_addr_e   (id_ex_rs2_addr),
        .o_rd_addr_e    (id_ex_rd_addr),
        .o_immext_e     (id_ex_immext),
        .o_pc4_e        (id_ex_pc4),
        .o_pcsrc_e      (pcsrc)
    );
    
    //-------------------------------------------------------------------------
    // Execute Stage
    //-------------------------------------------------------------------------
    execute_stage #(
        .DATA_WIDTH(P_DATA_WIDTH),
        .ADDR_WIDTH(P_ADDR_WIDTH)
    ) u_execute_stage (
        .i_clk          (i_clk),
        .i_rst_n        (i_rst_n),
        //.i_flush_e      (flush_e),
        .i_rs1_data_e   (id_ex_rs1_data),
        .i_rs2_data_e   (id_ex_rs2_data),
        .i_immext_e     (id_ex_immext),
        .i_pc_e         (id_ex_pc),
        .i_pc4_e        (id_ex_pc4),
        .i_rs1_addr_e   (id_ex_rs1_addr),
        .i_rs2_addr_e   (id_ex_rs2_addr),
        .i_rd_addr_e    (id_ex_rd_addr),
        .i_aluctrl_e    (id_ex_aluctrl),
        .i_alusrc_e     (id_ex_alusrc),
        .i_branch_e     (id_ex_branch),
        .i_jump_e       (id_ex_jump),
        .i_regwrite_e   (id_ex_regwrite),
        .i_memwrite_e   (id_ex_memwrite),
        .i_resultsrc_e  (id_ex_resultsrc),
        .i_forward_m    (forward_data_mem),
        .i_forward_w    (forward_data_wb),
        .i_forward_a    (forward_a),
        .i_forward_b    (forward_b),
        .o_alu_result_m (ex_mem_alu_result),
        .o_write_data_m (ex_mem_write_data),
        .o_pctarget_e   (pc_target),
        .o_zero_e       (zero_flag),
        .o_regwrite_m   (ex_mem_regwrite),
        .o_memwrite_m   (ex_mem_memwrite),
        .o_resultsrc_m  (ex_mem_resultsrc),
        .o_rd_addr_m    (ex_mem_rd_addr),
        .o_pc4_m        (ex_mem_pc4)
    );
    
    //-------------------------------------------------------------------------
    // Memory Stage
    //-------------------------------------------------------------------------
    memory_stage #(
        .P_DATA_WIDTH(P_DATA_WIDTH),
        .P_ADDR_WIDTH(P_ADDR_WIDTH)
    ) u_memory_stage (
        .i_clk          (i_clk),
        .i_rst_n        (i_rst_n),
        .i_regwrite_m   (ex_mem_regwrite),
        .i_resultsrc_m  (ex_mem_resultsrc),
        .i_memwrite_m   (ex_mem_memwrite),
        .i_alu_result_m (ex_mem_alu_result),
        .i_write_data_m (ex_mem_write_data),
        .i_rd_addr_m    (ex_mem_rd_addr),
        .i_pc4_m        (ex_mem_pc4),
        .o_read_data_w  (mem_wb_read_data),
        .o_regwrite_w   (mem_wb_regwrite),
        .o_resultsrc_w  (mem_wb_resultsrc),
        .o_rd_addr_w    (mem_wb_rd_addr),
        .o_pc4_w        (mem_wb_pc4),
        .o_alu_result_w (mem_wb_alu_result)
    );
    
    //-------------------------------------------------------------------------
    // Writeback Stage
    //-------------------------------------------------------------------------
    write_back #(
        .P_WIDTH(P_DATA_WIDTH)
    ) u_write_back (
        .i_alu_result_w (mem_wb_alu_result),
        .i_mem_data_w   (mem_wb_read_data),
        .i_pc_plus_4_w  (mem_wb_pc4),
        .i_sel_w        (mem_wb_resultsrc),
        .o_result_w     (wb_result)
    );
    
    //-------------------------------------------------------------------------
    // Hazard Detection Unit
    //-------------------------------------------------------------------------
    hazard_stage u_hazard_stage (
        .i_clk          (i_clk),
        .if_id_instr    (if_id_instr),
        .i_branch_d     (id_ex_branch),
        .i_jump_d       (id_ex_jump),
        .i_rs1_addr_e   (id_ex_rs1_addr),
        .i_rs2_addr_e   (id_ex_rs2_addr),
        .i_rd_addr_e    (id_ex_rd_addr),
        .i_regwrite_e   (id_ex_regwrite),
        .i_resultsrc_e  (id_ex_resultsrc),
        .i_rd_addr_m    (ex_mem_rd_addr),
        .i_regwrite_m   (ex_mem_regwrite),
        .i_rd_addr_w    (mem_wb_rd_addr),
        .i_regwrite_w   (mem_wb_regwrite),
        .i_pcsrc_e      (pcsrc),
        .o_stall_f      (stall_f),
        .o_stall_d      (stall_d),
        .o_flush_d      (flush_d),
        .o_flush_e      (flush_e),
        .o_forward_a_e  (forward_a),
        .o_forward_b_e  (forward_b)
    );
    
    //=========================================================================
    // Forwarding Data Assignment
    //=========================================================================
    assign forward_data_mem = ex_mem_alu_result;
    assign forward_data_wb = wb_result;

endmodule