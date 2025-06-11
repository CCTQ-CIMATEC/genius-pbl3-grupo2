//------------------------------------------------------------------------------
// Reference model module for RISCV
//------------------------------------------------------------------------------
// This module defines the reference model for the RISCV verification.
//
// Author: Gustavo Santiago
// Date  : June 2025
//------------------------------------------------------------------------------

`ifndef RISCV_REF_MODEL 
`define RISCV_REF_MODEL

class RISCV_ref_model extends uvm_component;
  `uvm_component_utils(RISCV_ref_model)

  // Ports for input and output transactions
  uvm_analysis_export#(RISCV_transaction) rm_export;
  uvm_analysis_port#(RISCV_transaction) rm2sb_port;
  uvm_tlm_analysis_fifo#(RISCV_transaction) rm_exp_fifo;

  // Shadow register file (x0–x31, x0 always zero)
  logic [31:0] regfile[32];

  // Writeback pipeline entry
  typedef struct {
    logic [4:0]  rd;
    logic [31:0] value;
    bit          we;
  } wb_info_t;

  // 5-stage pipeline to model writeback delay
  wb_info_t writeback_queue[5];

  // Internal transaction handles
  RISCV_transaction rm_trans;
  RISCV_transaction exp_trans;

  function new(string name = "RISCV_ref_model", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    rm_export    = new("rm_export", this);
    rm2sb_port   = new("rm2sb_port", this);
    rm_exp_fifo  = new("rm_exp_fifo", this);
    // Initialize regfile and pipeline
    foreach (regfile[i]) regfile[i] = 32'h0;
    foreach (writeback_queue[i]) writeback_queue[i] = '{rd: 0, value: 0, we: 0};
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    rm_export.connect(rm_exp_fifo.analysis_export);
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      // Apply writeback from the oldest entry in the queue
      if (writeback_queue[0].we && writeback_queue[0].rd != 0) begin
        regfile[writeback_queue[0].rd] = writeback_queue[0].value;
      end

      // Shift pipeline forward
      for (int i = 0; i < 4; i++) begin
        writeback_queue[i] = writeback_queue[i+1];
      end
      writeback_queue[4] = '{rd: 0, value: 0, we: 0};

      // Wait for a new transaction
      rm_exp_fifo.get(rm_trans);
      process_instruction(rm_trans);
    end
  endtask

  task automatic process_instruction(RISCV_transaction input_trans);
  RISCV_transaction exp_trans_local;
  bit [6:0] opcode;
  bit [2:0] funct3;
  bit [6:0] funct7;
  bit [4:0] reg1_addr;
  bit [4:0] reg2_addr;
  bit [4:0] reg_dest;
  bit [31:0] rs1, rs2;
  bit [31:0] imm;
  wb_info_t wb;

  exp_trans_local = RISCV_transaction::type_id::create("exp_trans_local");
  exp_trans_local.copy(input_trans);
  opcode = input_trans.instr_data[6:0];
  funct3 = input_trans.instr_data[14:12];
  funct7 = input_trans.instr_data[31:25];
  reg1_addr = input_trans.instr_data[19:15];
  reg2_addr = input_trans.instr_data[24:20];
  reg_dest = input_trans.instr_data[11:7];
  imm = {{20{input_trans.instr_data[31]}}, input_trans.instr_data[31:20]};

  rs1 = regfile[reg1_addr];
  rs2 = regfile[reg2_addr];
  
  wb = '{rd: 0, value: 0, we: 0};

  // ADD instruction (R-type)
  if (opcode == 7'b0110011 && funct3 == 3'b000 && funct7 == 7'b0000000) begin
    exp_trans_local.data_addr = rs1 + rs2;
    wb = '{rd: reg_dest, value: exp_trans_local.data_addr, we: 1};
  end
  // LW instruction (I-type)
  else if (opcode == 7'b0000011 && funct3 == 3'b010) begin
    exp_trans_local.data_addr = rs1 + imm;
    exp_trans_local.data_rd  = input_trans.data_rd;
    exp_trans_local.data_rd_en_ctrl = 4'b1111;
    wb = '{rd: reg_dest, value: input_trans.data_rd, we: 1};
  end
  // SW instruction (S-type)
  else if (opcode == 7'b0100011 && funct3 == 3'b010) begin
    exp_trans_local.data_addr = rs1 + imm;
    exp_trans_local.data_wr  = rs2;
    exp_trans_local.data_wr_en_ma  = 1;
    exp_trans_local.data_rd_en_ctrl = 4'b1111;
  end
  else begin
    `uvm_warning(get_full_name(), $sformatf("Unsupported instruction: 0x%h", input_trans.instr_data));
  end

  writeback_queue[4] = wb;
  rm2sb_port.write(exp_trans_local);
endtask

endclass

`endif
