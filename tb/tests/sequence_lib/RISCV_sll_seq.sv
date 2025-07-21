//------------------------------------------------------------------------------
// SLL sequence for RISCV
//------------------------------------------------------------------------------
// This sequence generates randomized transactions for the RISCV UVM verification.
//
// Author: Leonardo Rodrigues
// Date  : July 2025
//------------------------------------------------------------------------------


`ifndef RISCV_SLL_SEQ
`define RISCV_SLL_SEQ

class RISCV_sll_seq extends uvm_sequence#(RISCV_transaction);

  `uvm_object_utils(RISCV_sll_seq)

  // Campos que serão randomizados
  
  rand bit [4:0]  rs2_sll;  
  rand bit [4:0]  rs1_sll;  
  rand bit [4:0]  rd_sll;  

  // Constantes fixas para_ssl
  localparam bit [6:0] SLL_FUNCT7 = 7'b0000000;
  localparam bit [6:0] SLL_OPCODE = 7'b0110011;
  localparam bit [2:0] SLL_FUNCT3 = 3'b001;

  function new(string name = "RISCV_sll_seq");
    super.new(name);
  endfunction

  virtual task body();
   // Generate multiple_ssl transactions
    repeat(`NO_OF_TRANSACTIONS) begin

      req = RISCV_transaction::type_id::create("req");
      start_item(req);

      if (!randomize(rs1_sll, rs2_sll, rd_sll)) begin
        `uvm_fatal(get_type_name(), "Randomization failed!");
      end

      // Monta a instrução tipo R _ssl)
      req.instr_data = {
       SLL_FUNCT7, rs2_sll, rs1_sll, rd_sll, SLL_FUNCT3, SLL_OPCODE 
      };

            req.instr_name = $sformatf("ADDRESS: x%0d, x%0d, x%0d", rd_sll, rs1_sll, rs2_sll);

        `uvm_info(get_full_name(), $sformatf("Generated_SSL instruction: %s", req.instr_name), UVM_LOW);


      finish_item(req);
    end
  endtask

endclass

`endif