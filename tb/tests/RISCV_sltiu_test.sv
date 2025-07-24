//------------------------------------------------------------------------------
// SLTIU test for RISCV
//------------------------------------------------------------------------------
// This UVM test sets up the environment and sequence for the RISCV verification.
//
// Author: Henrique Teixeira
// Date  : July 2025
//------------------------------------------------------------------------------

`ifndef RISCV_SLTIU_TEST
`define RISCV_SLTIU_TEST

class RISCV_sltiu_test extends uvm_test;

  `uvm_component_utils(RISCV_sltiu_test)

  RISCV_environment env;
  RISCV_sltiu_seq   seq;

  function new(string name = "RISCV_sltiu_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = RISCV_environment::type_id::create("env", this);
    seq = RISCV_sltiu_seq::type_id::create("seq");
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    seq.start(env.RISCV_agnt.sequencer);
    phase.drop_objection(this);
  endtask

endclass

`endif
