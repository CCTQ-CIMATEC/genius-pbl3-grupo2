/**
    PBL3 - RISC-V Single Cycle Processor
    Immediate Value Extender Module

    File name: extend.sv

    Objective:
        Extract and sign-extend immediate values from RISC-V instructions.
        Handles all RISC-V immediate formats required for the RV32I instruction set.

        Extracts and sign-extends immediate values from instruction fields
    
    Specification:
        - Supports all RISC-V immediate formats (I-type, S-type, B-type, J-type)
        - Performs proper sign extension for all immediate values
        - Handles special alignment requirements for branch and jump targets
        - Pure combinational logic

    Functional Diagram:

                       +------------------+
                       |      MODULE      |
        i_instr[31:7]->|     IMMEDIATE    |
        i_immsrc[1:0]->|     EXTENDER     |--> o_immext[31:0]
                       |                  |
                       +------------------+

    Inputs:
        i_instr[31:7] - Relevant instruction bits containing immediate fields
        i_immsrc[1:0] - Immediate type selector:
                        * 2'b00: I-type (ADDI, LW, etc.)
                        * 2'b01: S-type (SW)
                        * 2'b10: B-type (BEQ, BNE)
                        * 2'b11: J-type (JAL)

    Outputs:
        o_immext[31:0] - 32-bit sign-extended immediate value

    Immediate Formats:
        I-type: [31:20] -> 12-bit immediate (sign-extended)
        S-type: [31:25] + [11:7] -> 12-bit immediate (combined and sign-extended)
        B-type: [7] + [30:25] + [11:8] + 0 -> 13-bit immediate (aligned to 2 bytes)
        J-type: [19:12] + [20] + [30:21] + 0 -> 21-bit immediate (aligned to 2 bytes)

    Operation:
        - Decodes immediate format based on i_immsrc
        - Extracts relevant instruction bits
        - Performs sign extension by replicating MSB
        - For B/J-types, adds implicit 0 in LSB for proper alignment
**/

//----------------------------------------------------------------------------- 
//  Immediate Value Extender Module
//-----------------------------------------------------------------------------
`timescale 1ns / 1ps  // Set simulation time unit to 1ns, precision to 1ps
module extend (
    input  logic [31:7] i_instr,
    input  logic [1:0]  i_immsrc,    //tipo da i_instrução
    output logic [31:0] o_immext     //imediato estendido (sinalizado)
);

    always_comb begin
        case (i_immsrc)
            // I-type (ex: LW, ADDI)
            2'b00: o_immext = {{20{i_instr[31]}}, i_instr[31:20]};

            // S-type (ex: SW)
            2'b01: o_immext = {{20{i_instr[31]}}, i_instr[31:25], i_instr[11:7]};

            // B-type (ex: BEQ, BNE)
            2'b10: o_immext = {{20{i_instr[31]}}, i_instr[7], i_instr[30:25], i_instr[11:8], 1'b0};

            // J-type (ex: JAL)
            2'b11: o_immext = {{12{i_instr[31]}}, i_instr[19:12], i_instr[20], i_instr[30:21], 1'b0};

            default: o_immext = 32'bx; // indefinido
        endcase
    end

endmodule