//------------------------------------------------------------------------------
// Scoreboard module for RISCV
//------------------------------------------------------------------------------
// This module verifies transaction responses for the RISCV environment.
//
// Author: Gustavo Santiago
// Date  : June 2025
//------------------------------------------------------------------------------

`ifndef RISCV_SCOREBOARD
`define RISCV_SCOREBOARD

class RISCV_scoreboard extends uvm_scoreboard;

  /*
   * Component registration
   */
  `uvm_component_utils(RISCV_scoreboard)

  /*
   * Analysis ports and FIFOs
   */
  uvm_analysis_export#(RISCV_transaction) rm2sb_export, mon2sb_export;
  uvm_tlm_analysis_fifo#(RISCV_transaction) rm2sb_export_fifo, mon2sb_export_fifo;

  RISCV_transaction exp_trans, act_trans;
  RISCV_transaction exp_trans_fifo[$], act_trans_fifo[$];
  bit error;

  /*
   * Constructor
   */
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  /*
   * Build phase
   */
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    rm2sb_export = new("rm2sb_export", this);
    mon2sb_export = new("mon2sb_export", this);
    rm2sb_export_fifo = new("rm2sb_export_fifo", this);
    mon2sb_export_fifo = new("mon2sb_export_fifo", this);
  endfunction

  /*
   * Connect phase
   */
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    rm2sb_export.connect(rm2sb_export_fifo.analysis_export);
    mon2sb_export.connect(mon2sb_export_fifo.analysis_export);
  endfunction

  /*
   * Run phase: comparison loop
   */
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      mon2sb_export_fifo.get(act_trans);
      if (act_trans == null) $stop;
      act_trans_fifo.push_back(act_trans);

      rm2sb_export_fifo.get(exp_trans);
      if (exp_trans == null) $stop;
      exp_trans_fifo.push_back(exp_trans);

      compare_trans();
    end
  endtask

  /*
   * Transaction comparison
   */
  task compare_trans();
    RISCV_transaction act_trans, exp_trans;
    bit [6:0] opcode;

    if (exp_trans_fifo.size != 0 && act_trans_fifo.size != 0) begin
      exp_trans = exp_trans_fifo.pop_front();
      act_trans = act_trans_fifo.pop_front();

      opcode = exp_trans.instr_data[6:0];

      `uvm_info(get_full_name(), $sformatf("Expected instr = 0x%08x | Actual instr = 0x%08x", exp_trans.instr_data, act_trans.instr_data), UVM_LOW);

      // Sempre comparar a instrução
      if (exp_trans.instr_data !== act_trans.instr_data) begin
        `uvm_error(get_full_name(), "Instruction MISMATCH");
        error = 1;
      end

      // Se for STORE (opcode 0100011), compara os campos de endereço e dados
      if (opcode == 7'b0100011) begin
        `uvm_info(get_full_name(), $sformatf("Expected addr = 0x%08x | Actual addr = 0x%08x", exp_trans.data_addr, act_trans.data_addr), UVM_LOW);

        if (exp_trans.data_addr !== act_trans.data_addr) begin
          `uvm_error(get_full_name(), "Data address MISMATCH");
          error = 1;
        end
        if (exp_trans.data_wr !== act_trans.data_wr) begin
          `uvm_error(get_full_name(), "Data write MISMATCH");
          error = 1;
        end
        if (exp_trans.data_wr_en_ma !== act_trans.data_wr_en_ma) begin
          `uvm_error(get_full_name(), "Data write enable MISMATCH");
          error = 1;
        end
      end
      // Se for LOAD (opcode 0000011), apenas validar os campos rs1, rd e imm dentro da própria instr_data
      else if (opcode == 7'b0000011) begin
        validate_load_fields(exp_trans);
      end
    end
  endtask

  function void validate_load_fields(RISCV_transaction trans);
    bit [6:0] opcode;
    bit [2:0] funct3;
    bit [4:0] rs1;
    bit [4:0] rd;
    bit [11:0] imm;

    opcode = trans.instr_data[6:0];
    funct3 = trans.instr_data[14:12];
    rd     = trans.instr_data[11:7];
    rs1    = trans.instr_data[19:15];
    imm    = trans.instr_data[31:20];

    if (opcode != 7'b0000011 || funct3 != 3'b010) begin
      `uvm_warning(get_full_name(), $sformatf("Instruction 0x%08h is not LW (opcode/funct3 mismatch)", trans.instr_data));
      return;
    end

    `uvm_info(get_full_name(), $sformatf(
      "Validating LW fields: rd = x%0d | rs1 = x%0d | imm = %0d",
      rd, rs1, $signed(imm)
    ), UVM_LOW);
  endfunction

  /*
   * Report phase
   */
  function void report_phase(uvm_phase phase);
    if (error == 0) begin
      $write("%c[7;32m",27);
      $display("-------------------------------------------------");
      $display("------ INFO : TEST CASE PASSED ------------------");
      $display("-------------------------------------------------");
      $write("%c[0m",27);
    end else begin
      $write("%c[7;31m",27);
      $display("---------------------------------------------------");
      $display("------ ERROR : TEST CASE FAILED ------------------");
      $display("---------------------------------------------------");
      $write("%c[0m",27);
    end
  endfunction

endclass

`endif