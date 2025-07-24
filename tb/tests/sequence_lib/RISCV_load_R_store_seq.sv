//------------------------------------------------------------------------------
// Load + R + Store sequence for RISCV
//------------------------------------------------------------------------------
// This sequence generates randomized Load (LW, LB, LH, LBU, LHU), R-type (ADD, SUB, AND, OR), and Store (SW, SB, SH) instructions
//
// Author: Henrique Teixeira
// Date  : July 2025
//------------------------------------------------------------------------------

`ifndef RISCV_LOAD_R_STORE_SEQ
`define RISCV_LOAD_R_STORE_SEQ

class RISCV_load_R_store_seq extends uvm_sequence#(RISCV_transaction_block);

  `uvm_object_utils(RISCV_load_R_store_seq)

  localparam int NUM_LOADS  = 32;
  localparam int NUM_RTYPE  = 32;
  localparam int NUM_STORES = 32;
  localparam int BLOCK_SIZE = NUM_LOADS + NUM_RTYPE + NUM_STORES;

  // R-type
  rand bit [4:0] rs1[NUM_RTYPE], rs2[NUM_RTYPE], rd[NUM_RTYPE];

  // LOAD
  rand bit [4:0] rs1_loads[NUM_LOADS], rd_loads[NUM_LOADS];
  rand bit [11:0] imm_loads[NUM_LOADS];
  rand bit [31:0] data_to_load[NUM_LOADS];

  // STORE
  rand bit [4:0] rs1_stores[NUM_STORES], rs2_stores[NUM_STORES];
  rand bit [11:0] imm_stores[NUM_STORES];

  // OPCODES
  localparam bit [6:0] LOAD_OPCODE   = 7'b0000011;
  localparam bit [6:0] STORE_OPCODE  = 7'b0100011;
  localparam bit [6:0] RTYPE_OPCODE  = 7'b0110011;

  // FUNCT3
  localparam bit [2:0] LB_FUNCT3  = 3'b000;
  localparam bit [2:0] LH_FUNCT3  = 3'b001;
  localparam bit [2:0] LW_FUNCT3  = 3'b010;
  localparam bit [2:0] LBU_FUNCT3 = 3'b100;
  localparam bit [2:0] LHU_FUNCT3 = 3'b101;

  localparam bit [2:0] SB_FUNCT3 = 3'b000;
  localparam bit [2:0] SH_FUNCT3 = 3'b001;
  localparam bit [2:0] SW_FUNCT3 = 3'b010;

  // R-type maps
  string r_instr_names[4] = '{"ADD", "SUB", "AND", "OR"};
  bit [2:0] funct3_map[4] = '{3'b000, 3'b000, 3'b111, 3'b110};
  bit [6:0] funct7_map[4] = '{7'b0000000, 7'b0100000, 7'b0000000, 7'b0000000};

  function new(string name = "RISCV_load_R_store_seq");
    super.new(name);
  endfunction

  virtual task body();
    req = RISCV_transaction_block::type_id::create("req");
    start_item(req);

    if (!randomize(rs1, rs2, rd,
                   rs1_loads, rd_loads, imm_loads, data_to_load,
                   rs1_stores, rs2_stores, imm_stores)) begin
      `uvm_fatal(get_type_name(), "Randomization failed!");
    end

    req.instr_data = new[BLOCK_SIZE];
    req.data_rd    = new[BLOCK_SIZE];
    req.instr_name = new[BLOCK_SIZE];

    // LOADs variados
    for (int i = 0; i < NUM_LOADS; i++) begin
      int load_sel = $urandom_range(0, 4); // LB a LHU
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

    // R-type
    for (int i = 0; i < NUM_RTYPE; i++) begin
      int idx = NUM_LOADS + i;
      int rtype_sel = $urandom_range(0, 3); // ADD, SUB, AND, OR

      req.instr_data[idx] = {
        funct7_map[rtype_sel], rs2[i], rs1[i], funct3_map[rtype_sel], rd[i], RTYPE_OPCODE
      };
      req.data_rd[idx] = 0;
      req.instr_name[idx] = $sformatf("%s x%0d, x%0d, x%0d", r_instr_names[rtype_sel], rd[i], rs1[i], rs2[i]);
    end

    // STOREs variados
    for (int i = 0; i < NUM_STORES; i++) begin
      int idx = NUM_LOADS + NUM_RTYPE + i;
      int store_sel = $urandom_range(0, 2); // SB, SH, SW
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
      $display("%0d =>  instr_data = %08h |  instr_name = %s", i, req.instr_data[i], req.instr_name[i]);

    finish_item(req);
  endtask

endclass

`endif

