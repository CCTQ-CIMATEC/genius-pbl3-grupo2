//------------------------------------------------------------------------------
// Monitor module for RISCV agent
//------------------------------------------------------------------------------
// This module captures interface activity for the RISCV agent.
//
// Author: Gustavo Santiago
// Date  : June 2025
//------------------------------------------------------------------------------

`ifndef RISCV_MONITOR_BLOCK
`define RISCV_MONITOR_BLOCK

class RISCV_block_monitor extends RISCV_monitor;

  virtual RISCV_interface vif;
  int countdown_delay;
  RISCV_transaction transaction_queue[$];

  `uvm_component_utils(RISCV_block_monitor)

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual RISCV_interface)::get(this, "", "intf", vif))
      `uvm_fatal("NOVIF", {"Virtual interface must be set for: ", get_full_name(), ".vif"});
  endfunction : build_phase

  virtual task run_phase(uvm_phase phase);
    // Aguarda sair do reset uma vez
    wait(vif.reset);
    forever begin
      collect_inputs();   // Coleta entradas (instruções)
      collect_outputs();  // Coleta saídas (resultados)
      @(posedge vif.clk);
    end
  endtask : run_phase

  task collect_inputs();
    RISCV_transaction act_trans;
    
    if (vif.reset && vif.instr_data != 0) begin
        act_trans = RISCV_transaction::type_id::create("act_trans", this);
        
        // Captura apenas as entradas
        act_trans.instr_data = vif.instr_data;
        act_trans.data_rd = vif.data_rd;
        
        // Adiciona à fila para processamento posterior
        transaction_queue.push_back(act_trans);

        `uvm_info(get_full_name(), $sformatf("Input captured: instr=0x%08h", act_trans.instr_data), UVM_LOW);
      end
      else begin 
        countdown_delay = 4;
      end
  endtask : collect_inputs

  task collect_outputs();
    RISCV_transaction complete_trans;
    if (vif.reset && vif.instr_data != 0) begin
        complete_trans = transaction_queue.pop_front();

        complete_trans.inst_addr = vif.inst_addr;
        complete_trans.data_wr = vif.data_wr;
        complete_trans.data_addr = vif.data_addr;
        complete_trans.data_wr_en_ma = vif.data_wr_en_ma;
        
        `uvm_info(get_full_name(), $sformatf("Monitor captured complete transaction"), UVM_LOW);
        complete_trans.print();
        
        // Envia para o scoreboard
        super.mon2sb_port.write(complete_trans);
      

        
    end
  endtask : collect_outputs

endclass

`endif