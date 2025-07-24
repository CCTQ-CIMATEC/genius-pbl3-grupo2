//------------------------------------------------------------------------------
// SLLI sequence for RISCV
//------------------------------------------------------------------------------
// This sequence generates randomized transactions for the RISCV UVM verification.
//
// Author: Angelo Santos
// Date  : July 2025
//------------------------------------------------------------------------------

`ifndef RISCV_SLLI_SEQ
`define RISCV_SLLI_SEQ

class RISCV_slli_seq extends uvm_sequence#(RISCV_transaction);

  `uvm_object_utils(RISCV_slli_seq)

  // Campos randomizados
  rand bit [4:0] shamt_slli;
  rand bit [4:0] rs1_slli;
  rand bit [4:0] rd_slli;

  // Constantes para SLLI
  localparam bit [6:0] SLLI_FUNCT7 = 7'b0000000;
  localparam bit [6:0] SLLI_OPCODE = 7'b0010011;
  localparam bit [2:0] SLLI_FUNCT3 = 3'b001;

  function new(string name = "RISCV_slli_seq");
    super.new(name);
  endfunction

  virtual task body();
    repeat(`NO_OF_TRANSACTIONS) begin
      req = RISCV_transaction::type_id::create("req");
      start_item(req);

      if (!randomize(rs1_slli, shamt_slli, rd_slli)) begin
        `uvm_fatal(get_type_name(), "Randomization failed!");
      end

      // Monta instrução tipo I (SLLI)
      req.instr_data = {
        SLLI_FUNCT7, shamt_slli, rs1_slli, rd_slli, SLLI_FUNCT3, SLLI_OPCODE
      };

      req.instr_name = $sformatf("SLLI x%0d, x%0d, %0d", rd_slli, rs1_slli, shamt_slli);

      `uvm_info(get_full_name(), $sformatf("Generated SLLI instruction: %s", req.instr_name), UVM_LOW);

      finish_item(req);
    end
  endtask

endclass

`endif
