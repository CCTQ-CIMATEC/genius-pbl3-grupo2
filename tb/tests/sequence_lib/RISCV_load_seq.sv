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

  // Constantes fixas para LW
  localparam bit [6:0] LOAD_OPCODE = 7'b0000011;
  localparam bit [2:0] LW_FUNCT3   = 3'b010;

  function new(string name = "RISCV_load_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_full_name(), "======= Executando LOAD sequence com randomização =======", UVM_LOW);

    repeat(`NO_OF_TRANSACTIONS) begin
      req = RISCV_transaction::type_id::create("req");
      start_item(req);

      if (!randomize(rs1, rd, imm)) begin
        `uvm_fatal(get_type_name(), "Randomization failed!");
      end

      // Opcional: Alinhar o imm se quiser só acessos word-aligned (não obrigatório pra LW, mas pode evitar warnings de memória desalinhada)
      imm[1:0] = 2'b00;

      // Monta a instrução tipo I (LW)
      req.instr_data = {
        imm,        // [31:20] immediate
        rs1,        // [19:15] base register
        LW_FUNCT3,  // [14:12] funct3
        rd,         // [11:7] destination register
        LOAD_OPCODE // [6:0] opcode
      };

      req.instr_name = $sformatf("LW x%0d, %0d(x%0d)", rd, $signed(imm), rs1);

      // Não preenche manualmente data_addr, data_rd, etc.
      // Isso é papel do ref_model

      `uvm_info(get_full_name(), $sformatf("Generated LOAD instruction: %s", req.instr_name), UVM_LOW);

      finish_item(req);
    end
  endtask

endclass

`endif