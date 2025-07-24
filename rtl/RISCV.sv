import riscv_definitions::*; // Import package with types and constants

/**
 * Module: riscv_core
 * Description:
 *     Implements a fully connected 5-stage RISC-V processor core compliant with the RV32I base instruction set (Execpt ecall, fence ebreak).
 *
 *     This processor follows a classic RISC pipeline composed of five sequential stages:
 *
 *       1. Instruction Fetch (IF)   - Fetches the next instruction from memory using the program counter (PC).
 *       2. Instruction Decode (ID) - Decodes the fetched instruction, reads register operands, and generates control signals.
 *       3. Execute (EX)             - Performs arithmetic/logic operations, computes branches and jump addresses.
 *       4. Memory Access (MEM)      - Reads from or writes to data memory if required by the instruction.
 *       5. Write Back (WB)          - Writes the result back to the register file.
 *
 **/

module RISCV (
    input  logic         clk,                 // Clock signal
    input  logic         rst_n,               // Asynchronous reset (active low)

    // Instruction memory interface
    input  logic         i_instr_ready,       // Instruction memory ready
    input  dataBus_t     i_instr_data,        // Instruction memory data
    output logic [3:0]   o_inst_rd_en,        // Enable instruction memory read
    output logic [31:0]  o_inst_addr,         // PC address to fetch instruction

    // Data memory interface
    input  logic         i_data_ready,        // Data memory ready
    input  dataBus_t     i_data_rd,           // Data memory read data
    output dataBus_t     o_data_wr,           // Data memory write data
    output dataBus_t     o_data_addr,         // Data memory address
    output logic [3:0]   o_data_rd_en_ctrl,   // Control for data memory read
    output logic         o_data_rd_en_ma,     // Enable data memory read (memory access)
    output logic         o_data_wr_en_ma      // Enable data memory write (memory access)
);

// ==== Control Signals ====
logic if_clk_en, id_clk_en, ex_clk_en, ma_clk_en;
logic flush;
logic [31:0] jump_addr;

// ==== Instruction Fetch Stage ====
logic [31:0] if_inst;
logic [31:0] if_pc;

instruction_fetch if_stage (
    .clk(clk),
    .rst_n(rst_n),
    .clk_en_if_pc(if_clk_en),
    .clk_en_if_reg(id_clk_en),
    .i_flush(flush),
    .i_jump_addr(jump_addr),
    .i_inst_data(i_instr_data),
    .o_inst_rd_enable(o_inst_rd_en),
    .o_inst_addr(o_inst_addr),
    .o_if_inst(if_inst),
    .o_if_pc(if_pc)
);

// ==== Instruction Decode Stage ====
logic id_mem_to_reg, id_alu_src1, id_alu_src2, id_reg_wr;
logic id_mem_rd, id_mem_wr, id_branch, id_jump;
logic [DATA_WIDTH-1:0] id_pc, id_reg_read_data1, id_reg_read_data2;
logic signed [DATA_WIDTH-1:0] id_imm;
logic [REG_ADDR-1:0] id_reg_destination;
logic [2:0] id_funct3;
logic [6:0] id_funct7;
logic id_result_src;
aluOpType id_alu_op;

// ==== Memory Access Stage ====
logic [REG_ADDR-1:0] ma_reg_destination;
logic ma_reg_wr;
logic [DATA_WIDTH-1:0] wb_data;


instruction_decode id_stage (
    .clk(clk),
    .clk_en(ex_clk_en),
    .rst_n(rst_n),
    .i_if_inst(if_inst),
    .i_if_pc(if_pc),
    .i_flush(flush),
    .i_insert_nop(!id_clk_en),
    .i_ma_reg_destination(ma_reg_destination),
    .i_ma_reg_wr(ma_reg_wr),
    .i_wb_data(wb_data),
    .o_id_mem_to_reg(id_mem_to_reg),
    .o_id_alu_src1(id_alu_src1),
    .o_id_alu_src2(id_alu_src2),
    .o_id_reg_wr(id_reg_wr),
    .o_id_mem_rd(id_mem_rd),
    .o_id_mem_wr(id_mem_wr),
    .o_id_branch(id_branch),
    .o_id_alu_op(id_alu_op),
    .o_id_jump(id_jump),
    .o_id_pc(id_pc),
    .o_id_reg_read_data1(id_reg_read_data1),
    .o_id_reg_read_data2(id_reg_read_data2),
    .o_id_imm(id_imm),
    .o_id_reg_destination(id_reg_destination),
    .o_id_funct3(id_funct3),
    .o_id_funct7(id_funct7),
    .o_id_result_src(id_result_src)
);

// ==== Execute Stage ====
logic ex_mem_to_reg, ex_reg_wr, ex_mem_rd, ex_mem_wr;
logic ex_result_src;
logic [DATA_WIDTH-1:0] ex_pc_plus_4, ex_alu_result, ex_data2;
logic [REG_ADDR-1:0] ex_reg_destination;
logic [2:0] ex_funct3;
logic [6:0] ex_funct7;

execution ex_stage (
    .clk(clk),
    .clk_en(ma_clk_en),
    .rst_n(rst_n),
    .i_id_mem_to_reg(id_mem_to_reg),
    .i_id_alu_src1(id_alu_src1),
    .i_id_alu_src2(id_alu_src2),
    .i_id_reg_wr(id_reg_wr),
    .i_id_mem_rd(id_mem_rd),
    .i_id_mem_wr(id_mem_wr),
    .i_id_result_src(id_result_src),
    .i_id_branch(id_branch),
    .i_id_alu_op(id_alu_op),
    .i_id_jump(id_jump),
    .i_id_pc(id_pc),
    .i_id_reg_read_data1(id_reg_read_data1),
    .i_id_reg_read_data2(id_reg_read_data2),
    .i_id_imm(id_imm),
    .i_id_reg_destination(id_reg_destination),
    .i_id_funct3(id_funct3),
    .i_id_funct7(id_funct7),
    .o_ex_flush(flush),
    .o_ex_jump_addr(jump_addr),
    .o_ex_mem_to_reg(ex_mem_to_reg),
    .o_ex_reg_wr(ex_reg_wr),
    .o_ex_mem_rd(ex_mem_rd),
    .o_ex_mem_wr(ex_mem_wr),
    .o_ex_result_src(ex_result_src),
    .o_ex_pc_plus_4(ex_pc_plus_4),
    .o_ex_alu_result(ex_alu_result),
    .o_ex_data2(ex_data2),
    .o_ex_reg_destination(ex_reg_destination),
    .o_ex_funct3(ex_funct3),
    .o_ex_funct7(ex_funct7)
);

// ==== Memory Access Stage ====
    logic        ma_mem_to_reg;
    logic        ma_rw_sel;
    logic [31:0] ma_pc_plus_4;
    logic [31:0] ma_read_data;
    logic [31:0] ma_result;

    memory_access ma_stage (
        .clk(clk),
        .rst_n(rst_n),
        .clk_en(ma_clk_en),

        .i_data_rd(i_data_rd),

        .i_ex_mem_to_reg(ex_mem_to_reg),
        .i_ex_rw_sel(ex_result_src),
        .i_ex_reg_wr(ex_reg_wr),
        .i_ex_mem_rd(ex_mem_rd),
        .i_ex_mem_wr(ex_mem_wr),
        .i_ex_pc_plus_4(ex_pc_plus_4),
        .i_ex_alu_result(ex_alu_result),
        .i_ex_reg_read_data2(ex_data2),
        .i_ex_reg_dest(ex_reg_destination),
        .i_ex_funct3(ex_funct3),
        .i_ex_funct7(ex_funct7),

        .o_data_wr(o_data_wr),
        .o_data_addr(o_data_addr),
        .o_data_rd_en_ctrl(o_data_rd_en_ctrl),
        .o_data_rd_en_ma(o_data_rd_en_ma),
        .o_data_wr_en_ma(o_data_wr_en_ma),

        .o_ma_mem_to_reg(ma_mem_to_reg),
        .o_ma_rw_sel(ma_rw_sel),
        .o_ma_pc_plus_4(ma_pc_plus_4),
        .o_ma_read_data(ma_read_data),
        .o_ma_result(ma_result),
        .o_ma_reg_dest(ma_reg_destination),
        .o_ma_reg_wr(ma_reg_wr)
    );

// ==== Write Back Stage ====
WriteBack wb_stage (
    .i_ma_mem_to_reg(ma_mem_to_reg),
    .i_ma_rw_sel(ma_rw_sel),
    .i_ma_result(ma_result),
    .i_ma_read_data(ma_read_data),
    .i_ma_pc_plus_4(ma_pc_plus_4),
    .o_wb_data(wb_data)
);

opcodeType  opcode;

assign  opcode         = opcodeType'(if_inst[6:0]);
wire [4:0] if_reg_src2 = (
    (opcode == ALU_S) || // Tipo R
    (opcode == STORE_S) || // Tipo S (e.g., SW)
    (opcode == BRCH_S)    // Tipo B (e.g., BEQ)
) ? if_inst[24:20] : 5'd0;

// ==== Hazard Control ====
hazard_control hc (
    .clk(clk),
    .i_instr_ready(i_instr_ready),
    .i_data_ready(i_data_ready),
    .i_if_reg_src1(if_inst[19:15]),     // rs1 from instruction
    .i_if_reg_src2(if_reg_src2),        // rs2 from instruction
    .i_id_reg_dest(id_reg_destination),
    .i_id_reg_wr(id_reg_wr),
    .i_ex_reg_dest(ex_reg_destination),
    .i_ex_reg_wr(ex_reg_wr),
    .i_ma_reg_dest(ma_reg_destination),
    .i_ma_reg_wr(ma_reg_wr),
    .i_id_branch(id_branch || id_jump),
    .o_if_clk_en(if_clk_en),
    .o_id_clk_en(id_clk_en),
    .o_ex_clk_en(ex_clk_en),
    .o_ma_clk_en(ma_clk_en)
);

endmodule