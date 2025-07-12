//------------------------------------------------------------------------------
// SLTI sequence for RISCV
//------------------------------------------------------------------------------
// This sequence generates randomized SLTI transactions for the RISCV UVM verification.
//
// Author: Henrique Teixeira
// Date  : July 2025
//------------------------------------------------------------------------------

`ifndef RISCV_SLTI_SEQ
`define RISCV_SLTI_SEQ

class RISCV_slti_seq extends uvm_sequence#(RISCV_transaction);

  `uvm_object_utils(RISCV_slti_seq)

  // Fields to randomize
  rand bit [11:0] imm;
  rand bit [4:0]  rs1_addr;
  rand bit [4:0]  rd_addr;

  // SLTI constants (I-type)
  localparam bit [6:0] SLTI_OPCODE = 7'b0010011;
  localparam bit [2:0] SLTI_FUNCT3 = 3'b010;

  function new(string name = "RISCV_slti_seq");
    super.new(name);
  endfunction

  virtual task body();
    repeat(`NO_OF_TRANSACTIONS) begin
      req = RISCV_transaction::type_id::create("req");
      start_item(req);

      if (!randomize(rs1_addr, rd_addr, imm)) begin
        `uvm_fatal(get_type_name(), "Randomization failed!");
      end

      // Build SLTI I-type instruction
      req.instr_data = { imm, rs1_addr, SLTI_FUNCT3, rd_addr, SLTI_OPCODE };

      req.instr_name = $sformatf("SLTI x%0d, x%0d, %0d", rd_addr, rs1_addr, $signed(imm));

      `uvm_info(get_full_name(), $sformatf("Generated SLTI instruction: %s", req.instr_name), UVM_LOW);

      finish_item(req);
    end
  endtask

endclass

`endif
