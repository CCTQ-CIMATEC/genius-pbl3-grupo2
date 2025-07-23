//------------------------------------------------------------------------------
// SRLI sequence for RISCV
//------------------------------------------------------------------------------
// This sequence generates randomized transactions for the RISCV UVM verification.
//
// Author: Leonardo Rodrigues
// Date  : July 2025
//------------------------------------------------------------------------------


`ifndef RISCV_SRLI_SEQ
`define RISCV_SRLI_SEQ

class RISCV_srli_seq extends uvm_sequence#(RISCV_transaction);

  `uvm_object_utils(RISCV_srli_seq)

  // Campos que serão randomizados
  
  rand bit [4:0]  shamt_srli;  
  rand bit [4:0]  rs1_srli;  
  rand bit [4:0]  rd_srli;  

  // Constantes fixas para_ssl
  localparam bit [6:0] SRLI_FUNCT7 = 7'b0000000;
  localparam bit [6:0] SRLI_OPCODE = 7'b0010011;
  localparam bit [2:0] SRLI_FUNCT3 = 3'b101;
  
  function new(string name = "RISCV_srli_seq");
    super.new(name);
  endfunction

  virtual task body();
   // Generate multiple_ssl transactions
    repeat(`NO_OF_TRANSACTIONS) begin

      req = RISCV_transaction::type_id::create("req");
      start_item(req);

      if (!randomize(rs1_srli, shamt_srli, rd_srli)) begin
        `uvm_fatal(get_type_name(), "Randomization failed!");
      end

      // Monta a instrução tipo I)
      req.instr_data = {
       SRLI_FUNCT7, shamt_srli, rs1_srli, rd_srli, SRLI_FUNCT3, SRLI_OPCODE 
      };

            req.instr_name = $sformatf("ADDRESS: x%0d, x%0d, x%0d", rd_srli, rs1_srli, shamt_srli);

        `uvm_info(get_full_name(), $sformatf("Generated_SSL instruction: %s", req.instr_name), UVM_LOW);


      finish_item(req);
    end
  endtask

endclass

`endif