/**
    PBL3 - RISC-V Single Cycle Processor
    Main Control Decoder Module

    File name: maindec.sv

    Objective:
        Decode RISC-V instruction opcodes into control signals for the datapath.
        Generates all primary control signals for the single-cycle processor.

    Specification:
        - Supports RV32I base instruction set
        - Decodes all major instruction formats (R, I, S, B, J)
        - Generates 11 control signals from 7-bit opcode
        - Pure combinational logic

    Functional Diagram:

                       +------------------+
                       |                  |
        i_op[6:0] ---->|                  |---> o_regwrite
                       |   MAIN CONTROL   |---> o_immsrc
                       |     DECODER      |---> o_alusrc
                       |                  |---> o_memwrite
                       |                  |---> o_resultsrc
                       |                  |---> o_branch
                       |                  |---> o_aluop
                       |                  |---> o_jump
                       +------------------+

    Inputs:
        i_op[6:0] - 7-bit opcode field from instruction word

    Outputs:
        o_regwrite   - Register file write enable (1 = write)
        o_immsrc[1:0] - Immediate format selector:
                       * 00: I-type
                       * 01: S-type
                       * 10: B-type
                       * 11: J-type
        o_alusrc     - ALU operand B source (0 = register, 1 = immediate)
        o_memwrite   - Data memory write enable (1 = write)
        o_resultsrc[1:0] - Result source selector:
                          * 00: ALU result
                          * 01: Memory read data
                          * 10: PC+4 (for JAL)
        o_branch     - Branch instruction indicator (1 = branch)
        o_aluop[1:0] - High-level ALU operation:
                      * 00: memory access (lw/sw)
                      * 01: branch comparison
                      * 10: R-type/I-type ALU operation
        o_jump       - Jump instruction indicator (1 = jump)

    Instruction Decoding:
        Opcode       | Instruction Type | Control Vector
        ------------ | ---------------- | --------------------------
        7'b0000011   | LW (I-type)      | 1_00_1_0_01_0_00_0
        7'b0100011   | SW (S-type)      | 0_01_1_1_00_0_00_0
        7'b0110011   | R-type           | 1_xx_0_0_00_0_10_0
        7'b1100011   | BEQ (B-type)     | 0_10_0_0_00_1_01_0
        7'b0010011   | I-type ALU       | 1_00_1_0_00_0_10_0
        7'b1101111   | JAL (J-type)     | 1_11_0_0_10_0_00_1

    Operation:
        - Decodes 7-bit opcode into 11-bit control vector
        - Splits control vector into individual signals
        - Handles undefined opcodes with 'x' outputs
**/

//----------------------------------------------------------------------------- 
//   Main Control Decode Module
//-----------------------------------------------------------------------------
`timescale 1ns / 1ps  // Set simulation time unit to 1ns, precision to 1ps
module maindec(
    input  logic [6:0] i_op,           // 7-bit opcode field from instruction
    output logic [1:0] o_resultsrc,    // Result source selection
    output logic       o_memwrite,     // Memory write enable
    output logic       o_branch,       // Branch instruction flag
    output logic       o_alusrc,       // ALU source selection
    output logic       o_regwrite,     // Register write enable
    output logic       o_jump,         // Jump instruction flag
    output logic [1:0] o_immsrc,       // Immediate format selection
    output logic [1:0] o_aluop         // ALU operation type
);
    
    // Internal 11-bit control vector that gets split into individual outputs
    logic [10:0] l_controls;

    // Concatenated output assignment (matches bit positions in control vector)
    assign {o_regwrite, o_immsrc, 
            o_alusrc, o_memwrite, 
            o_resultsrc, o_branch, 
            o_aluop, o_jump} = l_controls;

    // Instruction decoding logic
    always_comb begin   
        case (i_op)
            // Format: RegWrite_ImmSrc_ALUSrc_MemWrite_ResultSrc_Branch_ALUOp_Jump
            
            // Load Word (LW) - I-type
            7'b0000011: l_controls = 11'b1_00_1_0_01_0_00_0; 
            
            // Store Word (SW) - S-type
            7'b0100011: l_controls = 11'b0_01_1_1_00_0_00_0; 
            
            // R-type instructions (ADD, SUB, etc.)
            7'b0110011: l_controls = 11'b1_00_0_0_00_0_10_0; 
            
            // Branch Equal (BEQ) - B-type
            7'b1100011: l_controls = 11'b0_10_0_0_00_1_01_0; 
            
            // I-type ALU operations (ADDI, ANDI, etc.)
            7'b0010011: l_controls = 11'b1_00_1_0_00_0_10_0; 
            
            // Jump and Link (JAL) - J-type
            7'b1101111: l_controls = 11'b1_11_0_0_10_0_00_1; 
            
            // Default case (undefined opcode)
            default:    l_controls = 11'b0_00_0_0_00_0_00_0; 
        endcase
    end

endmodule