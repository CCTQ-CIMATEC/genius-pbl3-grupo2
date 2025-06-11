/**
    PBL3 - RISC-V Pipelined Processor  
    Fetch Stage Module

    File name: fetch_stage.sv

    Objective:
        Implement the instruction fetch stage for a RISC-V pipelined processor.
        Handles program counter management, instruction memory access, and 
        pipeline control signals.

    Specification:
        - Program counter (PC) management with increment logic
        - Instruction memory interface
        - Pipeline stall and flush control
        - Branch target handling
        - Configurable address and data widths
        - Fully synthesizable with proper timing

    Functional Diagram:

                          +------------------------+
        i_clk         --->|         MODULE         |
        i_rst_n       --->|      FETCH STAGE       |
        i_stall       --->|                        |
        i_flush       --->|                        |----> o_pc
        i_branch_taken--->|                        |----> o_instr
        i_branch_tgt  --->|                        |----> o_pc_plus4
                          +------------------------+

    Parameters:
        P_DATA_WIDTH - Instruction/data width in bits (default = 32)
        P_ADDR_WIDTH - Address width in bits (default = 10)

    Inputs:
        i_clk          - System clock (positive edge triggered)
        i_rst_n        - Asynchronous active-low reset
        i_stall        - Pipeline stall signal (freeze PC)
        i_flush        - Pipeline flush signal (for branches)
        i_branch_taken - Branch taken signal from execute stage
        i_branch_tgt   - Branch target address from execute stage

    Outputs:
        o_pc           - Current program counter value
        o_pc_plus4     - PC + 4 for next sequential instruction
        o_instr        - Fetched instruction from memory

    Memory Interface:
        - Connects to instruction memory module (instrucmem)
        - Provides current PC address
        - Receives instruction data

    Timing Characteristics:
        - PC updates on rising clock edge
        - Asynchronous reset
        - Combinational PC+4 calculation
        - Synchronous memory access

    Operation:
        - On reset: PC initialized to 0
        - Normal operation: PC increments by 4 each cycle
        - Branch handling: PC updates to branch target when taken
        - Stall handling: PC holds current value when stalled
        - Flush handling: Immediate PC update for branches

    Pipeline Integration:
        - Provides instruction and PC to decode stage
        - Receives control signals from hazard unit
        - Handles branch redirection from execute stage

    Implementation Notes:
        - Uses separate instruction memory module
        - PC increment assumes 4-byte aligned instructions
        - Stall/flush logic integrated with hazard unit
        - Branch resolution comes from execute stage

        // Instantiate the Unit Under Test (UUT)
    fetch_stage #(
        .P_DATA_WIDTH(P_DATA_WIDTH),
        .P_ADDR_WIDTH(P_ADDR_WIDTH)
        ) uut (
            .i_clk(i_clk),
            .i_rst_n(i_rst_n),
            .i_stall(i_stall),
            .i_flush(i_flush),
            .i_branch_taken,
            .i_branch_tgt(i_branch_tgt),
            .o_pc(o_pc),
            .o_pc_plus4(o_pc_plus4),
            .o_instr(o_instr)
        );
**/

//-----------------------------------------------------------------------------
// Fetch Stage Module
//-----------------------------------------------------------------------------
`timescale 1ns/1ps
module fetch_stage #(
    parameter P_DATA_WIDTH = 32,  // Default 32-bit for RISC-V
    parameter PC_WIDTH = 9   // Match instrucmem address width
)(
    // Clock and Reset
    input  logic                     i_clk,
    input  logic                     i_rst_n,
    
    // Control Signals[]
    input  logic                     i_stall_f,             
    input  logic                     i_stall_d,
    input  logic                     i_flush_d,

    // pc relatex
    input  logic                     i_pcsrc_e,
    input  logic [PC_WIDTH:0]        i_pctarget_e, 

    // Outputs
    output logic [PC_WIDTH:0]  o_pc_d,
    output logic [PC_WIDTH:0]  o_pc4_d,
    output logic [P_DATA_WIDTH-1:0]  o_instr_d
);

    logic [P_DATA_WIDTH-1:0]  l_instr_f;
    logic [PC_WIDTH:0] l_pc_f, l_pc4_f, l_pcnext_f; 
    
    // PC incrementer (PC + 4)
    adder #(.P_WIDTH(PC_WIDTH)) u_pcadd4 (
        .i_a (l_pc_f),
        .i_b (10'd4),            
        .o_y (l_pc4_f)
    );
    
    // PC source mux (select: PC+4 or target)
    mux2 #(.P_WIDTH(PC_WIDTH)) u_pcmux (
        .i_a   (l_pc4_f),
        .i_b   (i_pctarget_e),
        .i_sel (i_pcsrc_e),        // Controlled by branch decision
        .o_y   (l_pcnext_f)
    );

    // PC register (state element)
    flopr #(.P_WIDTH(PC_WIDTH)) u_pcreg (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_en    (!i_stall_f),
        .i_d     (l_pcnext_f),
        .o_q     (l_pc_f)
    );

    

    // Instruction Memory Interface
    instrucmem #(
        .P_DATA_WIDTH(P_DATA_WIDTH),        
        .P_ADDR_WIDTH(PC_WIDTH)
    ) u_instrucmem (
        .i_pc(l_pc_f),
        .o_instr(l_instr_f)
    );

    //IF/ID
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n | i_flush_d) begin
            o_pc_d      <= 0;
            o_pc4_d     <= 0;
            o_instr_d   <= 0;
        end else if(!i_stall_d) begin
            o_pc_d      <= l_pc_f;
            o_pc4_d     <= l_pc4_f;
            o_instr_d   <= l_instr_f;
        end
    end

endmodule