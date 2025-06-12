//------------------------------------------------------------------------------
// Top-level testbench for RISCV
//------------------------------------------------------------------------------
// This module instantiates the DUT, generates clock/reset, and starts UVM phases.
//
// Author: Gustavo Santiago
// Date  : JULY 2025
//------------------------------------------------------------------------------

`ifndef RISCV_TB_TOP
`define RISCV_TB_TOP
`include "uvm_macros.svh"
`include "RISCV_interface.sv"
import uvm_pkg::*;

module RISCV_tb_top;
   
  
import RISCV_test_list::*;

/*
 * Local signal declarations and parameter definitions
 */
 parameter P_DATA_WIDTH = 32;
 parameter P_ADDR_WIDTH = 10;
 parameter P_REG_ADDR_WIDTH = 5;
 parameter P_IMEM_ADDR_WIDTH = 9;
 parameter P_DMEM_ADDR_WIDTH = 8;
 
 parameter cycle = 10;
 bit clk;
 bit reset;
 
 /*
  * Clock generation process
  * Generates a clock signal with a period defined by the cycle parameter.
  */
 initial begin
   clk = 0;
   forever #(cycle/2) clk = ~clk;
 end

 /*
  * Reset generation process
  * Generates a reset signal that is asserted for a few clock cycles.
  */
 initial begin
    reset <= 0;   // Assert reset
    #10;          // Hold reset for 10ns (5 clock cycles)
    reset <= 1;   // Release reset
 end
 
 /*
  * Instantiate interface to connect DUT and testbench elements
  * The interface connects the DUT to the testbench components.
  */
 RISCV_interface #(
        .P_DATA_WIDTH(P_DATA_WIDTH),
        .P_IMEM_ADDR_WIDTH(P_IMEM_ADDR_WIDTH),
        .P_DMEM_ADDR_WIDTH(P_DMEM_ADDR_WIDTH)
 ) RISCV_intf(clk, reset);
 
 /*
  * DUT instantiation for RISCV
  * Instantiates the RISCV DUT and connects it to the interface signals.
  */
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
       .o_imem_addr    (RISCV_intf.inst_addr),
       .i_imem_rdata   (RISCV_intf.instr_data),
       // Data Memory Interface
       .o_dmem_we      (RISCV_intf.data_wr_en_ma),
       .o_dmem_addr    (RISCV_intf.data_addr),
       .o_dmem_wdata   (RISCV_intf.data_wr),
       .i_dmem_rdata   (RISCV_intf.data_rd)
   );
 
 /*
  * Start UVM test phases
  * Initiates the UVM test phases.
  */
 initial begin
   run_test();
 end
 
 /*
  * Set the interface instance in the UVM configuration database
  * Registers the interface instance with the UVM configuration database.
  */
 initial begin
   uvm_config_db#(virtual RISCV_interface)::set(uvm_root::get(), "*", "intf", RISCV_intf);
 end

endmodule

`endif