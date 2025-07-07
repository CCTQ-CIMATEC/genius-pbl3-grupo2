//------------------------------------------------------------------------------
// LUI sequence for RISCV
//------------------------------------------------------------------------------
// This sequence generates randomized transactions for the RISCV UVM verification.
//
// Author: Henrique Teixeira
// Date  : July 2025
//------------------------------------------------------------------------------

`ifndef RISCV_LUI_SEQ
`define RISCV_LUI_SEQ

class RISCV_lui_seq extends uvm_sequence#(RISCV_transaction);

  `uvm_object_utils(RISCV_lui_seq)

  // Randomizable fields
  rand bit [19:0] imm;
  rand bit [4:0]  rd_addr;

  // Constants for LUI
  localparam bit [6:0] LUI_OPCODE = 7'b0110111;

  function new(string name = "RISCV_lui_seq");
    super.new(name);
  endfunction

  virtual task body();
    bit [31:0] rd_value;

    repeat(`NO_OF_TRANSACTIONS) begin
      req = RISCV_transaction::type_id::create("req");
      start_item(req);

      if (!randomize(imm, rd_addr)) begin
        `uvm_fatal(get_type_name(), "Randomization failed!");
      end

      rd_value = {imm, 12'b0};

      // Build U-type instruction
      req.instr_data = {
        imm, rd_addr, LUI_OPCODE
      };

      req.data_rd = rd_value;

      req.instr_name = $sformatf(
        "LUI x%0d, 0x%0h | Result = 0x%0h",
        rd_addr, imm, rd_value
      );

      `uvm_info(get_full_name(), $sformatf("Generated LUI instruction: %s", req.instr_name), UVM_LOW);

      finish_item(req);
    end
  endtask

endclass

`endif
