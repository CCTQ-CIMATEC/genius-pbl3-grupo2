//------------------------------------------------------------------------------
// AUIPC sequence for RISCV
//------------------------------------------------------------------------------
// This sequence generates randomized AUIPC instructions for RISCV UVM verification.
// It builds U-type instructions with random immediates and destination registers,
// modeling the AUIPC behavior (PC + imm << 12).
//
// Author: Henrique Teixeira
// Date  : July 2025
//------------------------------------------------------------------------------

`ifndef RISCV_AUIPC_SEQ
`define RISCV_AUIPC_SEQ

class RISCV_auipc_seq extends uvm_sequence#(RISCV_transaction);

  `uvm_object_utils(RISCV_auipc_seq)

  // Randomizable fields
  rand bit [19:0] imm;
  rand bit [4:0]  rd_addr;

  // AUIPC opcode constant
  localparam bit [6:0] AUIPC_OPCODE = 7'b0010111;

  function new(string name = "RISCV_auipc_seq");
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


      // Build U-type instruction encoding
      req.instr_data = {
        imm, rd_addr, AUIPC_OPCODE
      };

      req.instr_name = $sformatf(
        "AUIPC x%0d, 0x%0h",
        rd_addr, imm
      );

      `uvm_info(get_full_name(), $sformatf("Generated AUIPC instruction: %s", req.instr_name), UVM_LOW);

      finish_item(req);
    end
  endtask

endclass

`endif
