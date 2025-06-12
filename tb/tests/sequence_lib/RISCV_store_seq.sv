//------------------------------------------------------------------------------
// Store sequence for RISCV
//------------------------------------------------------------------------------
// This sequence generates randomized transactions for the RISCV UVM verification.
//
// Author: Gustavo Santiago
// Date  : June 2025
//------------------------------------------------------------------------------

`ifndef RISCV_STORE_SEQ 
`define RISCV_STORE_SEQ

class RISCV_store_seq extends uvm_sequence#(RISCV_transaction);
   
  `uvm_object_utils(RISCV_store_seq)

  function new(string name = "RISCV_store_seq");
    super.new(name);
  endfunction

  // Fields to be randomized
  rand bit [4:0] rs1;
  rand bit [4:0] rs2;
  rand bit [11:0] imm;

  // Fixed opcode and funct3 for store instructions
  localparam bit [6:0] STORE_OPCODE = 7'b0100011;
  localparam bit [2:0] funct3 = 3'b010;

  virtual task body();
    // Generate multiple store transactions
    repeat(`NO_OF_TRANSACTIONS) begin
      req = RISCV_transaction::type_id::create("req");
      start_item(req);

      // Randomize the fields
      if (!randomize(rs1, rs2, imm)) 
        `uvm_fatal(get_type_name(), "Randomization failed!");

      imm[1:0] = 2'b00; // Align to word boundary for SW instruction

      // Build the store instruction (S-type encoding)
      req.instr_data = {
        imm[11:5], rs2, rs1, funct3, imm[4:0], STORE_OPCODE
      };
      req.instr_name = $sformatf("SW x%0d, %0d(x%0d)", rs2, $signed(imm), rs1);

      `uvm_info(get_full_name(), $sformatf("Generated STORE instruction: %s", req.instr_name), UVM_LOW);
      
      finish_item(req);
    end
  endtask
   
endclass

`endif