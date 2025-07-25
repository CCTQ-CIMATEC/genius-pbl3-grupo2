//------------------------------------------------------------------------------
// SRA sequence for RISCV
//------------------------------------------------------------------------------
// This sequence generates randomized transactions for the RISCV SRA instruction verification.
//
// Author: Henrique Teixeira
// Date  : July 2025
//------------------------------------------------------------------------------

`ifndef RISCV_SRA_SEQ
`define RISCV_SRA_SEQ

class RISCV_sra_seq extends uvm_sequence#(RISCV_transaction);

  `uvm_object_utils(RISCV_sra_seq)

  // Randomized fields for operands
  rand bit [4:0] rs2_sra;
  rand bit [4:0] rs1_sra;
  rand bit [4:0] rd_sra;

  // Fixed SRA instruction encoding (R-type)
  localparam bit [6:0] SRA_FUNCT7 = 7'b0100000;
  localparam bit [6:0] SRA_OPCODE = 7'b0110011;
  localparam bit [2:0] SRA_FUNCT3 = 3'b101;

  function new(string name = "RISCV_sra_seq");
    super.new(name);
  endfunction

  virtual task body();
    // Generate multiple SRA transactions
    repeat(`NO_OF_TRANSACTIONS) begin

      req = RISCV_transaction::type_id::create("req");
      start_item(req);

      if (!randomize(rs1_sra, rs2_sra, rd_sra)) begin
        `uvm_fatal(get_type_name(), "Randomization failed!");
      end

      // Assemble the R-type SRA instruction
      req.instr_data = {
        SRA_FUNCT7, rs2_sra, rs1_sra, rd_sra, SRA_FUNCT3, SRA_OPCODE
      };

      req.instr_name = $sformatf("SRA x%0d, x%0d, x%0d", rd_sra, rs1_sra, rs2_sra);

      `uvm_info(get_full_name(), $sformatf("Generated SRA instruction: %s", req.instr_name), UVM_LOW);

      finish_item(req);
    end
  endtask

endclass

`endif
