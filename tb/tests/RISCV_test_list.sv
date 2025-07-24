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
  import RISCV_agent_pkg::*;
  import RISCV_seq_list::*;

  /*
   * Including basic test definition
   */
  `include "RISCV_store_test.sv"
  `include "RISCV_load_test.sv" 
  `include "RISCV_add_test.sv" 
  `include "RISCV_addi_test.sv" 
  `include "RISCV_and_test.sv"
  `include "RISCV_sub_test.sv" 
  `include "RISCV_or_test.sv" 
  `include "RISCV_ori_test.sv" 
  `include "RISCV_xor_test.sv"
  `include "RISCV_xori_test.sv"
  `include "RISCV_beq_test.sv" 
  `include "RISCV_jal_test.sv" 
  `include "RISCV_andi_test.sv" 
  `include "RISCV_lui_test.sv" 
  `include "RISCV_load_store_test.sv"
  `include "RISCV_auipc_test.sv"
  `include "RISCV_slti_test.sv"
  `include "RISCV_sltiu_test.sv"
  `include "RISCV_load_R_store_test.sv"
  `include "RISCV_load_i_store_test.sv"

endpackage 

`endif