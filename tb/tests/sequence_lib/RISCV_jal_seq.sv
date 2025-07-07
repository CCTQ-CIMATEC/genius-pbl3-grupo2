//------------------------------------------------------------------------------
// Store sequence for RISCV
//------------------------------------------------------------------------------
// This sequence generates randomized transactions for the RISCV UVM verification.
//
// Author: Gustavo Santiago
// Date  : July 2025
//------------------------------------------------------------------------------

`ifndef RISCV_JAL_SEQ 
`define RISCV_JAL_SEQ

class RISCV_jal_seq extends uvm_sequence#(RISCV_transaction);
   
  `uvm_object_utils(RISCV_jal_seq)

  function new(string name = "RISCV_jal_seq");
    super.new(name);
  endfunction

  // Fields to be randomized
  rand bit [4:0] rd;
  rand bit [19:0] imm;

  constraint rd_not_zero {
    rd != 5'd0;
  }
  
  // Fixed opcode and funct3 for jal instructions
  localparam bit [6:0] JAL_OPCODE = 7'b1101111;

  virtual task body();
    // Generate multiple jal transactions
    repeat(`NO_OF_TRANSACTIONS) begin
      req = RISCV_transaction::type_id::create("req");
      start_item(req);

      // Randomize the fields
      if (!randomize(rd, imm)) 
        `uvm_fatal(get_type_name(), "Randomization failed!");

      imm[1:0] = 2'b00; // Align to word boundary for SW instruction

      // Build the jal instruction (S-type encoding)
      req.instr_data = {
        imm, rd, JAL_OPCODE
      };

      req.instr_name = $sformatf("JAL %d 0x%0h", rd, imm);

      `uvm_info(get_full_name(), $sformatf("Generated JAL instruction: %s", req.instr_name), UVM_LOW);
      
      finish_item(req);
    end
  endtask
   
endclass

`endif