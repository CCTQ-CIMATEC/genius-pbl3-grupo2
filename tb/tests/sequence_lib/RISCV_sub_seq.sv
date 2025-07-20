//------------------------------------------------------------------------------
// SUB sequence for RISCV
//------------------------------------------------------------------------------
// This sequence generates randomized transactions for the RISCV SUB instruction verification.
//
// Author: Angelo
// Date  : July 2025
//------------------------------------------------------------------------------
 
 
`ifndef RISCV_SUB_SEQ
`define RISCV_SUB_SEQ
 
class RISCV_sub_seq extends uvm_sequence#(RISCV_transaction);
 
  `uvm_object_utils(RISCV_sub_seq)
 
  // Campos que serão randomizados
//  rand bit [31:0] rs1_value; 
//  rand bit [31:0] rs2_value; 
//  rand bit [31:0] rd_value;  
 
  logic [31:0] regfile[32];
 
  rand bit [4:0]  rs2_addr;  
  rand bit [4:0]  rs1_addr;  
  rand bit [4:0]  rd_addr;  
 
  // Constantes fixas para SUB
  localparam bit [6:0] SUB_FUNCT7 = 7'b0100000; // Funct7 para SUB (diferente do ADD)
  localparam bit [6:0] SUB_OPCODE = 7'b0110011; // Mesmo opcode do ADD (R-type)
  localparam bit [2:0] SUB_FUNCT3 = 3'b000;     // Mesmo funct3 do ADD
 
  function new(string name = "RISCV_sub_seq");
    super.new(name);
  endfunction
 
  virtual task body();
   // Generate multiple sub transactions
    repeat(`NO_OF_TRANSACTIONS) begin
 
      req = RISCV_transaction::type_id::create("req");
      start_item(req);
 
      if (!randomize(rs1_addr, rs2_addr)) begin
        `uvm_fatal(get_type_name(), "Randomization failed!");
      end
 
      // Calcula o resultado esperado da subtração
      //rd_value = rs1_value - rs2_value;
 
      // Monta a instrução tipo R (SUB)
      req.instr_data = {
       SUB_FUNCT7, rs2_addr, rs1_addr, rd_addr, SUB_FUNCT3, SUB_OPCODE 
      };
 
      req.instr_name = $sformatf("SUB x%0d, x%0d, x%0d | VALUES: %0d - %0d = %0d", 
                                rd_addr, rs1_addr, rs2_addr);
 
      `uvm_info(get_full_name(), $sformatf("Generated SUB instruction: %s", req.instr_name), UVM_LOW);
 
      finish_item(req);
    end
  endtask
 
endclass
 
`endif