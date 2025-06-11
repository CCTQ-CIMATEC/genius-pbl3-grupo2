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
    reset = 1;
    #(cycle*5) reset = 0;
  end
  
  /*
   * Instantiate interface to connect DUT and testbench elements
   * The interface connects the DUT to the testbench components.
   */
  RISCV_interface RISCV_intf(clk, reset);
  
  /*
   * DUT instantiation for RISCV
   * Instantiates the RISCV DUT and connects it to the interface signals.
   */
    // DUT Instantiation
  RISCV dut (
    .clk(clk),
    .rst_n(reset),
    .i_instr_ready(RISCV_intf.instr_ready),
    .i_instr_data(RISCV_intf.instr_data),
    .o_inst_rd_en(RISCV_intf.inst_ctrl_cpu),
    .o_inst_addr(RISCV_intf.inst_addr),
    .i_data_ready(RISCV_intf.data_ready),
    .i_data_rd(RISCV_intf.data_rd),
    .o_data_wr(RISCV_intf.data_wr),
    .o_data_addr(RISCV_intf.data_addr),
    .o_data_rd_en_ctrl(RISCV_intf.data_rd_en_ctrl),
    .o_data_rd_en_ma(RISCV_intf.data_rd_en_ma),
    .o_data_wr_en_ma(RISCV_intf.data_wr_en_ma)
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