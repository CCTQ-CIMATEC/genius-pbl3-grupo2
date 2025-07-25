//------------------------------------------------------------------------------
// SLTU test for RISCV
//------------------------------------------------------------------------------
// This UVM test sets up the environment and sequence for the RISCV verification.
//
// Author: Angelo Santos
// Date  : July 2025
//------------------------------------------------------------------------------

`ifndef RISCV_SLTU_TEST 
`define RISCV_SLTU_TEST

class RISCV_sltu_test extends uvm_test;
 
  `uvm_component_utils(RISCV_sltu_test)
 
  RISCV_environment env;
  RISCV_sltu_seq    seq;
 
  function new(string name = "RISCV_sltu_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
 
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = RISCV_environment::type_id::create("env", this);
    seq = RISCV_sltu_seq::type_id::create("seq");
  endfunction : build_phase
 
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    seq.start(env.RISCV_agnt.sequencer);
    phase.drop_objection(this);
  endtask : run_phase

endclass

`endif
