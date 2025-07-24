//------------------------------------------------------------------------------
// Load + I-type + Store test for RISCV
//------------------------------------------------------------------------------
// This UVM test sets up the environment and sequence for RISCV verification
// using a mix of Load (LB, LH, LBU, LHU, LW), I-type (ADDI, SLTI, ANDI, etc.),
// and Store (SB, SH, SW) instructions in that order.
//
// Author: Henrique Teixeira 
// Date  : July 2025
//------------------------------------------------------------------------------

`ifndef RISCV_LOAD_I_STORE_TEST
`define RISCV_LOAD_I_STORE_TEST

class RISCV_load_i_store_test extends uvm_test;

  `uvm_component_utils(RISCV_load_i_store_test)

  RISCV_environment         env;
  RISCV_load_i_store_seq   seq;

  function new(string name = "RISCV_load_i_store_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    env = RISCV_environment::type_id::create("env", this);

    set_type_override_by_type(RISCV_transaction::get_type(), RISCV_transaction_block::get_type());
    set_type_override_by_type(RISCV_driver::get_type(), RISCV_block_driver::get_type());
    set_type_override_by_type(RISCV_monitor::get_type(), RISCV_block_monitor::get_type());

    seq = RISCV_load_i_store_seq::type_id::create("seq");
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info(get_type_name(), "Starting RISCV_load_i_store_seq...", UVM_MEDIUM)
    seq.start(env.RISCV_agnt.sequencer);
    `uvm_info(get_type_name(), "Completed RISCV_load_i_store_seq.", UVM_MEDIUM)
    phase.drop_objection(this);
  endtask

endclass

`endif
