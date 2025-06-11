/**
 * PBL3 - RISC-V Pipelined Processor
 * Instruction Decode Stage Module
 * 
 * File name: decode_stage.sv
 * 
 * Objective:
 *     Implements the instruction decode stage of a pipelined RISC-V processor.
 *     Combines controller, register file, and immediate extender functionality.
 * 
 * Description:
 *     - Decodes instruction fields and generates control signals
 *     - Reads source operands from register file
 *     - Extends immediate values based on instruction type
 *     - Passes all necessary signals to execute stage via pipeline register
 * 
 * Functional Diagram:
 * 
 *                    +----------------------------------+
 *                    |          DECODE STAGE            |
 *                    |                                  |
 *   i_instr_d    --->|  +----------+  +----------+      |
 *   i_pc_d       --->|  |CONTROLLER|  | REGFILE  |      |---> to EX stage
 *   i_pc4_d      --->|  +----------+  +----------+      |     via ID_EX_reg
 *   i_reg_write_w--->|                 +----------+     |
 *   i_rd_addr_w  --->|                 | EXTEND   |     |
 *   i_result_w   --->|                 +----------+     |
 *                    +----------------------------------+
 */

`timescale 1ns / 1ps

module decode_stage #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 5,
    parameter PC_WIDTH = 10
) (
    // Clock and Reset
    input logic i_clk,
    input logic i_rst_n,
    
    input logic i_flush_e,

    // Input from IF/ID pipeline register
    input logic [DATA_WIDTH-1:0] i_instr_d,     
    input logic [PC_WIDTH-1:0] i_pc_d,        
    input logic [PC_WIDTH-1:0] i_pc4_d,       
    
    // Writeback inputs (from WB stage)
    input logic                     i_reg_write_w, 
    input logic [ADDR_WIDTH-1:0]    i_rd_addr_w,   
    input logic [DATA_WIDTH-1:0]    i_result_w,    
    
    // ALU zero flag input
    input logic i_zero_e,
    
    // Control signals
    output logic        o_regwrite_e,
    output logic [1:0]  o_resultsrc_e,
    output logic        o_memwrite_e,
    output logic        o_jump_e,
    output logic        o_branch_e,
    output logic [2:0]  o_aluctrl_e,
    output logic        o_alusrc_e,
    
    // Data outputs
    output logic [DATA_WIDTH-1:0] o_rs1_data_e,
    output logic [DATA_WIDTH-1:0] o_rs2_data_e,
    output logic [PC_WIDTH-1:0] o_pc_e,
    
    // Instruction fields
    output logic [ADDR_WIDTH-1:0] o_rs1_addr_e,
    output logic [ADDR_WIDTH-1:0] o_rs2_addr_e,
    output logic [ADDR_WIDTH-1:0] o_rd_addr_e,
    
    // Extended immediate and PC+4
    output logic [DATA_WIDTH-1:0] o_immext_e,
    output logic [PC_WIDTH:0] o_pc4_e,
    
    // PC source output (for fetch stage)
    output logic o_pcsrc_e
);

    // Internal signals - Instruction field extraction
    logic [6:0]             l_opcode;
    logic [2:0]             l_funct3;
    logic                   l_funct7b5;
    logic [ADDR_WIDTH-1:0]  l_rs1_addr;
    logic [ADDR_WIDTH-1:0]  l_rs2_addr;
    logic [ADDR_WIDTH-1:0]  l_rd_addr;
    
    // Controller outputs
    logic [2:0]             l_aluctrl_d;
    logic [1:0]             l_resultsrc_d;
    logic [1:0]             l_immsrc_d;
    logic                   l_memwrite_d;
    logic                   l_alusrc_d;
    logic                   l_regwrite_d;
    logic                   l_jump_d;
    logic                   l_branch_d;
    
    // Register file outputs
    logic [DATA_WIDTH-1:0] l_rs1_data_d;
    logic [DATA_WIDTH-1:0] l_rs2_data_d;
    
    // Immediate extender output
    logic [DATA_WIDTH-1:0] l_immext_d;
    
    // Extract instruction fields
    assign l_opcode   =   i_instr_d[6:0];
    assign l_funct3   =   i_instr_d[14:12];
    assign l_funct7b5 =   i_instr_d[30];
    assign l_rs1_addr =   i_instr_d[19:15];
    assign l_rs2_addr =   i_instr_d[24:20];
    assign l_rd_addr  =   i_instr_d[11:7];
    
    // Controller instance
    controller u_controller (
        .i_op           (l_opcode),
        .i_funct3       (l_funct3),
        .i_funct7b5     (l_funct7b5),
        .o_alucrtl      (l_aluctrl_d),
        .o_resultsrc    (l_resultsrc_d),
        .o_immsrc       (l_immsrc_d),
        .o_memwrite     (l_memwrite_d),
        .o_alusrc       (l_alusrc_d),
        .o_regwrite     (l_regwrite_d),
        .o_jump         (l_jump_d),
        .o_branch       (l_branch_d)
    );
    
    // Register file instance
    regfile #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_regfile (
        .i_clk          (i_clk),
        .i_rst_n        (i_rst_n),
        .i_reg_write    (i_reg_write_w),
        .i_rs1_addr     (l_rs1_addr),
        .i_rs2_addr     (l_rs2_addr),
        .i_rd_addr      (i_rd_addr_w),
        .i_rd_data      (i_result_w),
        .o_rs1_data     (l_rs1_data_d),
        .o_rs2_data     (l_rs2_data_d)
    );
    
    // Immediate extender instance
    extend u_extend (
        .i_instr    (i_instr_d[31:7]),
        .i_immsrc   (l_immsrc_d),
        .o_immext   (l_immext_d)
    );
    
    // ID/EX pipeline register - integrated into decode_stage
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n | i_flush_e) begin
            o_regwrite_e    <= 1'b0;
            o_resultsrc_e   <= 2'b00;
            o_memwrite_e    <= 1'b0;
            o_jump_e        <= 1'b0;
            o_branch_e      <= 1'b0;
            o_aluctrl_e     <= 3'b000;
            o_alusrc_e      <= 1'b0;
            
            o_rs1_data_e <= {DATA_WIDTH{1'b0}};
            o_rs2_data_e <= {DATA_WIDTH{1'b0}};
            o_pc_e       <= {PC_WIDTH{1'b0}};
            
            o_rs1_addr_e <= {ADDR_WIDTH{1'b0}};
            o_rs2_addr_e <= {ADDR_WIDTH{1'b0}};
            o_rd_addr_e  <= {ADDR_WIDTH{1'b0}};
            
            o_immext_e  <=  {DATA_WIDTH{1'b0}};
            o_pc4_e     <=  {PC_WIDTH{1'b0}};
        end else begin
            // Latch control signals from decode stage
            o_regwrite_e    <= l_regwrite_d;
            o_resultsrc_e   <= l_resultsrc_d;
            o_memwrite_e    <= l_memwrite_d;
            o_jump_e        <= l_jump_d;
            o_branch_e      <= l_branch_d;
            o_aluctrl_e     <= l_aluctrl_d;
            o_alusrc_e      <= l_alusrc_d;
            
            // Latch data signals from decode stage
            o_rs1_data_e    <= l_rs1_data_d;
            o_rs2_data_e    <= l_rs2_data_d;
            o_pc_e          <= i_pc_d;
            
            // Latch address signals from decode stage
            o_rs1_addr_e    <= l_rs1_addr;
            o_rs2_addr_e    <= l_rs2_addr;
            o_rd_addr_e     <= l_rd_addr;
            
            // Latch immediate and PC+4 from decode stage
            o_immext_e      <= l_immext_d;
            o_pc4_e         <= i_pc4_d;
        end
    end    

    assign o_pcsrc_e = o_branch_e & i_zero_e | o_jump_e;

endmodule