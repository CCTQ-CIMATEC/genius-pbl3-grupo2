//------------------------------------------------------------------------------
// ANDI sequence for RISCV
//------------------------------------------------------------------------------
// This sequence generates randomized transactions for the RISCV UVM verification.
//
// Author: Henrique Teixeira
// Date  : July 2025
//------------------------------------------------------------------------------

`ifndef RISCV_ANDI_SEQ
`define RISCV_ANDI_SEQ

class RISCV_andi_seq extends uvm_sequence#(RISCV_transaction);

  `uvm_object_utils(RISCV_andi_seq)

  // Randomizable fields
  rand bit [31:0] rs1_value;
  rand bit [11:0] imm;
  rand bit [4:0]  rs1_addr;
  rand bit [4:0]  rd_addr;

  // Constants for ANDI
  localparam bit [6:0] ANDI_OPCODE = 7'b0010011;
  localparam bit [2:0] ANDI_FUNCT3 = 3'b111;

  function new(string name = "RISCV_andi_seq");
    super.new(name);
  endfunction

  virtual task body();
    bit [31:0] imm_sext;
    bit [31:0] rd_value;

    repeat(`NO_OF_TRANSACTIONS) begin
      req = RISCV_transaction::type_id::create("req");
      start_item(req);

      if (!randomize(imm, rs1_addr, rd_addr, rs1_value)) begin
        `uvm_fatal(get_type_name(), "Randomization failed!");
      end

      // Sign-extend the immediate
      imm_sext = {{20{imm[11]}}, imm};
      rd_value = rs1_value & imm_sext;

      // Build I-type instruction
      req.instr_data = {
        imm, rs1_addr, ANDI_FUNCT3, rd_addr, ANDI_OPCODE
      };

      req.data_rd = rd_value;

      req.instr_name = $sformatf(
        "ANDI x%0d, x%0d, %0d | %0d & %0d = %0d",
        rd_addr, rs1_addr, $signed(imm), rs1_value, $signed(imm_sext), rd_value
      );

      `uvm_info(get_full_name(), $sformatf("Generated ANDI instruction: %s", req.instr_name), UVM_LOW);

      finish_item(req);
    end
  endtask

endclass

`endif
