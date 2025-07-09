//------------------------------------------------------------------------------
// Transaction class for RISCV operations
//------------------------------------------------------------------------------
// This class defines the transaction fields and constraints for RISCV operations.
//
// Author: Gustavo Santiago
// Date  : June 2025
//------------------------------------------------------------------------------

`ifndef RISCV_TRANSACTION 
`define RISCV_TRANSACTION

class RISCV_transaction_block extends RISCV_transaction;

  // Input parameters (instruction and memory interface signals)
  bit [`P_DATA_WIDTH-1:0] instr_data [95:0];
  rand bit [`P_DATA_WIDTH-1:0] data_rd [95:0];

  // Expected output signals from the CPU (used by monitor or scoreboard)
  bit [`P_IMEM_ADDR_WIDTH-1:0] inst_addr [255:0];
  bit [`P_DATA_WIDTH-1:0] data_wr [95:0];
  bit [`P_DMEM_ADDR_WIDTH-1:0] data_addr [255:0];
  bit data_wr_en_ma [95:0];

  // Instruction type name, useful for debugging and logging
  string instr_name [95:0];

  `uvm_object_utils_begin(RISCV_transaction)
    `uvm_field_int(instr_data,        UVM_ALL_ON)
    `uvm_field_int(data_rd,           UVM_ALL_ON)
    `uvm_field_int(inst_addr,         UVM_ALL_ON)
    `uvm_field_int(data_wr,           UVM_ALL_ON)
    `uvm_field_int(data_addr,         UVM_ALL_ON)
    `uvm_field_int(data_wr_en_ma,     UVM_ALL_ON)
    `uvm_field_string(instr_name,     UVM_ALL_ON)
  `uvm_object_utils_end

  // Constructor
  function new(string name = "RISCV_transaction");
    super.new(name);
  endfunction

  /*
   * Method: post_randomize
   */
  function void post_randomize();
  endfunction 

  function void unpack_transactions(ref RISCV_transaction transactions[$]);
  RISCV_transaction single_tr;
  for (int i = 0; i < instr_data.size(); i++) begin
    single_tr = RISCV_transaction::type_id::create($sformatf("tr_%0d", i));
    
    single_tr.instr_data    = instr_data[i];
    single_tr.data_rd       = data_rd[i];
    single_tr.inst_addr     = inst_addr[i];
    single_tr.data_wr       = data_wr[i];
    single_tr.data_addr     = data_addr[i];
    single_tr.data_wr_en_ma = data_wr_en_ma[i];
    single_tr.instr_name    = instr_name[i];

    transactions.push_back(single_tr);
  end
endfunction

endclass

`endif