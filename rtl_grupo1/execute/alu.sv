/**
    PBL3 - RISC-V Single Cycle Processor
    Arithmetic Logic Unit (ALU) Module

    File name: alu.sv

    Objective:
        Implement the core arithmetic and logic operations for the RISC-V processor.
        Handles all required computations for the RV32I instruction set.

    Specification:
        - Supports basic arithmetic operations (ADD, SUBTRACT)
        - Implements logical operations (AND, OR)
        - Provides comparison operation (SET LESS THAN)
        - Generates zero flag for branch comparisons
        - 32-bit inputs and outputs
        - Combinational logic (no clocked elements)

    Operations:
        - ADD:       i_a + i_b
        - SUBTRACT:  i_a - i_b
        - AND:       i_a & i_b
        - OR:        i_a | i_b
        - SLT:       Sets result to 1 if  i_a < i_b (signed comparison)

    Functional Diagram:

                       +------------------+
                       |                  |
        i_a[31:0] ---->|                  |
        i_b[31:0] ---->|       ALU        |---> o_result[31:0]
        i_alucontrol ->|                  |---> o_zero
                       |                  |
                       +------------------+

    Inputs:
        i_a[31:0]       - First operand (typically from register file)
        i_b[31:0]       - Second operand (from register or immediate)
        i_alucontrol[2:0] - Operation selector:
                            * 3'b000: ADD
                            * 3'b001: SUBTRACT
                            * 3'b010: AND
                            * 3'b011: OR
                            * 3'b101: SET LESS THAN

    Outputs:
        o_result[31:0]  - Result of ALU operation
        o_zero          - Asserted (1) when result is zero, used for BEQ/BNE

    Control Signals:
        i_alucontrol    - Determines which operation the ALU performs
                         (decoded from funct3 and funct7 fields of instruction)
**/

//----------------------------------------------------------------------------- 
//  Arithmetic Logic Unit (ALU) Module
//-----------------------------------------------------------------------------
`timescale 1ns / 1ps  // Set simulation time unit to 1ns, precision to 1ps

module alu (
    input  logic [31:0] i_a,          // Operand A
    input  logic [31:0] i_b,          // Operand B
    input  logic [2:0]  i_alucontrol, // 3-bit ALU control signal
    output logic [31:0] o_result,     // ALU result
    output logic        o_zero        // Zero flag (1 when result is zero)
);

    always_comb begin
        case (i_alucontrol)
            3'b000: o_result = i_a + i_b;                   // ADD
            3'b001: o_result = i_a - i_b;                   // SUBTRACT
            3'b010: o_result = i_a & i_b;                   // AND
            3'b011: o_result = i_a | i_b;                   // OR
            3'b101: o_result = (i_a < i_b) ? 32'd1 : 32'd0; // SET LESS THAN
            default: o_result = 32'hDEADBEEF;               // Undefined operation
        endcase

        // Zero flag generation
        o_zero = (o_result == 32'b0);
    end

endmodule