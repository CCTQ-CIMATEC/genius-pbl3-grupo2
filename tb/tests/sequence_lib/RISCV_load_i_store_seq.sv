//------------------------------------------------------------------------------
// Load + I-type + Store sequence for RISCV
//------------------------------------------------------------------------------
// This sequence generates randomized Load (LB, LH, LW, LBU, LHU),
// I-type ALU (ADDI, SLTI, ORI, ANDI, etc.), and Store (SB, SH, SW)
// instructions in a fixed order: Load → I-type → Store.
//
// Author: Henrique Teixeira
// Date  : July 2025
//------------------------------------------------------------------------------

`ifndef RISCV_LOAD_I_STORE_SEQ
`define RISCV_LOAD_I_STORE_SEQ

class RISCV_load_i_store_seq extends uvm_sequence#(RISCV_transaction_block);

  `uvm_object_utils(RISCV_load_i_store_seq)

  localparam int NUM_LOADS  = 8;
  localparam int NUM_ITYPE  = 8;
  localparam int NUM_STORES = 8;
  localparam int BLOCK_SIZE = NUM_LOADS + NUM_ITYPE + NUM_STORES;

  // I-type ALU (ADDI, ANDI, ORI, etc.)
  rand bit [4:0] rs1_i[NUM_ITYPE], rd_i[NUM_ITYPE];
  rand bit [11:0] imm_i[NUM_ITYPE];
  string i_instr_names[6] = '{"ADDI", "ANDI", "ORI", "XORI", "SLTI", "SLTIU"};
  bit [2:0] i_funct3[6]   = '{3'b000, 3'b111, 3'b110, 3'b100, 3'b010, 3'b011};

  // LOAD
  rand bit [4:0] rs1_loads[NUM_LOADS], rd_loads[NUM_LOADS];
  rand bit [11:0] imm_loads[NUM_LOADS];
  rand bit [31:0] data_to_load[NUM_LOADS];

  // STORE
  rand bit [4:0] rs1_stores[NUM_STORES], rs2_stores[NUM_STORES];
  rand bit [11:0] imm_stores[NUM_STORES];

  // OPCODES
  localparam bit [6:0] I_OPCODE     = 7'b0010011;
  localparam bit [6:0] LOAD_OPCODE  = 7'b0000011;
  localparam bit [6:0] STORE_OPCODE = 7'b0100011;

  // FUNCT3 definitions
  localparam bit [2:0] LB_FUNCT3  = 3'b000;
  localparam bit [2:0] LH_FUNCT3  = 3'b001;
  localparam bit [2:0] LW_FUNCT3  = 3'b010;
  localparam bit [2:0] LBU_FUNCT3 = 3'b100;
  localparam bit [2:0] LHU_FUNCT3 = 3'b101;

  localparam bit [2:0] SB_FUNCT3 = 3'b000;
  localparam bit [2:0] SH_FUNCT3 = 3'b001;
  localparam bit [2:0] SW_FUNCT3 = 3'b010;

  function new(string name = "RISCV_I_load_store_seq");
    super.new(name);
  endfunction

  virtual task body();
    req = RISCV_transaction_block::type_id::create("req");
    start_item(req);

    if (!randomize(rs1_i, rd_i, imm_i,
                   rs1_loads, rd_loads, imm_loads, data_to_load,
                   rs1_stores, rs2_stores, imm_stores)) begin
      `uvm_fatal(get_type_name(), "Randomization failed!");
    end

    req.instr_data = new[BLOCK_SIZE];
    req.data_rd    = new[BLOCK_SIZE];
    req.instr_name = new[BLOCK_SIZE];

    // ------------------------------
    // Load instructions
    // ------------------------------
    for (int i = 0; i < NUM_LOADS; i++) begin
      int load_sel = $urandom_range(0, 4);
      bit [2:0] funct3;
      string instr;

      case (load_sel)
        0: begin funct3 = LB_FUNCT3;  instr = "LB"; end
        1: begin funct3 = LH_FUNCT3;  imm_loads[i][0] = 0; instr = "LH"; end
        2: begin funct3 = LW_FUNCT3;  imm_loads[i][1:0] = 2'b00; instr = "LW"; end
        3: begin funct3 = LBU_FUNCT3; instr = "LBU"; end
        default: begin funct3 = LHU_FUNCT3; imm_loads[i][0] = 0; instr = "LHU"; end
      endcase

      req.instr_data[i] = {
        imm_loads[i], rs1_loads[i], funct3, rd_loads[i], LOAD_OPCODE
      };
      req.data_rd[i] = data_to_load[i];
      req.instr_name[i] = $sformatf("%s x%0d, %0d(x%0d)", instr, rd_loads[i], $signed(imm_loads[i]), rs1_loads[i]);
    end

    // ------------------------------
    // I-type ALU instructions
    // ------------------------------
    for (int i = 0; i < NUM_ITYPE; i++) begin
      int idx = NUM_LOADS + i;
      int sel = $urandom_range(0, 5);
      req.instr_data[idx] = {
        imm_i[i], rs1_i[i], i_funct3[sel], rd_i[i], I_OPCODE
      };
      req.data_rd[idx] = 0;
      req.instr_name[idx] = $sformatf("%s x%0d, x%0d, %0d", i_instr_names[sel], rd_i[i], rs1_i[i], $signed(imm_i[i]));
    end

    // ------------------------------
    // Store instructions
    // ------------------------------
    for (int i = 0; i < NUM_STORES; i++) begin
      int idx = NUM_LOADS + NUM_ITYPE + i;
      int store_sel = $urandom_range(0, 2);
      bit [2:0] funct3;
      string instr;

      case (store_sel)
        0: begin funct3 = SB_FUNCT3;  instr = "SB"; end
        1: begin funct3 = SH_FUNCT3;  imm_stores[i][0] = 0; instr = "SH"; end
        default: begin funct3 = SW_FUNCT3; imm_stores[i][1:0] = 2'b00; instr = "SW"; end
      endcase

      req.instr_data[idx] = {
        imm_stores[i][11:5], rs2_stores[i], rs1_stores[i], funct3, imm_stores[i][4:0], STORE_OPCODE
      };
      req.data_rd[idx] = 0;
      req.instr_name[idx] = $sformatf("%s x%0d, %0d(x%0d)", instr, rs2_stores[i], $signed(imm_stores[i]), rs1_stores[i]);
    end

    foreach (req.instr_name[i])
      $display("%0d => instr_data = %08h | instr_name = %s", i, req.instr_data[i], req.instr_name[i]);

    finish_item(req);
  endtask

endclass

`endif
