//------------------------------------------------------------------------------
// XORI sequence for RISCV
//------------------------------------------------------------------------------
// This sequence generates randomized transactions for the RISCV XORI instruction verification.
//
// Author: Angelo Santos
// Date  : July 2025
//------------------------------------------------------------------------------
 
 
`ifndef RISCV_XORI_SEQ
`define RISCV_XORI_SEQ
 
class RISCV_xori_seq extends uvm_sequence#(RISCV_transaction);
 
  `uvm_object_utils(RISCV_xori_seq)
 
  // Campos que serão randomizados
  rand bit [11:0] imm;  
  rand bit [4:0]  rs1_addr;  
  rand bit [4:0]  rd_addr;  
 
  // Constantes fixas para XORI
  localparam bit [6:0] XORI_OPCODE = 7'b0010011; // I-type opcode
  localparam bit [2:0] XORI_FUNCT3 = 3'b100;     // Funct3 para XORI
 
  function new(string name = "RISCV_xori_seq");
    super.new(name);
  endfunction
 
  virtual task body();
   // Generate multiple xori transactions
    repeat(`NO_OF_TRANSACTIONS) begin
 
      req = RISCV_transaction::type_id::create("req");
      start_item(req);
 
      if (!randomize(imm, rs1_addr, rd_addr)) begin
        `uvm_fatal(get_type_name(), "Randomization failed!");
      end
 
      // Monta a instrução tipo I (XORI)
      req.instr_data = {
       imm, rs1_addr, XORI_FUNCT3, rd_addr, XORI_OPCODE
      };
 
      req.instr_name = $sformatf("XORI ADDRESS: x%0d, x%0d, %0d", rd_addr, rs1_addr, $signed(imm));
 
      `uvm_info(get_full_name(), $sformatf("Generated xori instruction: %s", req.instr_name), UVM_LOW);
 
      finish_item(req);
    end
  endtask
 
endclass
 
`endif
