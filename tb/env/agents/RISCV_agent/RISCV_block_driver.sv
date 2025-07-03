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

class RISCV_block_driver extends RISCV_driver #(RISCV_transaction);
 
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
    wait(vif.reset);
    
    forever begin
      // Get the next transaction from sequencer
      seq_item_port.get_next_item(req);
      
      // Drive the transaction
      drive();
      
      `uvm_info(get_full_name(), $sformatf("Drove instruction: %s", req.instr_name), UVM_LOW);
      req.print();
      
      // Create response and send to analysis port
      $cast(rsp, req.clone());
      rsp.set_id_info(req);
      drv2rm_port.write(rsp);
      
      // Signal completion to sequencer
      seq_item_port.item_done();
      
      repeat(4) @(posedge vif.clk); //await a little before send a new transactions
    end
  endtask

  /*
   * Task: drive
   * Drives a single instruction to the DUT.
   */
  task drive();
    // Wait for clock edge and ensure not in reset
    @(vif.dr_cb);
    
    // Drive instruction to DUT
    vif.dr_cb.instr_data <= req.instr_data;
    vif.dr_cb.data_rd    <= req.data_rd;
    
    `uvm_info(get_full_name(), $sformatf("Driving instr_data: 0x%08h", req.instr_data), UVM_HIGH);
  endtask

  /*
   * Task: reset
   * Resets the DUT inputs to known state.
   */
  task reset();
    @(vif.dr_cb);
    vif.dr_cb.instr_data <= 32'd0;
    vif.dr_cb.data_rd    <= 32'd0;
    `uvm_info(get_full_name(), "Driver reset completed", UVM_MEDIUM);
  endtask

endclass

`endif