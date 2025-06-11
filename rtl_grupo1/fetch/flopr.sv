/**
    PBL3 - RISC-V Single Cycle Processor  
    Resettable Flip-Flop Module

    File name: flopr.sv

    Objective:
        Implement a parameterized-width flip-flop with asynchronous active-low reset.
        Provides basic sequential storage element for the processor datapath.

        A parameterized width flip-flop with asynchronous active-low reset

    Specification:
        - Configurable data width via parameter
        - Positive-edge triggered
        - Asynchronous active-low reset
        - Reset clears all bits to 0
        - Fully synthesizable

    Functional Diagram:

                       +------------------+
        i_d[W-1:0] -->|                  |
        i_clk      -->|                  |--> o_q[W-1:0]
        i_rst_n    -->|     FLOPR        |
                       +------------------+

    Parameters:
        P_WIDTH - Data width in bits (default = 32)

    Inputs:
        i_clk     - Clock signal (positive edge triggered)
        i_rst_n   - Asynchronous active-low reset
        i_d       - Data input (width = P_WIDTH)

    Outputs:
        o_q       - Registered output (width = P_WIDTH)

    Timing Characteristics:
        - Setup time: Data must be stable before clock rising edge
        - Hold time: Data must remain stable after clock rising edge
        - Reset recovery: Reset must be deasserted sufficiently before clock edge

    Operation:
        - On reset (i_rst_n=0): Output clears to 0
        - On clock rising edge: Output updates to input value
        - Otherwise: Output maintains previous value

    Typical Usage:
        - Program counter register
        - Pipeline registers
        - State machine state storage
**/

//----------------------------------------------------------------------------- 
// Resettable Flip-Flop Module
//-----------------------------------------------------------------------------
`timescale 1ns / 1ps  // Set simulation time unit to 1ns, precision to 1ps
module flopr #(
    parameter P_WIDTH = 32  // Default width is 32 bits (configurable)
)(
    input  logic               i_clk,    // Clock input
    input  logic               i_rst_n,  // Active-low asynchronous reset
    input  logic               i_en,     // Enable
    input  logic [P_WIDTH:0] i_d,      // Data input
    output logic [P_WIDTH:0] o_q       // Data output (registered)
);

    // Sequential logic block triggered on clock rising edge or reset falling edge
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        // Reset condition (active low)
        if (!i_rst_n)
            o_q <= '0;  // Clear all bits when reset is active
        else if(i_en)
            o_q <= i_d; // On clock edge, pass input to output
    end

endmodule