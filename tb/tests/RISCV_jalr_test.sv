//------------------------------------------------------------------------------
// JALR test for RISCV
//------------------------------------------------------------------------------
// This UVM test sets up the environment and sequence for the RISCV JALR instruction verification.
//
// Author: Henrique Teixeira
// Date  : July 2025
//------------------------------------------------------------------------------

`ifndef RISCV_JALR_TEST
`define RISCV_JALR_TEST

class RISCV_jalr_test extends uvm_test;

  /*
   * Declare component utilities for the test-case
   */
  `uvm_component_utils(RISCV_jalr_test)

  RISCV_environment env;
  RISCV_jalr_seq    seq;

  /*
   * Constructor: new
   * Initializes the test with a given name and parent component.
   */
  function new(string name = "RISCV_jalr_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  /*
   * Build phase: Instantiate environment and sequence
   * This phase constructs the environment and sequence components.
   */
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = RISCV_environment::type_id::create("env", this);
    seq = RISCV_jalr_seq::type_id::create("seq");
  endfunction : build_phase

  /*
   * Run phase: Start the sequence on the agent’s sequencer
   * This phase starts the sequence, which generates and sends transactions to the DUT.
   */
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    seq.start(env.RISCV_agnt.sequencer);
    phase.drop_objection(this);
  endtask : run_phase

endclass : RISCV_jalr_test

`endif
