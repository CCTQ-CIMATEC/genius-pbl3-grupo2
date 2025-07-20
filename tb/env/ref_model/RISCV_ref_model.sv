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

    // Shadow register file (x0-x31), x0 is always zero
    logic [31:0] regfile[32];
    
    // Program Counter
    bit [31:0] pc;
    
    // Pipeline registers
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

        if (!uvm_config_db#(virtual RISCV_interface)::get(this, "", "intf", vif)) begin
            `uvm_fatal("NOVIF", {"Virtual interface must be set for: ", get_full_name(), ".vif"});
        end

        // Initialize register file and PC
        foreach (regfile[i]) regfile[i] = 32'h0;
        pc = 32'h0;
        if_id = RESET_PIPELINE_REG;
        id_ex = RESET_PIPELINE_REG;
        ex_mem = RESET_PIPELINE_REG;
        mem_wb = RESET_PIPELINE_REG;
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
        opcodeType opcode;
        bit [2:0]  funct3;
        bit [6:0]  funct7;
        bit [4:0]  rs1;
        bit [4:0]  rs2;
        bit [4:0]  rd;

        if (!if_id.valid) begin
            id_ex.valid = 0;
            return;
        end

        opcode = opcodeType'(if_id.instr[6:0]);
        funct3 = if_id.instr[14:12];
        funct7 = if_id.instr[31:25];
        rs1 = if_id.instr[19:15];
        rs2 = if_id.instr[24:20];
        rd  = if_id.instr[11:7];

        id_ex.valid   = 1;
        id_ex.pc      = if_id.pc;
        id_ex.instr   = if_id.instr;
        id_ex.rd      = rd;
        id_ex.rs1_val = get_forwarded_value(rs1);
        id_ex.rs2_val = get_forwarded_value(rs2);
        id_ex.imm     = get_immediate(opcode, if_id.instr);

        // Default control signals
        id_ex.reg_write     = 0;
        id_ex.mem_read      = 0;
        id_ex.mem_write     = 0;
        id_ex.branch_taken  = 0;
        id_ex.jump          = 0;
        id_ex.branch_target = 0;
        id_ex.alu_src1      = 0; // 0: rs1, 1: pc
        id_ex.alu_src2      = 0; // 0: rs2, 1: imm
        id_ex.alu_opcode    = ALU_ADD;

        case (opcode)
            LUI: begin
                id_ex.reg_write  = 1;
                id_ex.alu_src1   = 1; // unused, but set to PC
                id_ex.alu_src2   = 1; // use immediate
                id_ex.alu_opcode = ALU_BPS2;
            end

            AUIPC: begin
                id_ex.reg_write  = 1;
                id_ex.alu_src1   = 1; // PC
                id_ex.alu_src2   = 1; // imm
                id_ex.alu_opcode = ALU_ADD;
            end

            JAL: begin
                id_ex.reg_write     = 1;
                id_ex.alu_src1      = 1; // PC
                id_ex.alu_src2      = 1; // imm
                id_ex.alu_opcode    = ALU_ADD;
                id_ex.jump          = 1;
                id_ex.branch_target = if_id.pc + id_ex.imm;
            end

            JALR: begin
                id_ex.reg_write     = 1;
                id_ex.alu_src1      = 0; // rs1
                id_ex.alu_src2      = 1; // imm
                id_ex.alu_opcode    = ALU_ADD;
                id_ex.jump          = 1;
                id_ex.branch_target = (id_ex.rs1_val + id_ex.imm) & ~1;
            end

            BRCH_S: begin
                id_ex.alu_src1      = 0;
                id_ex.alu_src2      = 0;
                id_ex.alu_opcode    = get_branch_alu_op(funct3);
                id_ex.branch_taken  = 1;
                id_ex.branch_target = if_id.pc + id_ex.imm;
            end

            LOAD_S: begin
                id_ex.reg_write  = 1;
                id_ex.mem_read   = 1;
                id_ex.alu_src1   = 0; // rs1
                id_ex.alu_src2   = 1; // imm
                id_ex.alu_opcode = ALU_ADD;
            end

            STORE_S: begin
                id_ex.mem_write  = 1;
                id_ex.alu_src1   = 0;
                id_ex.alu_src2   = 1;
                id_ex.alu_opcode = ALU_ADD;
            end

            ALUI_S, ALU_S: begin
                id_ex.reg_write  = 1;
                id_ex.alu_src1   = 0;
                id_ex.alu_opcode = get_alu_op(opcode, funct3, funct7);
                id_ex.alu_src2   = opcode == ALUI_S;
            end
        endcase

        check_hazards();
    endtask

    task execute();
        bit [31:0] alu_src1;
        bit [31:0] alu_src2;

        if (!id_ex.valid) begin
            ex_mem.valid = 0;
            return;
        end

        // Source 1 selection
        if (id_ex.alu_src1 == 1) begin
            alu_src1 = id_ex.pc;
        end else begin
            alu_src1 = id_ex.rs1_val;
        end

        // Source 2 selection
        if (id_ex.alu_src2 == 1) begin
            alu_src2 = id_ex.imm;
        end else begin
            alu_src2 = id_ex.rs2_val;
        end

        // ALU operation
        ex_mem.alu_result = get_alu_result(id_ex.alu_opcode, alu_src1, alu_src2);

        // Pass-through signals
        ex_mem.valid         = 1;
        ex_mem.pc            = id_ex.pc;
        ex_mem.instr         = id_ex.instr;
        ex_mem.rd            = id_ex.rd;
        ex_mem.reg_write     = id_ex.reg_write;
        ex_mem.mem_read      = id_ex.mem_read;
        ex_mem.mem_write     = id_ex.mem_write;
        ex_mem.rs2_val       = id_ex.rs2_val;
        ex_mem.jump          = id_ex.jump;
        ex_mem.branch_taken  = id_ex.branch_taken;
        ex_mem.branch_target = id_ex.branch_target;

        // Handle branches
        if (id_ex.jump || (id_ex.branch_taken && ex_mem.alu_result)) begin
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

        // Update expected transaction
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

    function bit [31:0] get_immediate(opcodeType opcode, bit [31:0] instr);
        case (opcode)
            ALUI_S, LOAD_S, JALR:    return {{20{instr[31]}}, instr[31:20]};
            STORE_S:                 return {{20{instr[31]}}, instr[31:25], instr[11:7]};
            BRCH_S:                  return {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
            LUI, AUIPC:              return {instr[31:12], 12'b0};
            JAL:                     return {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
            default:                 return 32'h0;
        endcase
    endfunction

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
        if (ex_mem.reg_write && ex_mem.rd == reg_addr) begin
            return ex_mem.alu_result;
        end
        
        // Forwarding from MEM/WB stage
        if (mem_wb.reg_write && mem_wb.rd == reg_addr) begin
            return mem_wb.mem_read ? mem_wb.mem_data : mem_wb.alu_result;
        end
        
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