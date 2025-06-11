/**
    PBL3 - RISC-V Pipeline Processor
    Execute Stage (EX) Module
    File name: execute_stage.sv
    Objective:
        Implement the execute stage of the RISC-V pipeline processor.
        Handles ALU operations, branch condition evaluation, and address calculations.
    Specification:
        - Integrates ALU for arithmetic/logic operations
        - Calculates branch/jump target addresses
        - Evaluates branch conditions
        - Handles immediate value selection
        - Supports forwarding inputs from later pipeline stages
        - Generates control signals for next stages
    Functional Diagram:
                     +------------------------+
                     |                        |
    rs1_data ------> |                        |
    rs2_data ------> |                        |----> alu_result
    imm_data ------> |      EXECUTE STAGE     |----> branch_taken
    pc_current ----->|                        |----> target_addr
    alucontrol ----->|                        |----> zero_flag
    alusrc --------->|                        |
    branch --------->|                        |
    jump ----------> |                        |
                     +------------------------+
**/
//----------------------------------------------------------------------------- 
//  Execute Stage Module
//-----------------------------------------------------------------------------
`timescale 1ns / 1ps

module execute_stage #(
    parameter DATA_WIDTH=32, 
    parameter ADDR_WIDTH = 10
)(

    input logic                   i_clk,
    input logic                   i_rst_n,

    //input logic                   i_flush_e,

    // Data inputs from ID/EX pipeline register
    input  logic [DATA_WIDTH-1:0] i_rs1_data_e,    // Register source 1 data
    input  logic [DATA_WIDTH-1:0] i_rs2_data_e,    // Register source 2 data
    input  logic [DATA_WIDTH-1:0] i_immext_e,      // Immediate value (sign-extended)
    input  logic [ADDR_WIDTH-1:0] i_pc_e,          // Current PC value
    input  logic [ADDR_WIDTH-1:0] i_pc4_e,         // PC+4 value
    
    // Address inputs for forwarding logic
    input  logic [4:0]  i_rs1_addr_e,    // RS1 address
    input  logic [4:0]  i_rs2_addr_e,    // RS2 address
    input  logic [4:0]  i_rd_addr_e,     // RD address
    
    // Control signals from ID/EX pipeline register
    input  logic [2:0]  i_aluctrl_e,     // ALU operation control (3-bit from your decode)
    input  logic        i_alusrc_e,      // ALU source select (0=reg, 1=imm)
    input  logic        i_branch_e,      // Branch instruction flag
    input  logic        i_jump_e,        // Jump instruction flag
    input  logic        i_regwrite_e,    // Register write enable
    input  logic        i_memwrite_e,    // Memory write enable
    input  logic [1:0]  i_resultsrc_e,   // Result source select
    
    // Forwarding inputs (from MEM and WB stages)
    input  logic [DATA_WIDTH-1:0] i_forward_m,   // Forwarded data from MEM stage
    input  logic [DATA_WIDTH-1:0] i_forward_w,    // Forwarded data from WB stage
    input  logic [1:0]  i_forward_a,            // Forward control for operand A
    input  logic [1:0]  i_forward_b,            // Forward control for operand B
    
    // Outputs to EX/MEM pipeline register
    output logic [DATA_WIDTH-1:0] o_alu_result_m,    // ALU computation result
    output logic [DATA_WIDTH-1:0] o_write_data_m,    // RS2 data (for store operations)
    output logic [ADDR_WIDTH-1:0] o_pctarget_e,      // Branch/jump target address
    output logic                  o_zero_e,          // ALU zero flag
    
    // Pass-through control signals
    output logic        o_regwrite_m,    // Register write enable to MEM
    output logic        o_memwrite_m,    // Memory write enable to MEM
    output logic [1:0]  o_resultsrc_m,   // Result source to MEM
    output logic [4:0]  o_rd_addr_m,     // RD address to MEM
    output logic [ADDR_WIDTH-1:0] o_pc4_m          // PC+4 to MEM
);

    // Internal signals
    logic [DATA_WIDTH-1:0] l_alu_operand_a;          // ALU input A (after forwarding)
    logic [DATA_WIDTH-1:0] l_alu_operand_b;          // ALU input B (after forwarding/mux)
    logic [DATA_WIDTH-1:0] l_rs1_forwarded;          // RS1 after forwarding
    logic [DATA_WIDTH-1:0] l_rs2_forwarded;          // RS2 after forwarding
    logic [3:0]            l_alu_control_extended;   // Extended ALU control signal
    logic [DATA_WIDTH-1:0] l_alu_result_e;
    logic [DATA_WIDTH-1:0] l_write_data_e;

    // Forwarding Logic for Operand A (RS1) using mux3
    mux3 u_fmux1(
        .i_d0   (i_rs1_data_e), // No forwarding
        .i_d1   (i_forward_w),  // Forward from WB stage
        .i_d2   (i_forward_m),  // Forward from MEM stage
        .i_sel  (i_forward_a),
        .o_y    (l_rs1_forwarded)
    );    

    // Forwarding Logic for Operand B (RS2) using mux3
    mux3 u_fmux2(
        .i_d0   (i_rs2_data_e), // No forwarding
        .i_d1   (i_forward_w),  // Forward from WB stage
        .i_d2   (i_forward_m),  // Forward from MEM stage
        .i_sel  (i_forward_b),
        .o_y    (l_rs2_forwarded)
    );    

    //-------------------------------------------------------------------------
    // ALU Input Selection
    //-------------------------------------------------------------------------
    assign l_alu_operand_a = l_rs1_forwarded;
    
    // ALU Source B Multiplexer (register or immediate)
    assign l_alu_operand_b = i_alusrc_e ? i_immext_e : l_rs2_forwarded;
    
    // Extend 3-bit ALU control to 4-bit for your ALU
    assign l_alu_control_extended = {1'b0, i_aluctrl_e}; // ISSO PODE DAR BO, N LEMBRO DE TER ATUALIZADO A ULA

    //-------------------------------------------------------------------------
    // ALU Instantiation
    //-------------------------------------------------------------------------
    alu alu_inst (
        .i_a          (l_alu_operand_a),
        .i_b          (l_alu_operand_b),
        .i_alucontrol (l_alu_control_extended),
        .o_result     (l_alu_result_e),
        .o_zero       (o_zero_e)
    );

    //-------------------------------------------------------------------------
    // Branch/Jump Target Address Calculation
    //-------------------------------------------------------------------------
    assign o_pctarget_e = i_pc_e + i_immext_e;

    //-------------------------------------------------------------------------
    // Pass RS2 data for store operations
    //-------------------------------------------------------------------------
    assign l_write_data_e = l_rs2_forwarded;
    
    //-------------------------------------------------------------------------
    // Pass-through control signals to EX/MEM pipeline register
    //-------------------------------------------------------------------------


    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_regwrite_m    <= 0;
            o_resultsrc_m   <= 0;
            o_memwrite_m    <= 0;
            o_alu_result_m  <= 0;
            o_write_data_m  <= 0;
            o_rd_addr_m     <= 0;
            o_pc4_m         <= 0;
        end else begin
            o_regwrite_m    <= i_regwrite_e;
            o_resultsrc_m   <= i_resultsrc_e;
            o_memwrite_m    <= i_memwrite_e;
            o_alu_result_m  <= l_alu_result_e;
            o_write_data_m  <= l_write_data_e;
            o_rd_addr_m     <= i_rd_addr_e;
            o_pc4_m         <= i_pc4_e;
        end
    end

endmodule