//------------------------------------------------------------------------------
// SLL test for RISCV
//------------------------------------------------------------------------------
// This UVM test sets up the environment and sequence for the RISCV verification.
//
// Author: Leonardo Rodrigues
// Date  : July 2025
//------------------------------------------------------------------------------

`ifndef RISCV_SLL_TEST 
`define RISCV_SLL_TEST

class RISCV_sll_test extends uvm_test;
 
  /*
   * Declare component utilities for the test-case
   */
  `uvm_component_utils(RISCV_sll_test)
 
  RISCV_environment env;
  RISCV_sll_seq     seq;
 
  /*
   * Constructor: new
   * Initializes the test with a given name and parent component.
   */
  function new(string name = "RISCV_sll_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
 
  /*
   * Build phase: Instantiate environment and sequence
   * This phase constructs the environment and sequence components.
   */
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = RISCV_environment::type_id::create("env", this);
    seq = RISCV_sll_seq::type_id::create("seq");
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
 
endclass : RISCV_sll_test

`endif