/**
 * PBL3 - RISC-V Pipelined Processor with External Memory
 * 
 * File name: riscv_top.sv
 * 
 * Objective:
 *     Top-level module that instantiates the RISC-V processor core
 *     and external instruction/data memories with proper interfaces.
 */

`timescale 1ns/1ps

module riscv_top #(
    parameter P_DATA_WIDTH = 32,
    parameter P_ADDR_WIDTH = 10,
    parameter P_REG_ADDR_WIDTH = 5,
    parameter P_IMEM_ADDR_WIDTH = 9,
    parameter P_DMEM_ADDR_WIDTH = 8
)(
    input  logic i_clk,
    input  logic i_rst_n
);

    //=========================================================================
    // Memory Interface Signals
    //=========================================================================
    
    // Instruction Memory Interface
    logic [P_IMEM_ADDR_WIDTH-1:0]  imem_addr;
    logic [P_DATA_WIDTH-1:0]       imem_rdata;
    
    // Data Memory Interface  
    logic                          dmem_we;
    logic [P_DMEM_ADDR_WIDTH-1:0]  dmem_addr;
    logic [P_DATA_WIDTH-1:0]       dmem_wdata;
    logic [P_DATA_WIDTH-1:0]       dmem_rdata;

    //=========================================================================
    // RISC-V Processor Core
    //=========================================================================
    riscv_core #(
        .P_DATA_WIDTH(P_DATA_WIDTH),
        .P_ADDR_WIDTH(P_ADDR_WIDTH),
        .P_REG_ADDR_WIDTH(P_REG_ADDR_WIDTH),
        .P_IMEM_ADDR_WIDTH(P_IMEM_ADDR_WIDTH),
        .P_DMEM_ADDR_WIDTH(P_DMEM_ADDR_WIDTH)
    ) u_riscv_core (
        .i_clk          (i_clk),
        .i_rst_n        (i_rst_n),
        // Instruction Memory Interface
        .o_imem_addr    (imem_addr),
        .i_imem_rdata   (imem_rdata),
        // Data Memory Interface
        .o_dmem_we      (dmem_we),
        .o_dmem_addr    (dmem_addr),
        .o_dmem_wdata   (dmem_wdata),
        .i_dmem_rdata   (dmem_rdata)
    );

    //=========================================================================
    // External Instruction Memory
    //=========================================================================
    instrucmem #(
        .P_DATA_WIDTH(P_DATA_WIDTH),
        .P_ADDR_WIDTH(P_IMEM_ADDR_WIDTH)
    ) u_instrucmem (
        .i_pc     (imem_addr),
        .o_instr  (imem_rdata)
    );

    //=========================================================================
    // External Data Memory
    //=========================================================================
    data_memory #(
        .P_ADDR_WIDTH(P_DMEM_ADDR_WIDTH),
        .P_DATA_WIDTH(P_DATA_WIDTH)
    ) u_data_memory (
        .i_clk   (i_clk),
        .i_we    (dmem_we),
        .i_addr  (dmem_addr),
        .i_wdata (dmem_wdata),
        .o_rdata (dmem_rdata)
    );

endmodule