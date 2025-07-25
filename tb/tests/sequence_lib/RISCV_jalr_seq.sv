//------------------------------------------------------------------------------
// JALR sequence for RISCV
//------------------------------------------------------------------------------
// This sequence generates randomized transactions for the RISCV JALR instruction verification.
//
// Author: Henrique Teixeira
// Date  : July 2025
//------------------------------------------------------------------------------

`ifndef RISCV_JALR_SEQ
`define RISCV_JALR_SEQ

class RISCV_jalr_seq extends uvm_sequence#(RISCV_transaction);

  `uvm_object_utils(RISCV_jalr_seq)

  // Randomized fields for JALR
  rand bit [11:0] imm;
  rand bit [4:0]  rs1;
  rand bit [4:0]  rd;

  // Fixed values for JALR
  localparam bit [6:0] JALR_OPCODE = 7'b1100111;
  localparam bit [2:0] JALR_FUNCT3 = 3'b000;

  function new(string name = "RISCV_jalr_seq");
    super.new(name);
  endfunction

  virtual task body();
    // Generate multiple JALR transactions
    repeat(`NO_OF_TRANSACTIONS) begin

      req = RISCV_transaction::type_id::create("req");
      start_item(req);

      if (!randomize(rs1, rd, imm)) begin
        `uvm_fatal(get_type_name(), "Randomization failed!");
      end

      // Assemble I-type instruction for JALR
      req.instr_data = {
        imm, rs1, JALR_FUNCT3, rd, JALR_OPCODE
      };

      req.instr_name = $sformatf("JALR x%0d, x%0d, %0d", rd, rs1, $signed(imm));

      `uvm_info(get_full_name(), $sformatf("Generated JALR instruction: %s", req.instr_name), UVM_LOW);

      finish_item(req);
    end
  endtask

endclass

`endif
