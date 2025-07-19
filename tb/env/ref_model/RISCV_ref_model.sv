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

  virtual RISCV_interface vif;

  `uvm_component_utils(RISCV_ref_model)

  // Ports for input and output transactions
  uvm_analysis_export#(RISCV_transaction)       rm_export;
  uvm_analysis_port#(RISCV_transaction)         rm2sb_port;
  uvm_tlm_analysis_fifo#(RISCV_transaction)     rm_exp_fifo;

  // Shadow register file (x0–x31), x0 is always zero
  logic [31:0] regfile[32];
  
  // Program Counter
  bit [31:0] pc;
  
  // Pipeline registers
  typedef struct {
    bit        valid;
    bit [31:0] pc;
    bit [31:0] instr;
    bit [31:0] rs1_val;
    bit [31:0] rs2_val;
    bit [31:0] imm;
    bit [4:0]  rd;
    bit        reg_write;
    bit [31:0] alu_result;
    bit [31:0] mem_data;
    bit        mem_read;
    bit        mem_write;
    bit        branch_taken;
    bit [31:0] branch_target;
  } pipeline_reg_t;
  
  pipeline_reg_t if_id, id_ex, ex_mem, mem_wb;
  
  // Control signals
  bit stall;
  bit flush;
  bit [31:0] next_pc;

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

    if (!uvm_config_db#(virtual RISCV_interface)::get(this, "", "intf", vif))
      `uvm_fatal("NOVIF", {"Virtual interface must be set for: ", get_full_name(), ".vif"});

    // Initialize register file and PC
    foreach (regfile[i]) regfile[i] = 32'h0;
    pc = 32'h0;
    if_id = '{default:0};
    id_ex = '{default:0};
    ex_mem = '{default:0};
    mem_wb = '{default:0};
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    rm_export.connect(rm_exp_fifo.analysis_export);
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif.clk);
      // Wait for new transaction
      rm_exp_fifo.get(rm_trans);
      exp_trans = RISCV_transaction::type_id::create("exp_trans");

      fetch();
      decode();
      execute();
      memory_access();
      write_back();
      
    rm2sb_port.write(exp_trans);

      pc = next_pc;
      
    end
  endtask

  task fetch();
    if (!stall) begin
      if_id.valid = 1;
      if_id.pc = pc;
      if_id.instr = rm_trans.instr_data;
      
      // Default next PC is PC+4 unless overridden
      next_pc = pc + 4;
    end else begin
      if_id.valid = 0; // Insert bubble
    end
    
    if (flush) begin
      if_id.valid = 0; // Flush pipeline
      flush = 0;
    end

    exp_trans.inst_addr = next_pc;
    exp_trans.instr_data = rm_trans.instr_data;

  endtask

  task decode();
    bit [6:0] opcode;
    bit [2:0] funct3;
    bit [6:0] funct7;
    bit [4:0] rs1, rs2, rd;
    bit [31:0] imm;
    
    if (!if_id.valid) begin
      id_ex.valid = 0;
      return;
    end
    
    opcode = if_id.instr[6:0];
    funct3 = if_id.instr[14:12];
    funct7 = if_id.instr[31:25];
    rs1 = if_id.instr[19:15];
    rs2 = if_id.instr[24:20];
    rd = if_id.instr[11:7];
    
    // Immediate generation
    case (opcode)
      // I-type
      7'b0010011, 7'b0000011, 7'b1100111: 
        imm = {{20{if_id.instr[31]}}, if_id.instr[31:20]};
      // S-type
      7'b0100011: 
        imm = {{20{if_id.instr[31]}}, if_id.instr[31:25], if_id.instr[11:7]};
      // B-type
      7'b1100011: 
        imm = {{20{if_id.instr[31]}}, if_id.instr[7], if_id.instr[30:25], if_id.instr[11:8], 1'b0};
      // U-type
      7'b0110111, 7'b0010111: 
        imm = {if_id.instr[31:12], 12'b0};
      // J-type
      7'b1101111: 
        imm = {{12{if_id.instr[31]}}, if_id.instr[19:12], if_id.instr[20], if_id.instr[30:21], 1'b0};
      default: imm = 0;
    endcase
    
    // Register read with forwarding
    id_ex.rs1_val = get_forwarded_value(rs1);
    id_ex.rs2_val = get_forwarded_value(rs2);
    
    // Pass through signals
    id_ex.valid = 1;
    id_ex.pc = if_id.pc;
    id_ex.instr = if_id.instr;
    id_ex.imm = imm;
    id_ex.rd = rd;
    
    // Default control signals
    id_ex.reg_write = 0;
    id_ex.mem_read = 0;
    id_ex.mem_write = 0;
    id_ex.branch_taken = 0;
    id_ex.branch_target = 0;
    
    // Set control signals based on opcode
    case (opcode)
      // LUI, AUIPC
      7'b0110111, 7'b0010111: id_ex.reg_write = 1;
      // JAL
      7'b1101111: begin
        id_ex.reg_write = 1;
        id_ex.branch_taken = 1;
        id_ex.branch_target = if_id.pc + imm;
      end
      // JALR
      7'b1100111: begin
        id_ex.reg_write = 1;
        id_ex.branch_taken = 1;
        id_ex.branch_target = (get_forwarded_value(rs1) + imm) & ~1;
      end
      // Branch
      7'b1100011: begin
        id_ex.branch_taken = check_branch_condition(funct3, get_forwarded_value(rs1), get_forwarded_value(rs2));
        id_ex.branch_target = if_id.pc + imm;
      end
      // Load
      7'b0000011: begin
        id_ex.reg_write = 1;
        id_ex.mem_read = 1;
      end
      // Store
      7'b0100011: id_ex.mem_write = 1;
      // ALU ops
      7'b0010011, 7'b0110011: id_ex.reg_write = 1;
    endcase
    
    // Check for hazards
    check_hazards();
  endtask

  task execute();
    bit [6:0] opcode;
    bit [2:0] funct3;
    bit [6:0] funct7;
    bit [31:0] alu_src1, alu_src2;
    aluOpType alu_op;
    
    if (!id_ex.valid) begin
      ex_mem.valid = 0;
      return;
    end
    
    opcode = id_ex.instr[6:0];
    funct3 = id_ex.instr[14:12];
    funct7 = id_ex.instr[31:25];
    
    // ALU source selection
    case (opcode)
      // LUI
      7'b0110111: alu_src1 = 0;
      // AUIPC
      7'b0010111: alu_src1 = id_ex.pc;
      // JAL, JALR, Branches
      7'b1101111, 7'b1100111, 7'b1100011: alu_src1 = id_ex.pc;
      // ALU ops
      default: alu_src1 = id_ex.rs1_val;
    endcase
    
    case (opcode)
      // Immediate ops
      7'b0010011, 7'b0000011, 7'b1100111, 7'b0100011: alu_src2 = id_ex.imm;
      // LUI, AUIPC
      7'b0110111, 7'b0010111: alu_src2 = id_ex.imm;
      // JAL, Branches
      7'b1101111, 7'b1100011: alu_src2 = id_ex.imm;
      // Register ops
      default: alu_src2 = id_ex.rs2_val;
    endcase
    
    // ALU operation selection
    case (opcode)
      // LUI, AUIPC, JAL, JALR, Load/Store
      7'b0110111, 7'b0010111, 7'b1101111, 7'b1100111, 7'b0000011, 7'b0100011: 
        alu_op = ALU_ADD;
      // Branches
      7'b1100011: 
        alu_op = get_branch_alu_op(funct3);
      // ALU ops
      default: 
        alu_op = get_alu_op(opcode, funct3, funct7);
    endcase
    
    // Perform ALU operation
    ex_mem.alu_result = get_alu_result(alu_op, alu_src1, alu_src2);
    
    // Pass through signals
    ex_mem.valid = 1;
    ex_mem.pc = id_ex.pc;
    ex_mem.instr = id_ex.instr;
    ex_mem.rd = id_ex.rd;
    ex_mem.reg_write = id_ex.reg_write;
    ex_mem.mem_read = id_ex.mem_read;
    ex_mem.mem_write = id_ex.mem_write;
    ex_mem.rs2_val = id_ex.rs2_val;
    ex_mem.branch_taken = id_ex.branch_taken;
    ex_mem.branch_target = id_ex.branch_target;
    
    // Handle branches
    if (id_ex.branch_taken) begin
      next_pc = id_ex.branch_target;
      flush = 1;
    end
  endtask

  task memory_access();
    if (!ex_mem.valid) begin
      mem_wb.valid = 0;
      return;
    end
    
    mem_wb.mem_data = rm_trans.data_rd;
    
    // Pass through signals
    mem_wb.valid = 1;
    mem_wb.pc = ex_mem.pc;
    mem_wb.instr = ex_mem.instr;
    mem_wb.rd = ex_mem.rd;
    mem_wb.reg_write = ex_mem.reg_write;
    mem_wb.alu_result = ex_mem.alu_result;

          
    exp_trans.data_wr = ex_mem.rs2_val;         
    exp_trans.data_addr = ex_mem.alu_result;        
    exp_trans.data_wr_en_ma = ex_mem.mem_write;   
  endtask

  task write_back();
    if (!mem_wb.valid) return;
    
    // Write back to register file
    if (mem_wb.reg_write && mem_wb.rd != 0) begin
      regfile[mem_wb.rd] = mem_wb.mem_read ? mem_wb.mem_data : mem_wb.alu_result;
    end
    
  endtask

  task check_hazards();
    bit [6:0] opcode = if_id.instr[6:0];
    bit [4:0] rs1 = if_id.instr[19:15];
    bit [4:0] rs2 = if_id.instr[24:20];
    
    // Data hazards
    if (rs1 != 0 && ((id_ex.reg_write && id_ex.rd == rs1) || 
                     (ex_mem.reg_write && ex_mem.rd == rs1) ||
                     (mem_wb.reg_write && mem_wb.rd == rs1))) begin
      stall = 1;
    end else if ((rs2 != 0 && ((id_ex.reg_write && id_ex.rd == rs2) || 
                              (ex_mem.reg_write && ex_mem.rd == rs2) ||
                              (mem_wb.reg_write && mem_wb.rd == rs2)))) begin
      stall = 1;
                              end else begin
      stall = 0;
                              end
    
    // Control hazards (handled in execute stage)
  endtask

  function bit [31:0] get_forwarded_value(input bit [4:0] reg_addr);
    if (reg_addr == 0) return 0;

    // Forwarding from EX/MEM stage
    if (ex_mem.reg_write && ex_mem.rd == reg_addr)
      return ex_mem.alu_result;
    
    // Forwarding from MEM/WB stage
    if (mem_wb.reg_write && mem_wb.rd == reg_addr)
      return mem_wb.mem_read ? mem_wb.mem_data : mem_wb.alu_result;
    
    // Otherwise, return from register file
    return regfile[reg_addr];
  endfunction

  function aluOpType get_alu_op(input bit [6:0] opcode, input bit [2:0] funct3, input bit [6:0] funct7);
    case (funct3)
      3'b000: return (opcode == 7'b0110011 && funct7[5]) ? ALU_SUB : ALU_ADD;
      3'b001: return ALU_SLL;
      3'b010: return ALU_LT;
      3'b011: return ALU_LTU;
      3'b100: return ALU_XOR;
      3'b101: return (funct7[5]) ? ALU_SRA : ALU_SRL;
      3'b110: return ALU_OR;
      3'b111: return ALU_AND;
    endcase
  endfunction

  function aluOpType get_branch_alu_op(input bit [2:0] funct3);
    case (funct3)
      3'b000: return ALU_EQUAL;
      3'b001: return ALU_NEQUAL;
      3'b100: return ALU_LT;
      3'b101: return ALU_GT;
      3'b110: return ALU_LTU;
      3'b111: return ALU_GTU;
      default: return ALU_ADD;
    endcase
  endfunction

  function bit check_branch_condition(input bit [2:0] funct3, input bit [31:0] rs1, input bit [31:0] rs2);
    case (funct3)
      3'b000: return (rs1 == rs2);  // BEQ
      3'b001: return (rs1 != rs2);  // BNE
      3'b100: return ($signed(rs1) < $signed(rs2));  // BLT
      3'b101: return ($signed(rs1) >= $signed(rs2)); // BGE
      3'b110: return (rs1 < rs2);   // BLTU
      3'b111: return (rs1 >= rs2);  // BGEU
      default: return 0;
    endcase
  endfunction

  function bit [31:0] get_alu_result(
    input aluOpType alu_op,
    input bit [31:0] SrcA,
    input bit [31:0] SrcB
  );
    case (alu_op)
      ALU_ADD   : return $signed(SrcA) + $signed(SrcB);
      ALU_SUB   : return $signed(SrcA) - $signed(SrcB);
      ALU_XOR   : return SrcA ^ SrcB;
      ALU_OR    : return SrcA | SrcB;
      ALU_AND   : return SrcA & SrcB;
      ALU_SLL   : return SrcA << SrcB[4:0];
      ALU_SRL   : return SrcA >> SrcB[4:0];
      ALU_SRA   : return $signed(SrcA) >>> SrcB[4:0];
      ALU_EQUAL : return (SrcA == SrcB) ? 1 : 0;
      ALU_NEQUAL: return (SrcA != SrcB) ? 1 : 0;
      ALU_LT    : return ($signed(SrcA) < $signed(SrcB)) ? 1 : 0;
      ALU_GT    : return ($signed(SrcA) >= $signed(SrcB)) ? 1 : 0;
      ALU_LTU   : return (SrcA < SrcB) ? 1 : 0;
      ALU_GTU   : return (SrcA >= SrcB) ? 1 : 0;
      default   : return 0;
    endcase
  endfunction

endclass

`endif