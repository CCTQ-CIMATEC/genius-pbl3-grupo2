/**
    PBL3 - RISC-V Single Cycle Processor  
    Register File Module

    File name: regfile.sv

    Objective:
        Implement a RISC-V compliant register file with configurable data width
        and register count. Provides the processor's primary working registers.

        A parameterized register file with two read ports and one write port,
        implementing the RISC-V register file requirements (including x0 hardwired to zero).

    Specification:
        - Configurable data width via parameter
        - Configurable number of registers via address width parameter
        - Two asynchronous read ports
        - One synchronous write port
        - Register x0 hardwired to zero (RISC-V requirement)
        - Write-first behavior (bypasses newly written data to read ports)
        - Fully synthesizable

    Functional Diagram:

                       +----------------------+
        i_rs1_addr -->|                      |--> o_rs1_data
        i_rs2_addr -->|                      |--> o_rs2_data
        i_rd_addr  -->|     REGISTER FILE    |
        i_rd_data  -->|                      |
        i_reg_write ->|                      |
        i_clk      -->|                      |
        i_rst_n    -->|                      |
                       +----------------------+

    Parameters:
        DATA_WIDTH - Data width in bits (default = 32 for RISC-V)
        ADDR_WIDTH - Address width in bits (determines number of registers = 2^AW)
                     Critical parameter that defines:
                     - Total number of architectural registers
                     - Default of 5 gives 32 registers (x0-x31)
                     - Must be >=5 for RISC-V compliance

    Inputs:
        i_clk       - System clock (positive edge triggered)
        i_rst_n     - Asynchronous active-low reset
        i_reg_write - Register write enable
        i_rs1_addr  - Read address port 1 (width = ADDR_WIDTH)
        i_rs2_addr  - Read address port 2 (width = ADDR_WIDTH)
        i_rd_addr   - Write address (width = ADDR_WIDTH)
        i_rd_data   - Write data (width = DATA_WIDTH)

    Outputs:
        o_rs1_data - Read data port 1 (width = DATA_WIDTH)
        o_rs2_data - Read data port 2 (width = DATA_WIDTH)

    Register Organization:
        - Implemented as 2^ADDR_WIDTH registers of DATA_WIDTH bits each
        - Register x0 is hardwired to zero (RISC-V requirement)
        - Example: ADDR_WIDTH=5 → 32 registers (x0-x31)

    Timing Characteristics:
        - Read ports: Combinational output (asynchronous)
        - Write port: Synchronous to clock rising edge
        - Reset: Asynchronous clear of all registers

    Operation:
        - On reset (i_rst_n=0): All registers cleared to 0 (including x0)
        - On clock rising edge:
            - If i_reg_write=1 and i_rd_addr!=0: Selected register updates
        - Read ports:
            - Always show current register value (x0 hardwired to 0)
            - Bypass newly written data on same cycle (internal forwarding)

    Typical Usage:
        - Core register storage in RISC-V processor
        - Connected to ALU operand ports
        - Stores intermediate computation results

    Implementation Notes:
        - Actual storage implemented as standard flip-flop array
        - ADDR_WIDTH must be 5 for standard RISC-V (32 registers)
        - Register x0 implementation saves power by preventing actual writes
        - Write-first behavior prevents pipeline hazards through internal forwarding
**/

//-----------------------------------------------------------------------------
// Register File Module (RISC-V style)
//-----------------------------------------------------------------------------
`timescale 1ns/1ps  // Simulation time unit = 1ns, precision = 1ps
module regfile #(
    parameter DATA_WIDTH = 32,  // Width of each register (default 32 bits)
    parameter ADDR_WIDTH = 5    // Number of address bits (default 5 for 32 regs)
)(
    // Clock and Reset
    input logic                  i_clk,       // System clock
    input logic                  i_rst_n,     // Active-low asynchronous reset
    
    // Control Signals
    input logic                  i_reg_write, // Register write enable
    
    // Address Inputs
    input logic [ADDR_WIDTH-1:0] i_rs1_addr,  // Read address port 1
    input logic [ADDR_WIDTH-1:0] i_rs2_addr,  // Read address port 2
    input logic [ADDR_WIDTH-1:0] i_rd_addr,   // Write address
    
    // Data Ports
    input logic [DATA_WIDTH-1:0] i_rd_data,   // Write data
    output logic [DATA_WIDTH-1:0] o_rs1_data, // Read data port 1
    output logic [DATA_WIDTH-1:0] o_rs2_data  // Read data port 2
);

    // Register Storage (2^ADDR_WIDTH registers of DATA_WIDTH bits each)
    logic [DATA_WIDTH-1:0] register_r [0:(1<<ADDR_WIDTH)-1];
    
    // Register Update Logic
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            // Asynchronous reset - clear all registers
            foreach (register_r[i]) register_r[i] <= '0;
        end
        else if (i_reg_write && (i_rd_addr != '0)) begin
            // Synchronous write operation (with x0 hardwired to zero check)
            register_r[i_rd_addr] <= i_rd_data;
        end
    end
    
    // Read Ports with Internal Forwarding (write-first behavior)
    // - Register x0 is always hardwired to zero in RISC-V
    // - Bypasses newly written data on same cycle (internal forwarding)
    always_comb begin
        // Read port 1 with internal forwarding
        if (i_rs1_addr == '0) begin
            o_rs1_data = '0;  // x0 hardwired to zero
        end
        else if (i_reg_write && (i_rd_addr == i_rs1_addr) && (i_rd_addr != '0)) begin
            o_rs1_data = i_rd_data;  // Forward write data (prevents hazard)
        end
        else begin
            o_rs1_data = register_r[i_rs1_addr];  // Normal read
        end
        
        // Read port 2 with internal forwarding  
        if (i_rs2_addr == '0) begin
            o_rs2_data = '0;  // x0 hardwired to zero
        end
        else if (i_reg_write && (i_rd_addr == i_rs2_addr) && (i_rd_addr != '0)) begin
            o_rs2_data = i_rd_data;  // Forward write data (prevents hazard)
        end
        else begin
            o_rs2_data = register_r[i_rs2_addr];  // Normal read
        end
    end

endmodule