//------------------------------------------------------------------------------
// Sequencer module for RISCV agent
//------------------------------------------------------------------------------
// This module defines the sequencer for the RISCV agent.
//
// Author: Gustavo Santiago
// Date  : June 2025
//------------------------------------------------------------------------------

`ifndef RISCV_SEQUENCER
`define RISCV_SEQUENCER

class RISCV_sequencer extends uvm_sequencer#(RISCV_transaction);
 
  `uvm_component_utils(RISCV_sequencer)
 
  /*
   * Constructor
   */
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
   
endclass

`endif