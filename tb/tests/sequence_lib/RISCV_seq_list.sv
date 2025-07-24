//------------------------------------------------------------------------------
// Package for listing RISCV sequences
//------------------------------------------------------------------------------
// This package includes the basic sequence for the RISCV testbench.
//
// Author: Gustavo Santiago
// Date  : June 2025
//------------------------------------------------------------------------------

`ifndef RISCV_SEQ_LIST 
`define RISCV_SEQ_LIST

package RISCV_seq_list;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import RISCV_agent_pkg::*;
  import RISCV_ref_model_pkg::*;
  import RISCV_env_pkg::*;

  /*
   * Including RISCV store sequence 
   */
  `include "RISCV_store_seq.sv"
  `include "RISCV_load_seq.sv"
  `include "RISCV_add_seq.sv" 
  `include "RISCV_and_seq.sv" 
  `include "RISCV_addi_seq.sv"
  `include "RISCV_sub_seq.sv"
  `include "RISCV_or_seq.sv"  
  `include "RISCV_ori_seq.sv" 
  `include "RISCV_xor_seq.sv"
  `include "RISCV_xori_seq.sv"
  `include "RISCV_beq_seq.sv"
  `include "RISCV_jal_seq.sv"
  `include "RISCV_andi_seq.sv"
  `include "RISCV_lui_seq.sv"
  `include "RISCV_load_store_seq.sv"
  `include "RISCV_auipc_seq.sv"
  `include "RISCV_slti_seq.sv"
  `include "RISCV_sll_seq.sv"
  `include "RISCV_srl_seq.sv"
  `include "RISCV_srli_seq.sv"  
  `include "RISCV_sltiu_seq.sv"
  `include "RISCV_load_R_store_seq.sv"
  `include "RISCV_load_i_store_seq.sv"
  `include "RISCV_slli_seq.sv"
  `include "RISCV_sltu_seq.sv"
  `include "RISCV_slt_seq.sv"

endpackage

`endif
