//------------------------------------------------------------------------------
// SLTIU sequence for RISCV
//------------------------------------------------------------------------------
// This sequence generates randomized SLTIU transactions for the RISCV UVM verification.
//
// Author: Henrique Teixeira
// Date  : July 2025
//------------------------------------------------------------------------------

`ifndef RISCV_SLTIU_SEQ
`define RISCV_SLTIU_SEQ

class RISCV_sltiu_seq extends uvm_sequence#(RISCV_transaction);

  `uvm_object_utils(RISCV_sltiu_seq)

  // Fields to randomize
  rand bit [11:0] imm;
  rand bit [4:0]  rs1_addr;
  rand bit [4:0]  rd_addr;

  // SLTIU constants (I-type)
  localparam bit [6:0] SLTIU_OPCODE = 7'b0010011;
  localparam bit [2:0] SLTIU_FUNCT3 = 3'b011;

  function new(string name = "RISCV_sltiu_seq");
    super.new(name);
  endfunction

  virtual task body();
    repeat (`NO_OF_TRANSACTIONS) begin
      req = RISCV_transaction::type_id::create("req");
      start_item(req);

      // Create instruction using helper task
      get_instruction(req);

      finish_item(req);
    end
  endtask

  // Generate a SLTIU instruction
  virtual task get_instruction(ref RISCV_transaction req);

    if (!randomize(rs1_addr, rd_addr, imm)) begin
      `uvm_fatal(get_type_name(), "Randomization failed!");
    end

    // Build I-type SLTIU instruction
    req.instr_data = { imm, rs1_addr, SLTIU_FUNCT3, rd_addr, SLTIU_OPCODE };

    req.instr_name = $sformatf("SLTIU x%0d, x%0d, %0d", rd_addr, rs1_addr, imm);

    `uvm_info(get_full_name(), $sformatf("Generated SLTIU instruction: %s", req.instr_name), UVM_LOW);
  endtask

endclass

`endif
