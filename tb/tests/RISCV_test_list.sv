//------------------------------------------------------------------------------
// Package for aggregating RISCV tests
//------------------------------------------------------------------------------
// This package includes all the tests for the RISCV simulation.
//
// Author: Gustavo Santiago
// Date  : June 2025
//------------------------------------------------------------------------------

`ifndef RISCV_TEST_LIST 
`define RISCV_TEST_LIST

package RISCV_test_list;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import RISCV_env_pkg::*;
  import RISCV_seq_list::*;

  /*
   * Including basic test definition
   */
  `include "RISCV_store_test.sv"

endpackage 

`endif





