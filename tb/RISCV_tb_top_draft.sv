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
   pipeline #(
        .P_DATA_WIDTH(32),
        .P_ADDR_WIDTH(10),
        .P_REG_ADDR_WIDTH(5)
    ) dut (
        .i_clk(clk),
        .i_rst_n(RISCV_intf.instr_data)
    );

    //=========================================================================
    // Signal Monitoring Assignments
    //=========================================================================
    // Monitor memory stage signals for verification
    assign RISCV_intf.data_wr = dut.ex_mem_write_data;
    assign RISCV_intf.data_addr   = dut.ex_mem_alu_result;
    assign RISCV_intf.data_wr_en_ma  = dut.ex_mem_memwrite;
    
    // Optional: Monitor pipeline control signals for debug
    assign RISCV_intf.inst_addr     = dut.if_id_pc;
    assign RISCV_intf.data_rd  = dut.u_memory_stage.l_read_data_m;
    assign l_stall_f   = dut.stall_f;
    assign l_flush_d   = dut.flush_d;
    assign l_forward_a = dut.forward_a;
    assign l_forward_b = dut.forward_b;
  
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