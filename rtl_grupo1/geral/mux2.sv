/**
    PBL3 - RISC-V Single Cycle Processor
    2-to-1 Multiplexer Module

    File name: mux2.sv

    Objective:
        Implement a parameterized 2-to-1 multiplexer for selecting between two data buses.
        Provides flexible data path routing throughout the processor.

        Parameterized width multiplexer with binary selection

    Specification:
        - Configurable data width via parameter
        - Pure combinational logic
        - Single-cycle operation
        - Zero-delay simulation model
        - Fully synthesizable

    Functional Diagram:

                       +-----------+
        i_a[W-1:0] --->|           |
        i_b[W-1:0] --->|   MUX2    |---> o_y[W-1:0]
        i_sel      --->|           |
                       +-----------+

    Parameters:
        P_WIDTH - Data bus width in bits (default = 32)

    Inputs:
        i_a[P_WIDTH-1:0] - First input bus
        i_b[P_WIDTH-1:0] - Second input bus
        i_sel            - Selection control:
                          * 0: selects i_a
                          * 1: selects i_b

    Outputs:
        o_y[P_WIDTH-1:0] - Selected output bus

    Timing Characteristics:
        - Combinational path: i_sel to o_y
        - No clock involved
        - Glitch-free operation when inputs change

    Operation:
        o_y = i_sel ? i_b : i_a;

    Typical Usage:
        - ALU operand selection
        - PC source selection
        - Result forwarding
        - General data path routing

    Simulation:
        - Timescale set to 1ns/1ps for precise simulation
        - Zero-delay model for combinational behavior
**/

//----------------------------------------------------------------------------- 
// Multiplexer 2x1 Module Module
//-----------------------------------------------------------------------------
`timescale 1ns / 1ps  // Simulation time unit: 1ns, precision: 1ps

module mux2 #(
    parameter P_WIDTH = 32  // Default data width is 32 bits
)(
    input  logic [P_WIDTH:0] i_a,   // First input
    input  logic [P_WIDTH:0] i_b,   // Second input
    input  logic               i_sel, // Selection signal
    output logic [P_WIDTH:0] o_y    // Output
);

    // Combinational logic
    assign o_y = i_sel ? i_b : i_a;  // Select i_b when i_sel=1, otherwise i_a

endmodule