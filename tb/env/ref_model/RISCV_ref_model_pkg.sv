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

  typedef struct {
    logic [4:0]  rd;
    logic [31:0] value;
    bit          we;
  } wb_info_t;

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
    Enum: imm_src_t
    Description:
         Encodes the type of immediate field to be used for sign-extension,
         based on RISC-V instruction formats (I-type, S-type, B-type, J-type).
    */
        typedef enum logic [2:0] {
            IMM_I = 3'b000,  // I-type immediate (e.g., ADDI, LW)
            IMM_IS = 3'b001, //I-type - Shifts by constant are encoded as specialization of I-type
            IMM_S = 3'b010,  // S-type immediate (e.g., SW)
            IMM_B = 3'b011,  // B-type immediate (e.g., BEQ, BNE)
            IMM_U = 3'b100,  // U-type immediate (e.g., LUI, AUIPC)
            IMM_J = 3'b101   // J-type immediate (e.g., JAL)
        } imm_src_t;
    
    /**
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
        
  `include "RISCV_ref_model.sv"

endpackage

`endif



