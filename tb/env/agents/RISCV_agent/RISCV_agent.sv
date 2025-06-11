//------------------------------------------------------------------------------
// UVM agent for RISCV transactions
//------------------------------------------------------------------------------
// This agent handles the driver, monitor, and sequencer for RISCV transactions.
//
// Author: Gustavo Santiago
// Date  : June 2025
//------------------------------------------------------------------------------

`ifndef RISCV_AGENT 
`define RISCV_AGENT

class RISCV_agent extends uvm_agent;

  /*
   * Declaration of UVC components such as driver, monitor, sequencer, etc.
   */
  RISCV_driver    driver;
  RISCV_sequencer sequencer;
  RISCV_monitor   monitor;

  /*
   * Declaration of component utils 
   */
  `uvm_component_utils(RISCV_agent)

  /*
   * Constructor
   */
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  /*
   * Build phase: construct the components such as driver, monitor, sequencer, etc.
   */
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    driver = RISCV_driver::type_id::create("driver", this);
    sequencer = RISCV_sequencer::type_id::create("sequencer", this);
    monitor = RISCV_monitor::type_id::create("monitor", this);
  endfunction : build_phase

  /*
   * Connect phase: connect TLM ports and exports (e.g., analysis port/exports)
   */
  function void connect_phase(uvm_phase phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction : connect_phase
 
endclass : RISCV_agent

`endif
