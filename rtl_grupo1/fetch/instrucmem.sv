/**
    PBL3 - RISC-V Single Cycle Processor  
    Instruction Memory Module

    File name: instrucmem.sv

    Objective:
        Implement a byte-addressable instruction memory for RISC-V processor.
        Provides read-only storage for program instructions with word-aligned access.

        A parameterized instruction memory module supporting configurable address space.

    Specification:
        - Configurable memory size via address width parameter
        - Word-aligned access (32-bit instructions)
        - Read-only operation (ROM behavior)
        - Byte address to word address conversion
        - Fully synthesizable (initialized as ROM)

    Functional Diagram:

                        +----------------------+
        i_pc[AW-1:0]--->|                      |
                        |  INSTRUCTION MEMORY  |
                        |                      |---> o_instr[31:0]
                        +----------------------+

    Parameters:
        P_DATA_WIDTH - Instruction width in bits (fixed at 32 for RISC-V)
        P_ADDR_WIDTH - Byte address width (determines memory size = 2^AW bytes)
                       Critical parameter that defines:
                       - Total addressable memory space
                       - ROM array depth (2^(AW-2) words)
                       Default of 10 gives 1KB memory (256 words)

    Inputs:
        i_pc - Program counter address (byte address, width = P_ADDR_WIDTH)

    Outputs:
        o_instr - Instruction word read from memory (width = P_DATA_WIDTH)

    Memory Organization:
        - Implemented as 2^(P_ADDR_WIDTH-2) words of 32 bits each
        - Byte address converted to word address by dropping 2 LSBs
        - Example: P_ADDR_WIDTH=10 → 256 words (1KB total)

    Timing Characteristics:
        - Combinational read path (no clock)
        - Address to output delay critical for processor cycle time

    Operation:
        - Continuous assignment: Output reflects addressed word
        - Address conversion: i_pc[AW-1:2] selects word
        - Unused address bits ignored (no memory protection)

    Typical Usage:
        - Stores program instructions in single-cycle processor
        - Connected directly to program counter
        - Base memory for Harvard architecture implementations

    Implementation Notes:
        - Actual storage implemented as synthesizable ROM array
        - Larger P_ADDR_WIDTH increases memory capacity but requires more resources
        - Must match program counter width in processor datapath
**/

//----------------------------------------------------------------------------- 
//  instruction Memory Module
//-----------------------------------------------------------------------------
`timescale 1ns / 1ps  // Set simulation time unit to 1ns, precision to 1ps
module instrucmem #(
    parameter P_DATA_WIDTH = 32,                // Word size (4 bytes)
    parameter P_ADDR_WIDTH = 10                 // Byte address width (1024 bytes)
)(
    input  logic [P_ADDR_WIDTH-1:0] i_pc,       // 10-bit PC counter address
    output logic [P_DATA_WIDTH-1:0] o_instr     // 32-bit data instruction
);
    // 1KB memory: 256 words (32-bit each)
    logic [P_DATA_WIDTH-1:0] l_rom [0:255];     // 256 words = 2^8
                                                // To access a 32-bit word in ROM, 
                                                // we need to ignore the 2 least s
                                                // ignificant bits by discarding 
                                                // the 2 LSBs (i_pc[1:0])

    // Convert byte address to word address (divide by 4)
    assign o_instr = l_rom[i_pc[P_ADDR_WIDTH-1:2]];

endmodule