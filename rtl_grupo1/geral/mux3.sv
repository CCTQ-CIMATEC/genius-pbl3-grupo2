/**
    PBL3 - RISC-V Single Cycle Processor
    3-to-1 Multiplexer Module

    File name: mux3.sv

    Objective:
        Implement a parameterized 3-to-1 multiplexer with priority-based selection.
        Provides flexible data routing for processor writeback and data path control.

    Specification:
        - Configurable data width via parameter (default 32-bit)
        - Pure combinational logic implementation
        - Priority-based selection (i_sel[1] has highest priority)
        - Supports all RISC-V data path width requirements
        - Zero-delay simulation model
        - Fully synthesizable RTL

    Functional Diagram:

                       +-----------------+
        i_d0[W-1:0] -->|                 |
        i_d1[W-1:0] -->|      MUX3       |--> o_y[W-1:0]
        i_d2[W-1:0] -->|                 |
        i_sel[1:0]  -->|                 |
                       +-----------------+

    Parameters:
        DATA_WIDTH - Data bus width in bits (default = 32)

    Input Ports:
        i_d0[DATA_WIDTH-1:0] - Input data bus 0 (selected when i_sel=00)
        i_d1[DATA_WIDTH-1:0] - Input data bus 1 (selected when i_sel=01)
        i_d2[DATA_WIDTH-1:0] - Input data bus 2 (selected when i_sel=1X)

    Control Port:
        i_sel[1:0] - Selection control:
                    * 2'b00: selects i_d0
                    * 2'b01: selects i_d1
                    * 2'b1X: selects i_d2 (both 10 and 11 cases)

    Output Port:
        o_y[DATA_WIDTH-1:0] - Selected output data bus

    Selection Logic:
        o_y = i_sel[1] ? i_d2 : (i_sel[0] ? i_d1 : i_d0);

    Timing Characteristics:
        - Single-level combinational logic path
        - Propagation delay < 1ns in typical implementations
        - Glitch-free operation when inputs change

    Typical Usage:
        - Writeback stage result selection (ALU, memory, PC+4)
        - Pipeline hazard forwarding
        - Exception handling path selection
        - Multi-source operand selection

    Simulation:
        - Timescale set to 1ns/1ps for precise simulation
        - Zero-delay model for ideal combinational behavior
**/

//----------------------------------------------------------------------------- 
// Multiplexer 3x1 Module
//-----------------------------------------------------------------------------
`timescale 1ns / 1ps  // Sets simulation time unit to 1ns, precision to 1ps
module mux3 #(
    parameter DATA_WIDTH = 32  // Configurable data width (default 32 bits)
) (
    // Input Ports
    input logic [DATA_WIDTH-1:0]    i_d0,   // Input data bus 0
    input logic [DATA_WIDTH-1:0]    i_d1,   // Input data bus 1
    input logic [DATA_WIDTH-1:0]    i_d2,   // Input data bus 2
    
    // Control Port
    input logic [1:0]               i_sel,  // 2-bit selection control:
                                           // 00 = select i_d0
                                           // 01 = select i_d1
                                           // 1X = select i_d2 (10 or 11)
    
    // Output Port
    output logic [DATA_WIDTH-1:0]   o_y     // Selected output data bus
);

    // Combinational Logic
    // Priority-based selection using nested ternary operators:
    // - MSB (i_sel[1]) has highest priority (selects i_d2 when high)
    // - LSB (i_sel[0]) selects between remaining options when MSB is low
    assign o_y = i_sel[1] ? i_d2 :         // If i_sel[1] is 1, choose i_d2
                (i_sel[0] ? i_d1 : i_d0);  // Else choose i_d1 or i_d0

endmodule