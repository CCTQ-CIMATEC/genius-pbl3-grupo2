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
  uvm_analysis_export#(RISCV_transaction)       rm_export;
  uvm_analysis_port#(RISCV_transaction)         rm2sb_port;
  uvm_tlm_analysis_fifo#(RISCV_transaction)     rm_exp_fifo;

  // Shadow register file (x0–x31), x0 is always zero
  logic [31:0] regfile[32];

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

    // Initialize register file and writeback pipeline
    foreach (regfile[i]) regfile[i] = 32'h0;
    foreach (writeback_queue[i]) writeback_queue[i] = '{rd: 0, value: 0, we: 0};
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    rm_export.connect(rm_exp_fifo.analysis_export);
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      // Apply writeback from the oldest entry in the pipeline
      if (writeback_queue[0].we && writeback_queue[0].rd != 0) begin
        regfile[writeback_queue[0].rd] = writeback_queue[0].value;
      end

      // Shift pipeline forward
      for (int i = 0; i < 4; i++) begin
        writeback_queue[i] = writeback_queue[i+1];
      end
      writeback_queue[4] = '{rd: 0, value: 0, we: 0};

      // Wait for new transaction
      rm_exp_fifo.get(rm_trans);
      process_instruction(rm_trans);
    end
  endtask

  task automatic process_instruction(RISCV_transaction input_trans);
    RISCV_transaction exp_trans_local;
    opcodeType opcode;
    aluOpType alu_op;

    bit [2:0]  funct3;
    bit [6:0]  funct7;
    bit [4:0]  reg1_addr;
    bit [4:0]  reg2_addr;
    bit [4:0]  reg_dest;
    bit [31:0] rs1, rs2;
    bit [31:0] imm;
    bit [31:0] data_rd;
    wb_info_t  wb;

    exp_trans_local = RISCV_transaction::type_id::create("exp_trans_local");
    exp_trans_local.copy(input_trans);

    opcode     = opcodeType'(input_trans.instr_data[6:0]);
    funct3     = input_trans.instr_data[14:12];
    funct7     = input_trans.instr_data[31:25];
    reg1_addr  = input_trans.instr_data[19:15];
    reg2_addr  = input_trans.instr_data[24:20];
    reg_dest   = input_trans.instr_data[11:7];
    data_rd    = input_trans.data_rd;

    rs1 = get_forwarded_value(reg1_addr);
    rs2 = get_forwarded_value(reg2_addr);

    wb = '{rd: 0, value: 0, we: 0};
    `uvm_info(get_full_name(), $sformatf("TESTE rs1_addr = %d => rs1_value = %d | rs2_addr = %d => rs2_value = %d ", reg1_addr, rs1, reg2_addr, rs2), UVM_LOW);

    
    case (opcode)
      LUI: begin
        imm = get_sign_extend_result(IMM_U, input_trans.instr_data[31:7]);
        exp_trans_local.data_addr = imm;
        wb = '{rd: reg_dest, value: exp_trans_local.data_addr, we: 1};
      end

      AUIPC: begin
        imm = get_sign_extend_result(IMM_U, input_trans.instr_data[31:7]);
        exp_trans_local.data_addr = get_alu_result(ALU_ADD, exp_trans_local.inst_addr, imm);
        exp_trans_local.data_wr   = imm;
        wb = '{rd: reg_dest, value: exp_trans_local.data_addr, we: 1};
      end

      JAL: begin
        imm = get_sign_extend_result(IMM_J, input_trans.instr_data[31:7]);
        exp_trans_local.inst_addr = get_alu_result(ALU_ADD, input_trans.inst_addr, imm);
        exp_trans_local.data_addr = get_alu_result(ALU_ADD, rs1, rs2);
        wb = '{rd: reg_dest, value: (input_trans.inst_addr + 4), we: 1};
      end

      JALR: begin
        imm = get_sign_extend_result(IMM_I, input_trans.instr_data[31:7]);
        exp_trans_local.inst_addr = get_alu_result(ALU_ADD, rs1, imm);
        exp_trans_local.data_addr = get_alu_result(ALU_ADD, rs1, rs2);
        wb = '{rd: reg_dest, value: (input_trans.inst_addr + 4), we: 1};
      end

      BRCH_S: begin
        imm    = get_sign_extend_result(IMM_B, input_trans.instr_data[31:7]);
        alu_op = ALU_EQUAL;

        case (funct3)
          3'b001: alu_op = ALU_NEQUAL;
          3'b100: alu_op = ALU_LT;
          3'b101: alu_op = ALU_GT;
          3'b110: alu_op = ALU_LTU;
          3'b111: alu_op = ALU_GTU;
        endcase

        exp_trans_local.data_addr = get_alu_result(alu_op, rs1, rs2);
        if (exp_trans_local.data_addr) begin
          exp_trans_local.inst_addr = get_alu_result(ALU_ADD, input_trans.inst_addr, imm);
        end
      end

      LOAD_S: begin
        imm = get_sign_extend_result(IMM_I, input_trans.instr_data[31:7]);
        exp_trans_local.data_addr     = get_alu_result(ALU_ADD, rs1, imm);
        exp_trans_local.data_wr_en_ma = 0;
        exp_trans_local.data_wr       = rs2;
        exp_trans_local.data_rd       = data_rd;
        wb = '{rd: reg_dest, value: exp_trans_local.data_rd, we: 1};
      end

      STORE_S: begin
        imm = get_sign_extend_result(IMM_S, input_trans.instr_data[31:7]);
        exp_trans_local.data_addr     = get_alu_result(ALU_ADD, rs1, imm);
        exp_trans_local.data_wr       = rs2;
        exp_trans_local.data_wr_en_ma = 1;
      end

      ALUI_S: begin
        imm = get_sign_extend_result(IMM_I, input_trans.instr_data[31:7]);
        alu_op = ALU_ADD;

        if (funct3 == 3'b001 || funct3 == 3'b101)
          imm = get_sign_extend_result(IMM_IS, input_trans.instr_data[31:7]);

        if (funct3 == 3'b101 && funct7[5])
          alu_op = ALU_SRA;
        else
          alu_op = aluOpType'({1'b0, funct3});

        exp_trans_local.data_addr = get_alu_result(alu_op, rs1, imm);
        wb = '{rd: reg_dest, value: exp_trans_local.data_addr, we: 1};
      end

      ALU_S: begin
        if (funct3 == 3'b000 && funct7[5])
          alu_op = ALU_SUB;
        else if (funct3 == 3'b101 && funct7[5])
          alu_op = ALU_SRA;
        else
          alu_op = aluOpType'({1'b0, funct3});

        exp_trans_local.data_addr = get_alu_result(alu_op, rs1, rs2);
        wb = '{rd: reg_dest, value: exp_trans_local.data_addr, we: 1};
      end

      default: begin
        `uvm_warning(get_full_name(), $sformatf("Unsupported instruction: 0x%h", input_trans.instr_data))
      end
    endcase

    writeback_queue[4] = wb;
    
    for (int i = 0; i <= 4; i++) begin
      `uvm_info(get_full_name(), $sformatf("TESTE2 queue indice = %d => value = %0h", i, writeback_queue[i].value), UVM_LOW);
    end

    rm2sb_port.write(exp_trans_local);
  endtask

  function bit [31:0] get_forwarded_value(input bit [4:0] reg_addr);
    if (reg_addr == 0) return 0;

    // Check from the newest (index 4) to the oldest (index 1)
    for (int i = 4; i >= 1; i--) begin
      if (writeback_queue[i].we && (writeback_queue[i].rd == reg_addr)) begin
        return writeback_queue[i].value;
      end
    end

    // Otherwise, return from register file
    return regfile[reg_addr];
  endfunction

  function bit [31:0] get_alu_result(
    input aluOpType alu_op,
    input bit [31:0] SrcA,
    input bit [31:0] SrcB
  );
    bit [31:0] ALUResult = 0;
    case (alu_op)
      ALU_ADD   : ALUResult = $signed(SrcA) + $signed(SrcB);
      ALU_SUB   : ALUResult = $signed(SrcA) - $signed(SrcB);
      ALU_XOR   : ALUResult = SrcA ^ SrcB;
      ALU_OR    : ALUResult = SrcA | SrcB;
      ALU_AND   : ALUResult = SrcA & SrcB;
      ALU_SLL   : ALUResult = SrcA << SrcB[4:0];
      ALU_SRL   : ALUResult = SrcA >> SrcB[4:0];
      ALU_SRA   : ALUResult = $signed(SrcA) >>> SrcB[4:0];
      ALU_EQUAL : ALUResult = (SrcA == SrcB) ? 1 : 0;
      ALU_NEQUAL: ALUResult = (SrcA != SrcB) ? 1 : 0;
      ALU_LT    : ALUResult = ($signed(SrcA) < $signed(SrcB)) ? 1 : 0;
      ALU_GT    : ALUResult = ($signed(SrcA) >= $signed(SrcB)) ? 1 : 0;
      ALU_LTU   : ALUResult = (SrcA < SrcB) ? 1 : 0;
      ALU_GTU   : ALUResult = (SrcA >= SrcB) ? 1 : 0;
      ALU_BPS2  : ALUResult = SrcB;
    endcase
    return ALUResult;
  endfunction

  function bit [31:0] get_sign_extend_result(input imm_src_t i_imm_src, input [31:7] i_instr);
    bit [31:0] o_imm_out = 32'b0;

    case (i_imm_src)
      IMM_I  : o_imm_out = {{20{i_instr[31]}}, i_instr[31:20]};
      IMM_IS : o_imm_out = {{27{i_instr[31]}}, i_instr[24:20]};
      IMM_S  : o_imm_out = {{20{i_instr[31]}}, i_instr[31:25], i_instr[11:7]};
      IMM_B  : o_imm_out = {{20{i_instr[31]}}, i_instr[7], i_instr[30:25], i_instr[11:8], 1'b0};
      IMM_U  : o_imm_out = {{20{i_instr[31]}}, i_instr[31:12]};
      IMM_J  : o_imm_out = {{12{i_instr[31]}}, i_instr[19:12], i_instr[20], i_instr[30:21], 1'b0};
    endcase

    return o_imm_out;
  endfunction

endclass

`endif