//------------------------------------------------------------------------------
// Driver module for RISCV agent
//------------------------------------------------------------------------------
// This module handles transaction driving for the RISCV agent.
//
// Author: Gustavo Santiago
// Date  : June 2025
//------------------------------------------------------------------------------

`ifndef RISCV_DRIVER
`define RISCV_DRIVER

class RISCV_driver extends uvm_driver #(RISCV_transaction);
 
  RISCV_transaction trans;
  virtual RISCV_interface vif;

  `uvm_component_utils(RISCV_driver)
  uvm_analysis_port#(RISCV_transaction) drv2rm_port;

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual RISCV_interface)::get(this, "", "intf", vif))
      `uvm_fatal("NO_VIF", {"Virtual interface must be set for: ", get_full_name(), ".vif"});
    drv2rm_port = new("drv2rm_port", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    reset();
    forever begin
      seq_item_port.get_next_item(req);
      drive();
      `uvm_info(get_full_name(), $sformatf("Driving instruction: %s", req.instr_name), UVM_LOW);
      req.print();
      @(vif.dr_cb); // Wait one clock for handshake
      $cast(rsp, req.clone());
      rsp.set_id_info(req);
      drv2rm_port.write(rsp);
      seq_item_port.item_done();
      seq_item_port.put(rsp);
    end
  endtask

  /*
   * Task: drive
   * Drives instruction and memory request signals to the DUT.
   * This version supports instruction fetch and store operations.
   */
  task drive();
    wait(!vif.reset);
    @(vif.dr_cb);

    // Drive instruction bus
    vif.dr_cb.instr_ready <= req.instr_ready;
    vif.dr_cb.instr_data  <= req.instr_data;

    // Memory signals (optional for future enhancements)
    vif.dr_cb.data_ready  <= req.data_ready;
    vif.dr_cb.data_rd     <= req.data_rd;
  endtask

  /*
   * Task: reset
   * Resets the DUT inputs.
   */
  task reset();
    @(vif.dr_cb);
    vif.dr_cb.instr_ready <= 0;
    vif.dr_cb.instr_data  <= 32'd0;
    vif.dr_cb.data_ready  <= 0;
    vif.dr_cb.data_rd     <= 32'd0;
  endtask

endclass

`endif