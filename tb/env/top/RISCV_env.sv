//------------------------------------------------------------------------------
// Environment module for RISCV
//------------------------------------------------------------------------------
// This module instantiates agents, monitors, and other components for the RISCV environment.
//
// Author: Gustavo Santiago
// Date  : June 2025
//------------------------------------------------------------------------------

`ifndef RISCV_ENV
`define RISCV_ENV

class RISCV_environment extends uvm_env;
 
  /*
   * Declaration of components
   */
  RISCV_agent RISCV_agnt;
  RISCV_ref_model ref_model;
  RISCV_coverage#(RISCV_transaction) coverage;
  RISCV_scoreboard  sb;
   
  /*
   * Register with factory
   */
  `uvm_component_utils(RISCV_environment)
     
  /*
   * Constructor
   */
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  /*
   * Build phase: instantiate components
   */
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    RISCV_agnt = RISCV_agent::type_id::create("RISCV_agent", this);
    ref_model = RISCV_ref_model::type_id::create("ref_model", this);
    coverage = RISCV_coverage#(RISCV_transaction)::type_id::create("coverage", this);
    sb = RISCV_scoreboard::type_id::create("sb", this);
  endfunction : build_phase

  /*
   * Connect phase: hook up TLM ports
   */
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    RISCV_agnt.driver.drv2rm_port.connect(ref_model.rm_export);
    RISCV_agnt.monitor.mon2sb_port.connect(sb.mon2sb_export);
    ref_model.rm2sb_port.connect(coverage.analysis_export);
    ref_model.rm2sb_port.connect(sb.rm2sb_export);
  endfunction : connect_phase

endclass : RISCV_environment

`endif




