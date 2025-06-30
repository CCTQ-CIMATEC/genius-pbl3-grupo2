//------------------------------------------------------------------------------
// ADD sequence for RISCV
//------------------------------------------------------------------------------
// This sequence generates randomized transactions for the RISCV UVM verification.
//
// Author: Leonardo Rodrigues
// Date  : June 2025
//------------------------------------------------------------------------------


`ifndef RISCV_ADDI_SEQ
`define RISCV_ADDI_SEQ

class RISCV_addi_seq extends uvm_sequence#(RISCV_transaction);

  `uvm_object_utils(RISCV_addi_seq)

  // Campos que serão randomizados
  
  rand bit [11:0] imm;  
  rand bit [4:0]  rs1_addr;  
  rand bit [4:0]  rd_addr;  

  // Constantes fixas para ADDI
  localparam bit [6:0] ADDI_OPCODE = 7'b0010011;
  localparam bit [2:0] ADDI_FUNCT3 = 3'b000;

  function new(string name = "RISCV_addi_seq");
    super.new(name);
  endfunction

  virtual task body();
   // Generate multiple addi transactions
    repeat(`NO_OF_TRANSACTIONS) begin

      req = RISCV_transaction::type_id::create("req");
      start_item(req);

      if (!randomize(rs1_addr, rd_addr, imm)) begin
        `uvm_fatal(get_type_name(), "Randomization failed!");
      end

      // Monta a instrução tipo R (ADDI)
      req.instr_data = {
       imm, rs1_addr, ADDI_FUNCT3, rd_addr,  ADDI_OPCODE
      };

        req.instr_name = $sformatf("ADDI ADDRESS: x%0d, x%0d, %0d", rd_addr, rs1_addr, $signed(imm));

        `uvm_info(get_full_name(), $sformatf("Generated addi instruction: %s", req.instr_name), UVM_LOW);

      finish_item(req);
    end
  endtask

endclass

`endif