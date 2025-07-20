//------------------------------------------------------------------------------
// Package for RISCV reference model components
//------------------------------------------------------------------------------
// This package includes the reference model components for the RISCV verification.
//
// Author: Gustavo Santiago
// Date  : June 2025
//------------------------------------------------------------------------------

`ifndef RISCV_REF_MODEL_PKG
`define RISCV_REF_MODEL_PKG

package RISCV_ref_model_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    /*
     * Importing packages: agent, ref model, register, etc.
     */
    import RISCV_agent_pkg::*;

    /*
     * Enum: opcodeType
     * Description: RISC-V instruction opcodes
     */
    typedef enum logic [6:0] {
        // ------------------------------------------------------------
        // U-Type Instructions (Upper Immediate)
        // ------------------------------------------------------------
        LUI    = 7'b0110111,  // Load Upper Immediate
        AUIPC  = 7'b0010111,  // Add Upper Immediate to PC

        // ------------------------------------------------------------
        // J-Type Instructions (Jumps)
        // ------------------------------------------------------------
        JAL    = 7'b1101111,  // Jump and Link

        // ------------------------------------------------------------
        // I-Type Instructions (Jumps and Immediate ALU)
        // ------------------------------------------------------------
        JALR   = 7'b1100111,  // Jump and Link Register

        // ------------------------------------------------------------
        // B-Type Instructions (Conditional Branches)
        // All branch instructions share the same opcode.
        // ------------------------------------------------------------
        BRCH_S = 7'b1100011,  // Branch instruction set (e.g., BEQ, BNE, BLT, BGE, etc.)

        // ------------------------------------------------------------
        // I-Type Instructions (Memory Load)
        // All load instructions share the same opcode.
        // ------------------------------------------------------------
        LOAD_S = 7'b0000011,  // Load instruction set (e.g., LB, LH, LW, LBU, LHU)

        // ------------------------------------------------------------
        // S-Type Instructions (Memory Store)
        // All store instructions share the same opcode.
        // ------------------------------------------------------------
        STORE_S = 7'b0100011, // Store instruction set (e.g., SB, SH, SW)

        // ------------------------------------------------------------
        // I-Type Instructions (ALU with Immediate)
        // All immediate ALU operations share the same opcode.
        // ------------------------------------------------------------
        ALUI_S = 7'b0010011,  // ALU operations with immediate (e.g., ADDI, ANDI, ORI, etc.)

        // ------------------------------------------------------------
        // R-Type Instructions (Register-Register ALU)
        // All register-based ALU operations share the same opcode.
        // ------------------------------------------------------------
        ALU_S  = 7'b0110011   // ALU operations with registers (e.g., ADD, SUB, AND, OR, etc.)
    } opcodeType;
    
    /*
     * Enum: aluOpType
     * Description:
     *     Specifies the operation type used by the ALU, based on RISC-V
     *     instruction formats and function codes (funct7/funct3 combinations).
     *     Also includes pseudo-operations for comparisons and bypassing.
     */
    typedef enum logic [3:0] {
        ALU_ADD    = 4'b0000, // funct7 = 0000000, funct3 = 000 (ADD)
        ALU_SLL    = 4'b0001, // funct7 = 0000000, funct3 = 001 (SLL)
        ALU_LT     = 4'b0010, // funct7 = 0000000, funct3 = 010 (SLT)
        ALU_LTU    = 4'b0011, // funct7 = 0000000, funct3 = 011 (SLTU)
        ALU_XOR    = 4'b0100, // funct7 = 0000000, funct3 = 100 (XOR)
        ALU_SRL    = 4'b0101, // funct7 = 0000000, funct3 = 101 (SRL)
        ALU_OR     = 4'b0110, // funct7 = 0000000, funct3 = 110 (OR)
        ALU_AND    = 4'b0111, // funct7 = 0000000, funct3 = 111 (AND)
        ALU_SUB    = 4'b1000, // funct7 = 0100000, funct3 = 000 (SUB)
        ALU_SRA    = 4'b1001, // funct7 = 0100000, funct3 = 101 (SRA)
        ALU_BPS2   = 4'b1010, // Bypass source 2
        ALU_EQUAL  = 4'b1011, // Equal comparison (==)
        ALU_NEQUAL = 4'b1100, // Not equal (!=)
        ALU_GT     = 4'b1101, // Signed Greater/Equal than (>=)
        ALU_GTU    = 4'b1111  // Unsigned Greater/Equal than (>=)
    } aluOpType;

    /*
     * Struct: pipeline_reg_t
     * Description: Pipeline register structure containing all pipeline stage information
     */
    typedef struct {
        bit        valid;          // Valid flag
        bit [31:0] pc;            // Program counter
        bit [31:0] instr;         // Instruction
        bit [31:0] rs1_val;       // RS1 value
        bit [31:0] rs2_val;       // RS2 value
        bit [31:0] imm;           // Immediate value
        bit [4:0]  rd;            // Destination register
        bit        reg_write;     // Register write enable
        bit [31:0] alu_result;    // ALU result
        bit [31:0] mem_data;      // Memory data
        bit        mem_read;      // Memory read enable
        bit        mem_write;     // Memory write enable
        bit        jump;          // Jump flag
        bit        alu_src1;      // ALU source 1 select
        bit        alu_src2;      // ALU source 2 select
        bit        branch_taken;   // Branch taken flag
        bit [31:0] branch_target;  // Branch target address
        aluOpType  alu_opcode;    // ALU operation code
    } pipeline_reg_t;
        
    // Reset value for pipeline registers
    const pipeline_reg_t RESET_PIPELINE_REG = '{
        valid:         0,
        pc:           0,
        instr:        0,
        rs1_val:      0,
        rs2_val:      0,
        imm:          0,
        rd:           0,
        reg_write:    0,
        alu_result:   0,
        mem_data:     0,
        mem_read:     0,
        mem_write:    0,
        jump:         0,
        alu_src1:     0,
        alu_src2:     0,
        branch_taken: 0,
        branch_target: 0,
        alu_opcode:    ALU_ADD  // Default valid value
    };

    `include "RISCV_ref_model.sv"

endpackage

`endif