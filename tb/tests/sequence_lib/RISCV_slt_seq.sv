//------------------------------------------------------------------------------
// SLT sequence for RISCV
//------------------------------------------------------------------------------
// This sequence generates randomized transactions for the RISCV UVM verification.
//
// Author: Angelo Santos
// Date  : July 2025
//------------------------------------------------------------------------------

`ifndef RISCV_SLT_SEQ
`define RISCV_SLT_SEQ

class RISCV_slt_seq extends uvm_sequence#(RISCV_transaction);

  `uvm_object_utils(RISCV_slt_seq)

  // Campos randomizados
  rand bit [4:0] rs2_slt;
  rand bit [4:0] rs1_slt;
  rand bit [4:0] rd_slt;

  // Constantes para SLT (R-type)
  localparam bit [6:0] SLT_FUNCT7 = 7'b0000000;
  localparam bit [6:0] SLT_OPCODE = 7'b0110011;
  localparam bit [2:0] SLT_FUNCT3 = 3'b010;

  function new(string name = "RISCV_slt_seq");
    super.new(name);
  endfunction

  virtual task body();
    repeat(`NO_OF_TRANSACTIONS) begin
      req = RISCV_transaction::type_id::create("req");
      start_item(req);

      if (!randomize(rs1_slt, rs2_slt, rd_slt)) begin
        `uvm_fatal(get_type_name(), "Randomization failed!");
      end

      // Monta instrução tipo R (SLT)
      req.instr_data = {
        SLT_FUNCT7, rs2_slt, rs1_slt, rd_slt, SLT_FUNCT3, SLT_OPCODE
      };

      req.instr_name = $sformatf("SLT x%0d, x%0d, x%0d", rd_slt, rs1_slt, rs2_slt);

      `uvm_info(get_full_name(), $sformatf("Generated SLT instruction: %s", req.instr_name), UVM_LOW);

      finish_item(req);
    end
  endtask

endclass

`endif
