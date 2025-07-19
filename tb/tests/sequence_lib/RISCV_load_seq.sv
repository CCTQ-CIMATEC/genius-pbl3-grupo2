//------------------------------------------------------------------------------
// Load sequence for RISCV
//------------------------------------------------------------------------------
// This sequence generates randomized transactions for the RISCV UVM verification.
//
// Author: Leonardo Rodrigues
// Date  : June 2025
//------------------------------------------------------------------------------


`ifndef RISCV_LOAD_SEQ
`define RISCV_LOAD_SEQ

class RISCV_load_seq extends uvm_sequence#(RISCV_transaction);

  `uvm_object_utils(RISCV_load_seq)

  // Campos que serão randomizados
  rand bit [4:0] rs1;
  rand bit [4:0] rd;
  rand bit [11:0] imm;
  rand bit [31:0] data_to_load;
  rand int unsigned load_type;
  bit [2:0] funct3;

  string instr_name;

  // Constantes
  localparam bit [6:0] LOAD_OPCODE = 7'b0000011;
  localparam bit [2:0] LB_FUNCT3  = 3'b000;
  localparam bit [2:0] LH_FUNCT3  = 3'b001;
  localparam bit [2:0] LW_FUNCT3  = 3'b010;
  localparam bit [2:0] LBU_FUNCT3 = 3'b100;
  localparam bit [2:0] LHU_FUNCT3 = 3'b101;

  function new(string name = "RISCV_load_seq");
    super.new(name);
  endfunction

  virtual task body();
   // Generate multiple load transactions
    repeat(`NO_OF_TRANSACTIONS) begin
      req = RISCV_transaction::type_id::create("req");
      start_item(req);

      if (!randomize(rs1, rd, imm, data_to_load, load_type) with { load_type inside {[0:4]}; }) begin
        `uvm_fatal(get_type_name(), "Randomization failed!");
      end


      if (load_type == 0) begin
        funct3 = LB_FUNCT3;
        instr_name = "LB";
      end
      else if (load_type == 1) begin
        funct3 = LH_FUNCT3;
        imm[0] = 1'b0; // halfword alignment
        instr_name = "LH";
      end
      else if (load_type == 2) begin
        funct3 = LW_FUNCT3;
        imm[1:0] = 2'b00; // word alignment
        instr_name = "LW";
      end
      else if (load_type == 3) begin
        funct3 = LBU_FUNCT3;
        instr_name = "LBU";
      end
      else begin
        funct3 = LHU_FUNCT3;
        imm[0] = 1'b0; // halfword alignment
        instr_name = "LHU";
      end

      // Monta a instrução tipo I
      req.instr_data = {
        imm,        // [31:20] immediate
        rs1,        // [19:15] base register
        LW_FUNCT3,  // [14:12] funct3
        rd,         // [11:7] destination register
        LOAD_OPCODE // [6:0] opcode
      };

      req.data_rd = data_to_load; // Dados que serão lidos
      req.instr_name = $sformatf("%s x%0d, %0d(x%0d)", instr_name, rd, $signed(imm), rs1);

      `uvm_info(get_full_name(), $sformatf("Generated LOAD instruction: %s", req.instr_name), UVM_LOW);

      finish_item(req);
    end
  endtask

endclass

`endif