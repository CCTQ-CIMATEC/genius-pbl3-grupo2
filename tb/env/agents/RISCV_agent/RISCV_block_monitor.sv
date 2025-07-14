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

  // Buffer para entradas aguardando delay
  RISCV_transaction input_buffer[$];

  // Transação atual em construção
  RISCV_transaction_block curr_block;
  RISCV_transaction trans_input;
  // Delay entre entrada e saída
  int unsigned delay_cycles = 4;
  int unsigned nop_count = 0;
  bit flag_initied = 0;
  int idx;

  `uvm_component_utils(RISCV_block_monitor)

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual RISCV_interface)::get(this, "", "intf", vif))
      `uvm_fatal("NOVIF", {"Virtual interface must be set for: ", get_full_name(), ".vif"});
  endfunction

  virtual task run_phase(uvm_phase phase);
    wait(vif.reset);
    repeat(1) @(posedge vif.clk);

    // Inicializa bloco atual
    curr_block = RISCV_transaction_block::type_id::create("curr_block");

    forever begin
      collect_input();
      collect_output_if_ready();
    end
  endtask

  // Captura a entrada (instr_data + data_rd)
  task collect_input();
    @(posedge vif.clk);
    if (vif.reset) begin
      if(vif.instr_data != 32'h0)begin
        flag_initied = 1;

        trans_input = RISCV_transaction::type_id::create("input_trans");
        trans_input.instr_data = vif.instr_data;;
        trans_input.data_rd    = vif.data_rd;

        input_buffer.push_back(trans_input);
      end
      else if(flag_initied) begin 
        if (vif.instr_data == 32'h0) begin//NOP verification
          nop_count++;
        end else begin
          nop_count = 0;
        end
      end
      
      `uvm_info(get_full_name(), $sformatf("Captured input: 0x%08h", vif.instr_data), UVM_LOW);
    end
  endtask

  // Processa saída após delay e completa a transação atual
  task collect_output_if_ready();
    if (input_buffer.size() >= delay_cycles) begin
      RISCV_transaction ready_trans = input_buffer.pop_front();

      // Aguarda delay
      repeat(delay_cycles) @(posedge vif.clk);

      // Captura sinais de saída
      ready_trans.inst_addr     = vif.inst_addr;
      ready_trans.data_wr       = vif.data_wr;
      ready_trans.data_addr     = vif.data_addr;
      ready_trans.data_wr_en_ma = vif.data_wr_en_ma;

      idx = curr_block.instr_data.size();

      curr_block.instr_data = new[idx + 1](curr_block.instr_data);
      curr_block.instr_data[idx] = ready_trans.instr_data;

      curr_block.data_rd = new[idx + 1](curr_block.data_rd);
      curr_block.data_rd[idx] = ready_trans.data_rd;

      curr_block.inst_addr = new[idx + 1](curr_block.inst_addr);
      curr_block.inst_addr[idx] = ready_trans.inst_addr;

      curr_block.data_wr = new[idx + 1](curr_block.data_wr);
      curr_block.data_wr[idx] = ready_trans.data_wr;

      curr_block.data_addr = new[idx + 1](curr_block.data_addr);
      curr_block.data_addr[idx] = ready_trans.data_addr;

      curr_block.data_wr_en_ma = new[idx + 1](curr_block.data_wr_en_ma);
      curr_block.data_wr_en_ma[idx] = ready_trans.data_wr_en_ma;

      curr_block.instr_name = new[idx + 1](curr_block.instr_name);
      curr_block.instr_name[idx] = ""; // ou ready_trans.instr_name

      // Se detectou 5 NOPs seguidos, finalize a transação
      if (nop_count >= 5) begin
        `uvm_info(get_full_name(), "Block complete. Sending RISCV_transaction_block.", UVM_LOW);
        curr_block.print();
        super.mon2sb_port.write(curr_block);

        // Reinicia para próximo bloco
        curr_block = RISCV_transaction_block::type_id::create("curr_block");
        nop_count = 0;
        flag_initied = 0;
      end
    end
  endtask

endclass

`endif