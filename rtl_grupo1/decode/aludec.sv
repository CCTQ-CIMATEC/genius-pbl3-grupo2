`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: David Machado Couto Bezerra
// 
// Create Date: 05/19/2025
// Module Name: aludec
// Project Name: SYNGLE_CYCLE
// Tool Versions: 1.0
// Description: ALU decoder for RISC-V single-cycle CPU.
//
// Additional Comments: Decodes ALU operations based on 
//                      ALUOp, funct3, funct7, and opcode[5].
//////////////////////////////////////////////////////////////////////////////////

/**
    PBL3 - RISC-V Single Cycle Processor
    ALU Control Decoder Module

    File name: aludec.sv

    Objective:
        Decode the ALU control signals based on the instruction type and function fields.
        Translates RISC-V instruction fields into specific ALU operations.
        Determines the ALU operation based on instruction type and fields

    Specification:
        - Supports RV32I base instruction set
        - Decodes ALU operations for:
            * R-type instructions (ADD, SUB, AND, OR, SLT)
            * I-type instructions (ADDI, ANDI, ORI, SLTI)
            * Branch instructions (BEQ, BNE)
        - Uses funct3, funct7, and ALUOp fields to determine operation
        - Generates 3-bit ALU control signal

    Operations:
        - ADD/ADDI:   000
        - SUB:        001
        - AND/ANDI:   010
        - OR/ORI:     011
        - SLT/SLTI:   101

    Functional Diagram:

                       +------------------+
                       |                  |
        i_opb5     --->|                  |
        i_funct3   --->|   ALU Control    |---> o_alucrtl[2:0]
        i_funct7b5 --->|     Decoder      |
        i_aluop    --->|                  |
                       +------------------+

    Inputs:
        i_opb5       - Bit 5 of opcode (helps distinguish R-type instructions)
        i_funct3[2:0] - Function field 3 (from instruction)
        i_funct7b5   - Bit 5 of funct7 field (identifies SUB instruction)
        i_aluop[1:0]  - Higher-level ALU control from main decoder:
                        * 2'b00: Addition (for loads/stores)
                        * 2'b01: Subtraction (for branches)
                        * 2'b10: Use funct3/funct7 (for R/I-type)

    Outputs:
        o_alucrtl[2:0] - ALU control signal:
                        * 3'b000: ADD
                        * 3'b001: SUB
                        * 3'b010: AND
                        * 3'b011: OR
                        * 3'b101: SLT

    Control Logic:
        - For R-type instructions, examines both funct3 and funct7 fields
        - For I-type instructions, uses only funct3 field
        - For memory/branch instructions, uses ALUOp directly
**/

//----------------------------------------------------------------------------- 
//  ALU Decoder Module
//-----------------------------------------------------------------------------
`timescale 1ns / 1ps  // Set simulation time unit to 1ns, precision to 1ps
module aludec
(
    input logic         i_opb5,         // Bit 5 of the opcode (used to identify R-type)
    input logic [2:0]   i_funct3,       // funct3 field from instruction
    input logic         i_funct7b5,     // Bit 5 of funct7 field (for R-type instructions)
    input logic [1:0]   i_aluop,        // ALUOp from main decoder (determines instruction type)
    output logic [2:0]  o_alucrtl       // ALU control output
);

    // Internal signal to identify R-type subtract operation
    logic l_rtypesub;
    // R-type subtract is identified when both i_funct7b5 and i_opb5 are 1
    assign l_rtypesub = i_funct7b5 & i_opb5; // TRUE R-type subtract

    // Combinational logic for ALU control
    always_comb begin
        case (i_aluop)
            2'b00:  o_alucrtl = 3'b000; // addition (for loads, stores, etc.)
            2'b01:  o_alucrtl = 3'b001; // subtraction (for branches)
            default:
                // For R-type and I-type instructions (when ALUOp = 1x)
                case (i_funct3)
                    3'b000:                         // ADD/SUB or ADDI
                        if(l_rtypesub)
                            o_alucrtl = 3'b001;     // sub (R-type)
                        else
                            o_alucrtl = 3'b000;     // add (R-type), addi (I-type)
                    
                    3'b010:     o_alucrtl = 3'b101; // slt (set less than), slti
                    3'b100:     o_alucrtl = 3'b100; // xor
                    3'b110:     o_alucrtl = 3'b011; // or, ori
                    3'b111:     o_alucrtl = 3'b010; // and, andi
                    default:    o_alucrtl = 3'bxxx; // undefined operation    
                endcase
        endcase
    end

endmodule