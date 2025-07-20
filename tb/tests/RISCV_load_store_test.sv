//------------------------------------------------------------------------------
// load test for RISCV
//------------------------------------------------------------------------------
// This UVM test sets up the environment and sequence for the RISCV verification.
//
// Author: Leonardo Rodrigues
// Date  : June 2025
//------------------------------------------------------------------------------

`ifndef RISCV_LOAD_STORE_TEST 
`define RISCV_LOAD_STORE_TEST

class RISCV_load_store_test extends uvm_test;
 
  /*
   * Declare component utilities for the test-case
   */
  `uvm_component_utils(RISCV_load_store_test)
 
  RISCV_environment env;
  RISCV_load_store_seq   seq;
 
  /*
   * Constructor: new
   * Initializes the test with a given name and parent component.
   */
  function new(string name = "RISCV_load_store_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
 
  /*
   * Build phase: Instantiate environment and sequence
   * This phase constructs the environment and sequence components.
   */
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = RISCV_environment::type_id::create("env", this);
    set_type_override_by_type(RISCV_transaction::get_type(), RISCV_transaction_block::get_type());
    set_type_override_by_type(RISCV_driver::get_type(), RISCV_block_driver::get_type());
    set_type_override_by_type(RISCV_monitor::get_type(), RISCV_block_monitor::get_type());
    seq = RISCV_load_store_seq::type_id::create("seq");
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
 
endclass : RISCV_load_store_test

`endif