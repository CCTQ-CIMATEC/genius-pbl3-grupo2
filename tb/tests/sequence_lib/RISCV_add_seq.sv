//------------------------------------------------------------------------------
// ADD sequence for RISCV
//------------------------------------------------------------------------------
// This sequence generates randomized transactions for the RISCV UVM verification.
//
// Author: Leonardo Rodrigues
// Date  : June 2025
//------------------------------------------------------------------------------


`ifndef RISCV_ADD_SEQ
`define RISCV_ADD_SEQ

class RISCV_add_seq extends uvm_sequence#(RISCV_transaction);

  `uvm_object_utils(RISCV_add_seq)

  // Campos que serão randomizados
  
  bit [31:0] rs1_value = 2; // Valor do registrador rs1
  bit [31:0] rs2_value = 3; // Valor do registrador rs2
  bit [31:0] rd_value; 

  logic [31:0] regfile[32];

  rand bit [4:0]  rs2_addr;  
  rand bit [4:0]  rs1_addr;   
       bit [4:0]  rd_addr;

  // Constantes fixas para ADD
  localparam bit [6:0] ADD_FUNCT7 = 7'b0000000; // Funct7 para ADD
  localparam bit [6:0] ADD_OPCODE = 7'b0110011;
  localparam bit [2:0] ADD_FUNCT3 = 3'b000;

  function new(string name = "RISCV_add_seq");
    super.new(name);
  endfunction

  virtual task body();
   // Generate multiple add transactions
    repeat(`NO_OF_TRANSACTIONS) begin
      req = RISCV_transaction::type_id::create("req");
      start_item(req);

      if (!randomize(rs1_addr, rs2_addr)) begin
        `uvm_fatal(get_type_name(), "Randomization failed!");
      end

        rs1_addr = regfile[rs1_value];
        rs2_addr = regfile[rs2_value];

      // Monta a instrução tipo R (ADD)
      req.instr_data = {
       ADD_FUNCT7, rs2_addr, rs1_addr, rd_addr, ADD_FUNCT3, ADD_OPCODE 
      };

      req.instr_name   = $sformatf("ADD x%0d, x%0d, x%0d", rs2_addr, rs1_addr, rd_addr);

      `uvm_info(get_full_name(), $sformatf("Generated add instruction: %s", req.instr_name), UVM_LOW);

      finish_item(req);
    end
  endtask

endclass

`endif