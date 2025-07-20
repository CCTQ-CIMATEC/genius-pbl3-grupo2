//------------------------------------------------------------------------------
// ORI sequence for RISCV
//------------------------------------------------------------------------------
// This sequence generates randomized transactions for the RISCV ORI instruction verification.
//
// Author: Angelo
// Date  : July 2025
//------------------------------------------------------------------------------
 
 
`ifndef RISCV_ORI_SEQ
`define RISCV_ORI_SEQ
 
class RISCV_ori_seq extends uvm_sequence#(RISCV_transaction);
 
  `uvm_object_utils(RISCV_ori_seq)
 
  // Campos que serão randomizados
  rand bit [31:0] rs1_value; 
  rand bit [31:0] rd_value;  
 
  logic [31:0] regfile[32];
 
  rand bit [11:0] imm;  
  rand bit [4:0]  rs1_addr;  
  rand bit [4:0]  rd_addr;  
 
  // Constantes fixas para ORI
  localparam bit [6:0] ORI_OPCODE = 7'b0010011; // Mesmo opcode de ADDI (I-type)
  localparam bit [2:0] ORI_FUNCT3 = 3'b110;     // Funct3 para ORI
 
  function new(string name = "RISCV_ori_seq");
    super.new(name);
  endfunction
 
  virtual task body();
   // Generate multiple ori transactions
    repeat(`NO_OF_TRANSACTIONS) begin
 
      req = RISCV_transaction::type_id::create("req");
      start_item(req);
 
      if (!randomize(imm, rs1_addr, rd_addr, rs1_value)) begin
        `uvm_fatal(get_type_name(), "Randomization failed!");
      end
 
      // Calcula o resultado esperado da operação OR com imediato
      // O imediato é sign-extended para 32 bits
      rd_value = rs1_value | {{20{imm[11]}}, imm};
 
      // Monta a instrução tipo I (ORI)
      req.instr_data = {
       imm, rs1_addr, ORI_FUNCT3, rd_addr, ORI_OPCODE
      };
 
      req.instr_name = $sformatf("ORI x%0d, x%0d, %0d | VALUES: 0x%08h | 0x%08h = 0x%08h", 
                                rd_addr, rs1_addr, $signed(imm), rs1_value, {{20{imm[11]}}, imm}, rd_value);
 
      `uvm_info(get_full_name(), $sformatf("Generated ORI instruction: %s", req.instr_name), UVM_LOW);
 
      finish_item(req);
    end
  endtask
 
endclass
 
`endif