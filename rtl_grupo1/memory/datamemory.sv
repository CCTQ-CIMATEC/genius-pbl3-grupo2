/**
    PBL3 - RISC-V Single Cycle Processor  
    Data Memory Module

    File name: datamemory.sv

    Objective:
        Implement a synchronous-write, asynchronous-read data memory for RISC-V processors.
        Provides configurable memory size and data width for system integration.

        A parameterized RAM module with single read/write port and word-addressable access.

    Specification:
        - Configurable address space via P_ADDR_WIDTH
        - Configurable data width via P_DATA_WIDTH
        - Synchronous write (clocked)
        - Asynchronous read (combinational)
        - Single-port operation (reads and writes share same address bus)
        - Fully synthesizable RAM implementation

    Functional Diagram:

                       +------------------+
        i_addr[AW-1:0]->|                  |
        i_wdata[DW-1:0]->|                  |-> o_rdata[DW-1:0]
        i_we           ->|   DATA MEMORY    |
        i_clk         ->|                  |
                       +------------------+

    Parameters:
        P_ADDR_WIDTH - Address bus width (default = 8)
                       Determines memory depth: 2^AW words
                       Critical for:
                       - Total addressable memory (e.g., 8→256 words)
                       - Physical RAM resource utilization

        P_DATA_WIDTH - Data bus width (default = 32)
                       Sets word size in bits
                       Must match processor datapath width

    Inputs:
        i_clk    - System clock (positive edge triggered)
        i_we     - Write enable (1=write, 0=read)
        i_addr   - Word address input (width = P_ADDR_WIDTH)
        i_wdata  - Write data input (width = P_DATA_WIDTH)

    Outputs:
        o_rdata  - Read data output (width = P_DATA_WIDTH)

    Memory Organization:
        - Implemented as 2^P_ADDR_WIDTH words of P_DATA_WIDTH bits
        - Example: P_ADDR_WIDTH=8 → 256×32-bit memory (1KB)
        - Word-addressable (no byte addressing in this implementation)

    Timing Characteristics:
        - Write Operations:
            - Sampled on clock rising edge
            - Requires stable i_addr/i_wdata before clock edge
        - Read Operations:
            - Combinational path from i_addr to o_rdata
            - Critical for memory access time in processor cycle

    Operation:
        - Write Cycle (i_we=1):
            On clock rising edge: Stores i_wdata at i_addr
        - Read Cycle (i_we=0):
            o_rdata continuously shows contents of i_addr
        - No simultaneous read/write (single-port)

    Typical Usage:
        - Main data memory in RISC-V load/store unit
        - Connected to processor datapath via memory interface
        - Stores variables and data structures during execution

    Implementation Notes:
        - Actual implementation uses register-based RAM (for small memories)
        - For P_ADDR_WIDTH>10, consider block RAM resources
        - Read-during-write behavior: New writes not visible until next cycle
        - No memory initialization in this version (would need $readmemh for pre-load)

    RISC-V Specifics:
        - Word-aligned access (matches base ISA)
        - For byte/halfword access, wrap with byte enable logic
**/

//----------------------------------------------------------------------------- 
//  Data Memoory Module
//-----------------------------------------------------------------------------
`timescale 1ns / 1ps

module data_memory #(
    parameter P_ADDR_WIDTH = 8,
    parameter P_DATA_WIDTH = 32
)(
    input  logic                i_clk,         
    input  logic                i_we,        
    input  logic [P_ADDR_WIDTH-1:0] i_addr,     
    input  logic [P_DATA_WIDTH-1:0] i_wdata,    
    output logic [P_DATA_WIDTH-1:0] o_rdata   
);

    logic [P_DATA_WIDTH-1:0] mem_r [0:2**(P_ADDR_WIDTH)]; 


    assign o_rdata = mem_r[i_addr];

    always_ff @(posedge i_clk) begin
        if (i_we) begin
            mem_r[i_addr] <= i_wdata;
        end
    end

endmodule