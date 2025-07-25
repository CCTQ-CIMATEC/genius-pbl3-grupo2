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

class RISCV_transaction extends uvm_sequence_item;

  // Input parameters (instruction and memory interface signals)
       bit [`P_DATA_WIDTH-1:0]      instr_data;
  rand bit [`P_DATA_WIDTH-1:0]      data_rd;

  // Expected output signals from the CPU (used by monitor or scoreboard)
       bit [`P_DMEM_ADDR_WIDTH-1:0] inst_addr;
       bit [`P_DATA_WIDTH-1:0]      data_wr;
       bit [`P_DMEM_ADDR_WIDTH-1:0] data_addr;
       bit                          data_wr_en_ma;

       bit inBurst;

  // Instruction type name, useful for debugging and logging
  string instr_name;

  `uvm_object_utils_begin(RISCV_transaction)
    `uvm_field_int(instr_data,        UVM_ALL_ON)
    `uvm_field_int(data_rd,           UVM_ALL_ON)
    `uvm_field_int(inst_addr,         UVM_ALL_ON)
    `uvm_field_int(data_wr,           UVM_ALL_ON)
    `uvm_field_int(data_addr,         UVM_ALL_ON)
    `uvm_field_int(data_wr_en_ma,     UVM_ALL_ON)
    `uvm_field_int(inBurst,           UVM_ALL_ON)
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


  virtual function void unpack_transactions(ref RISCV_transaction transactions[$]);
  
endfunction

endclass

`endif