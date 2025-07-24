//------------------------------------------------------------------------------
// SLTU sequence for RISCV
//------------------------------------------------------------------------------
// This sequence generates randomized transactions for the RISCV UVM verification.
//
// Author: Angelo Santos
// Date  : July 2025
//------------------------------------------------------------------------------

`ifndef RISCV_SLTU_SEQ
`define RISCV_SLTU_SEQ

class RISCV_sltu_seq extends uvm_sequence#(RISCV_transaction);

  `uvm_object_utils(RISCV_sltu_seq)

  // Campos randomizados
  rand bit [4:0] rs2_sltu;
  rand bit [4:0] rs1_sltu;
  rand bit [4:0] rd_sltu;

  // Constantes para SLTU (R-type)
  localparam bit [6:0] SLTU_FUNCT7 = 7'b0000000;
  localparam bit [6:0] SLTU_OPCODE = 7'b0110011;
  localparam bit [2:0] SLTU_FUNCT3 = 3'b011;

  function new(string name = "RISCV_sltu_seq");
    super.new(name);
  endfunction

  virtual task body();
    repeat(`NO_OF_TRANSACTIONS) begin
      req = RISCV_transaction::type_id::create("req");
      start_item(req);

      if (!randomize(rs1_sltu, rs2_sltu, rd_sltu)) begin
        `uvm_fatal(get_type_name(), "Randomization failed!");
      end

      // Monta instrução tipo R (SLTU)
      req.instr_data = {
        SLTU_FUNCT7, rs2_sltu, rs1_sltu, rd_sltu, SLTU_FUNCT3, SLTU_OPCODE
      };

      req.instr_name = $sformatf("SLTU x%0d, x%0d, x%0d", rd_sltu, rs1_sltu, rs2_sltu);

      `uvm_info(get_full_name(), $sformatf("Generated SLTU instruction: %s", req.instr_name), UVM_LOW);

      finish_item(req);
    end
  endtask

endclass

`endif
