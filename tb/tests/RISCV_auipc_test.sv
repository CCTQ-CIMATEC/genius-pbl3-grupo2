//------------------------------------------------------------------------------
// AUIPC test for RISCV
//------------------------------------------------------------------------------
// This UVM test sets up the environment and runs the AUIPC sequence for RISCV
// instruction verification. It initializes the UVM environment and executes
// randomized AUIPC transactions.
//
// Author: Henrique Teixeira
// Date  : July 2025
//------------------------------------------------------------------------------

`ifndef RISCV_AUIPC_TEST
`define RISCV_AUIPC_TEST

class RISCV_auipc_test extends uvm_test;

  `uvm_component_utils(RISCV_auipc_test)

  RISCV_environment env;
  RISCV_auipc_seq   seq;

  function new(string name = "RISCV_auipc_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create the environment and sequence
    env = RISCV_environment::type_id::create("env", this);
    seq = RISCV_auipc_seq::type_id::create("seq");
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    // Start the AUIPC sequence on the agent's sequencer
    seq.start(env.RISCV_agnt.sequencer);

    phase.drop_objection(this);
  endtask

endclass

`endif
