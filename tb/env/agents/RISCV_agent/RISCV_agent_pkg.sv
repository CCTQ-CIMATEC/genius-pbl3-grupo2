//------------------------------------------------------------------------------
// Package for RISCV agent components
//------------------------------------------------------------------------------
// This package includes the components and declarations for the RISCV agent.
//
// Author: Gustavo Santiago
// Date  : June 2025
//------------------------------------------------------------------------------

`ifndef RISCV_AGENT_PKG
`define RISCV_AGENT_PKG

package RISCV_agent_pkg;
 
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  /*
   * Include Agent components: driver, monitor, sequencer
   */
  `include "RISCV_defines.sv" //rever esse carinha
  `include "RISCV_transaction.sv"
  `include "RISCV_sequencer.sv"
  `include "RISCV_driver.sv"
  `include "RISCV_monitor.sv"
  `include "RISCV_agent.sv"

endpackage

`endif