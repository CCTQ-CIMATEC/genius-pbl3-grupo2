//------------------------------------------------------------------------------
// SRL sequence for RISCV
//------------------------------------------------------------------------------
// This sequence generates randomized transactions for the RISCV UVM verification.
//
// Author: Leonardo Rodrigues
// Date  : July 2025
//------------------------------------------------------------------------------


`ifndef RISCV_SRL_SEQ
`define RISCV_SRL_SEQ

class RISCV_srl_seq extends uvm_sequence#(RISCV_transaction);

  `uvm_object_utils(RISCV_srl_seq)

  // Campos que serão randomizados
  
  rand bit [4:0]  rs2_srl;  
  rand bit [4:0]  rs1_srl;  
  rand bit [4:0]  rd_srl;  

  // Constantes fixas para_ssl
  localparam bit [6:0] SRL_FUNCT7 = 7'b0000000;
  localparam bit [6:0] SRL_OPCODE = 7'b0110011;
  localparam bit [2:0] SRL_FUNCT3 = 3'b101;

  function new(string name = "RISCV_srl_seq");
    super.new(name);
  endfunction

  virtual task body();
   // Generate multiple_ssl transactions
    repeat(`NO_OF_TRANSACTIONS) begin

      req = RISCV_transaction::type_id::create("req");
      start_item(req);

      if (!randomize(rs1_srl, rs2_srl, rd_srl)) begin
        `uvm_fatal(get_type_name(), "Randomization failed!");
      end

      // Monta a instrução tipo R _ssl)
      req.instr_data = {
       SRL_FUNCT7, rs2_srl, rs1_srl, rd_srl, SRL_FUNCT3, SRL_OPCODE 
      };

            req.instr_name = $sformatf("ADDRESS: x%0d, x%0d, x%0d", rd_srl, rs1_srl, rs2_srl);

        `uvm_info(get_full_name(), $sformatf("Generated_SSL instruction: %s", req.instr_name), UVM_LOW);


      finish_item(req);
    end
  endtask

endclass

`endif