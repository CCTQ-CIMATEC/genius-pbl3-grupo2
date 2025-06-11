//------------------------------------------------------------------------------
// Monitor module for RISCV agent
//------------------------------------------------------------------------------
// This module captures interface activity for the RISCV agent.
//
// Author: Gustavo Santiago
// Date  : June 2025
//------------------------------------------------------------------------------

`ifndef RISCV_MONITOR 
`define RISCV_MONITOR

class RISCV_monitor extends uvm_monitor;
 
  virtual RISCV_interface vif;
  uvm_analysis_port #(RISCV_transaction) mon2sb_port;

  `uvm_component_utils(RISCV_monitor)

  function new (string name, uvm_component parent);
    super.new(name, parent);
    mon2sb_port = new("mon2sb_port", this);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual RISCV_interface)::get(this, "", "intf", vif))
      `uvm_fatal("NOVIF", {"Virtual interface must be set for: ", get_full_name(), ".vif"});
  endfunction : build_phase

  virtual task run_phase(uvm_phase phase);
    forever begin
      collect_trans();
    end
  endtask : run_phase

  task collect_trans();
    RISCV_transaction act_trans;

    wait(!vif.reset);  // Espera sair do reset

    act_trans = RISCV_transaction::type_id::create("act_trans", this);

    // Inputs
    act_trans.instr_ready   = vif.instr_ready;
    act_trans.instr_data    = vif.instr_data;

    act_trans.data_ready    = vif.data_ready;
    act_trans.data_rd       = vif.data_rd;

    // Outputs esperados
    act_trans.inst_rd_en     = vif.inst_rd_en;
    act_trans.inst_ctrl_cpu  = vif.inst_ctrl_cpu;
    act_trans.inst_addr      = vif.inst_addr;
    act_trans.data_wr        = vif.data_wr;
    act_trans.data_addr      = vif.data_addr;
    act_trans.data_rd_en_ctrl= vif.data_rd_en_ctrl;
    act_trans.data_rd_en_ma  = vif.data_rd_en_ma;
    act_trans.data_wr_en_ma  = vif.data_wr_en_ma;

    `uvm_info(get_full_name(), $sformatf("Monitor captured transaction:\n%s", act_trans.sprint()), UVM_LOW);

    mon2sb_port.write(act_trans);
  endtask : collect_trans

endclass : RISCV_monitor

`endif
