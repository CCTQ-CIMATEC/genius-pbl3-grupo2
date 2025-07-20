//------------------------------------------------------------------------------
// AND sequence for RISCV
//------------------------------------------------------------------------------
// This sequence generates randomized transactions for the RISCV UVM verification.
//
// Author: Leonardo Rodrigues
// Date  : June 2025
//------------------------------------------------------------------------------

`ifndef RISCV_AND_SEQ
`define RISCV_AND_SEQ

class RISCV_and_seq extends uvm_sequence#(RISCV_transaction);

  `uvm_object_utils(RISCV_and_seq)

  // Campos que serão randomizados
 
  rand bit [4:0]  rs2_addr;  
  rand bit [4:0]  rs1_addr;  
  rand bit [4:0]  rd_addr;  

  // Constantes fixas para AND
  localparam bit [6:0] AND_FUNCT7 = 7'b0000000; // Funct7 para AND
  localparam bit [6:0] AND_OPCODE = 7'b0110011; // Opcode para operações R-type
  localparam bit [2:0] AND_FUNCT3 = 3'b111;     // Funct3 para AND

  function new(string name = "RISCV_and_seq");
    super.new(name);
  endfunction

  virtual task body();
   // Generate multiple AND transactions
    repeat(`NO_OF_TRANSACTIONS) begin

      req = RISCV_transaction::type_id::create("req");
      start_item(req);

      if (!randomize(rs1_addr, rs2_addr)) begin
         `uvm_fatal(get_type_name(), "Randomization failed!");
      end

      // Monta a instrução tipo R (AND)
      req.instr_data = {
        AND_FUNCT7, rs2_addr, rs1_addr, AND_FUNCT3, rd_addr, AND_OPCODE 
      };

      req.instr_name = $sformatf("AND ADDRESS: x%0d, x%0d, x%0d", rd_addr, rs1_addr, rs2_addr);


      finish_item(req);
    end
  endtask

endclass

`endif