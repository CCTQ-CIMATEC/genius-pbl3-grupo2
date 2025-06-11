/**
  PBL3 - RISC-V Single Cycle Processor
  Controller Module
 
  File name: controller.sv
 
  Objective:
     Implements the main control unit and ALU control logic for a RISC-V processor.
     Generates all control signals based on the instruction opcode and funct fields.
 
  Description:
     - Decodes RISC-V instructions to produce control signals
     - Uses a main decoder for primary control signals
     - Uses an ALU decoder for ALU operation control
     - Combines branch and zero conditions for PC source control
 
  Functional Diagram:
 
                   +----------------------------+
                   |        CONTROLLER          |
                   |                            |
  i_op[6:0]    --->|  +----------+ +---------+  |
  i_funct3[2:0]--->|  |  maindec | |  Aludec |  |---> o_alucrtl[2:0]
  i_funct7b5   --->|  +----------+ +---------+  |---> o_resultsrc[1:0]
  i_zero       --->|                            |---> o_immsrc[1:0]
                   |                            |---> o_memwrite
                   |                            |---> o_pcsrc
                   |                            |---> o_alusrc
                   |                            |---> o_regwrite
                   |                            |---> o_jump
                   +----------------------------+

    Inputs:
        input logic [6:0] i_op,             - 7-bit opcode field from instruction
        input logic [2:0] i_funct3,         - 3-bit funct3 field from instruction
        input logic       i_funct7b5,       - funct7 bit 5 (for R-type instructions)
        input logic       i_zero,           - Zero flag from ALU (for branch instructions)
    
    Outputs:
        output logic [2:0] o_alucrtl,       - 3-bit ALU control signal
        output logic [1:0] o_resultsrc,     - Result multiplexer select (for writeback)
        output logic [1:0] o_immsrc,        - Immediate format select
        output logic       o_memwrite,      - Data memory write enable
        output logic       o_pcsrc,         - PC source select (branch/jump)
        output logic       o_alusrc,        - ALU source select (reg/immediate)
        output logic       o_regwrite,      - Register file write enable
        output logic       o_jump           - Jump instruction flag
 */

//----------------------------------------------------------------------------- 
//  Controller Module
//-----------------------------------------------------------------------------
`timescale 1ns / 1ps  // Set simulation time unit to 1ns, precision to 1ps
module controller(
    // Inputs
    input logic [6:0] i_op,             // 7-bit opcode field from instruction
    input logic [2:0] i_funct3,         // 3-bit funct3 field from instruction
    input logic       i_funct7b5,       // funct7 bit 5 (for R-type instructions)
//  input logic       i_zero,           // Zero flag from ALU (for branch instructions)
    
    // Outputs
    output logic [2:0] o_alucrtl,       // 3-bit ALU control signal
    output logic [1:0] o_resultsrc,     // Result multiplexer select (for writeback)
    output logic [1:0] o_immsrc,        // Immediate format select
    output logic       o_memwrite,      // Data memory write enable
    //output logic       o_pcsrc,         // PC source select (branch/jump)
    output logic       o_alusrc,        // ALU source select (reg/immediate)
    output logic       o_regwrite,      // Register file write enable
    output logic       o_jump,          // Jump instruction flag
    output logic       o_branch      
);
    
    // Local signals/variables
    logic [1:0] r_aluop;                // ALU operation type from main decoder
    logic       i_opb5;                 // Opcode bit 5 (used for ALU decoding)

    // Main decoder instance
    maindec md (
        .i_op           (i_op),         // Instruction opcode
        .o_resultsrc    (o_resultsrc),  // Result source
        .o_memwrite     (o_memwrite),   // Memory write enable
        .o_branch       (o_branch),     // Branch instruction
        .o_alusrc       (o_alusrc),     // ALU source select
        .o_regwrite     (o_regwrite),   // Register write enable
        .o_jump         (o_jump),       // Jump instruction
        .o_immsrc       (o_immsrc),     // Immediate format
        .o_aluop        (r_aluop)       // ALU operation type
    );

    // ALU decoder instance
    aludec ad(
        .i_opb5     (i_opb5),           // Opcode bit 5
        .i_funct3   (i_funct3),         // funct3 field
        .i_funct7b5 (i_funct7b5),       // funct7 bit 5
        .i_aluop    (r_aluop),          // ALU operation type
        .o_alucrtl  (o_alucrtl)         // ALU control output
    );

    // Extract opcode bit 5
    assign i_opb5 = i_op[5];

    // PC source logic: branch & zero (for beq) OR jump (for jal)
    // assign o_pcsrc = l_branch & i_zero | o_jump; somente no EXECUTE

endmodule