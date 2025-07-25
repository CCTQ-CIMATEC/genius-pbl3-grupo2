//------------------------------------------------------------------------------
// SRAI sequence for RISCV
//------------------------------------------------------------------------------
// This sequence generates randomized transactions for the RISCV SRAI instruction verification.
//
// Author: Henrique Teixeira
// Date  : July 2025
//------------------------------------------------------------------------------

`ifndef RISCV_SRAI_SEQ
`define RISCV_SRAI_SEQ

class RISCV_srai_seq extends uvm_sequence#(RISCV_transaction);

  `uvm_object_utils(RISCV_srai_seq)

  // Randomized fields for SRAI operands
  rand bit [4:0] shamt_srai;
  rand bit [4:0] rs1_srai;
  rand bit [4:0] rd_srai;

  // Fixed encoding fields for SRAI (I-type)
  localparam bit [6:0] SRAI_FUNCT7 = 7'b0100000;
  localparam bit [6:0] SRAI_OPCODE = 7'b0010011;
  localparam bit [2:0] SRAI_FUNCT3 = 3'b101;

  function new(string name = "RISCV_srai_seq");
    super.new(name);
  endfunction

  virtual task body();
    // Generate multiple SRAI transactions
    repeat(`NO_OF_TRANSACTIONS) begin

      req = RISCV_transaction::type_id::create("req");
      start_item(req);

      if (!randomize(rs1_srai, shamt_srai, rd_srai)) begin
        `uvm_fatal(get_type_name(), "Randomization failed!");
      end

      // Assemble I-type SRAI instruction
      req.instr_data = {
        SRAI_FUNCT7, shamt_srai, rs1_srai, rd_srai, SRAI_FUNCT3, SRAI_OPCODE
      };

      req.instr_name = $sformatf("SRAI x%0d, x%0d, %0d", rd_srai, rs1_srai, shamt_srai);

      `uvm_info(get_full_name(), $sformatf("Generated SRAI instruction: %s", req.instr_name), UVM_LOW);

      finish_item(req);
    end
  endtask

endclass

`endif
