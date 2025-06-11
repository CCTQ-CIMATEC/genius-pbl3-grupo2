/**
    PBL3 - RISC-V Single Cycle Processor
        Adder module for RISC-V processor implementation
        File name: adder.sv

        Parameterized Adder Module
        Implements a simple combinatorial adder with configurable bit-width

    File name: adder.sv

    Objective:
        Implement a parameterized adder that can handle different bit widths
        - Supports unsigned addition
        - Zero-delay combinatorial operation

    Specification:
        - Configurable bit width via parameter
        - Pure combinatorial logic
        - No overflow detection
        - No carry-in or carry-out

    Operations:
        - Continuous addition: Output o_y always reflects the sum of i_a and i_b
        - Bit-width handling: Supports any width determined by P_WIDTH parameter
        - Propagation: Changes on inputs immediately affect output (combinatorial logic)

    Functional Diagram:

                            +-------------+
                            |   MODULE    |
        i_a [P_WIDTH:0] --->|   ADDER     |
        i_b [P_WIDTH:0] --->|             |---> o_y [P_WIDTH:0]
                            |             |
                            +-------------+

    Inputs:
        i_a - First operand (P_WIDTH+1 bits)
        i_b - Second operand (P_WIDTH+1 bits)

    Outputs:
        o_y - Sum of i_a and i_b (P_WIDTH+1 bits)

    Parameters:
        P_WIDTH - Bit width of operands (default = 32)

*/

//----------------------------------------------------------------------------- 
// Adder Module
//-----------------------------------------------------------------------------
`timescale 1ns / 1ps  // Set simulation time unit to 1ns, precision to 1ps
module adder #(
    parameter P_WIDTH = 32  // Default width is 32 bits (configurable)
    
) (
    // Input Ports
    input  logic [P_WIDTH:0] i_a,  // First operand (width = P_WIDTH+1 bits)
    input  logic [P_WIDTH:0] i_b,  // Second operand (width = P_WIDTH+1 bits)
    
    // Output Ports
    output logic [P_WIDTH:0] o_y   // Sum output (width = P_WIDTH+1 bits)
);

    // Combinational Logic
    // --------------------------------------------
    // Continuous assignment: 
    // - Output o_y immediately updates when i_a or i_b changes
    // - Note: No overflow detection/carry-out 
    assign o_y = i_a + i_b;

endmodule