//------------------------------------------------------------------------------
// Coverage collection module for RISCV
//------------------------------------------------------------------------------
// This module collects functional coverage for the RISCV environment.
//
// Author: Gustavo Santiago
// Date  : June 2025
//------------------------------------------------------------------------------

`ifndef RISCV_COVERAGE
`define RISCV_COVERAGE

class RISCV_coverage#(type T = RISCV_transaction) extends uvm_subscriber#(T);

  /*
   * Local copy of the transaction for coverage sampling
   */
  RISCV_transaction cov_trans;
  `uvm_component_utils(RISCV_coverage)

  /*
   * Covergroup for functional coverage of store instructions
   */
  covergroup riscv_store_cg;
    option.per_instance = 1;

    // Coverpoint for opcode (bits [6:0] of instr_data)
    cp_opcode: coverpoint cov_trans.instr_data[6:0] {
      bins sb = {7'b0100011}; // opcode for STORE group
    }

    // Coverpoint for funct3 (bits [14:12] of instr_data)
    cp_funct3: coverpoint cov_trans.instr_data[14:12] {
      bins sb_bin = {3'b000}; // SB
      bins sh_bin = {3'b001}; // SH
      bins sw_bin = {3'b010}; // SW
    }

    // Coverpoint for instr_ready signal
    cp_instr_ready: coverpoint cov_trans.instr_ready {
      bins ready     = {1};
      bins not_ready = {0};
    }

    // Coverpoint for address being written to
    cp_data_addr: coverpoint cov_trans.data_addr {
      bins low_addr  = {[32'h0000_0000 : 32'h0000_00FF]};
      bins mid_addr  = {[32'h0000_0100 : 32'h0000_0FFF]};
      bins high_addr = {[32'h0000_1000 : 32'hFFFF_FFFF]};
    }

    // Coverpoint for data being written
    cp_data_wr: coverpoint cov_trans.data_wr {
      bins zero_val     = {32'd0};
      bins all_ones_val = {32'hFFFF_FFFF};
      bins small_val    = {[32'd1 : 32'd255]};
      bins large_val    = {[32'd256 : 32'hFFFF_FFFF]};
    }

  endgroup

  /*
   * Constructor: Initializes the coverage group and transaction object.
   */
  function new(string name = "RISCV_coverage", uvm_component parent);
    super.new(name, parent);
    riscv_store_cg = new();
    cov_trans = new();
  endfunction

  /*
   * Coverage sampling callback
   */
  function void write(RISCV_transaction t);
    this.cov_trans = t;
    riscv_store_cg.sample();
  endfunction

endclass

`endif