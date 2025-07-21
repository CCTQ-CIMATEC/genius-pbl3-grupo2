//------------------------------------------------------------------------------
// Load sequence for RISCV
//------------------------------------------------------------------------------
// This sequence generates randomized transactions for the RISCV UVM verification.
//
// Author: Leonardo Rodrigues
// Date  : June 2025
//------------------------------------------------------------------------------


`ifndef RISCV_LOAD_STORE_SEQ
`define RISCV_LOAD_STORE_SEQ

class RISCV_load_store_seq extends uvm_sequence#(RISCV_transaction_block);

  `uvm_object_utils(RISCV_load_store_seq)

// Parâmetros para o número de instruções
localparam int NUM_LOADS = 32;
localparam int NUM_STORES = 32;
localparam int BLOCK_SIZE = NUM_LOADS + NUM_STORES;

// Arrays para randomização
rand bit [4:0] rs1_loads[NUM_LOADS];
rand bit [4:0] rd_loads[NUM_LOADS];
rand bit [11:0] imm_loads[NUM_LOADS];
rand bit [31:0] data_to_load[NUM_LOADS];

rand bit [4:0] rs1_stores[NUM_STORES];
rand bit [4:0] rs2_stores[NUM_STORES];
rand bit [11:0] imm_stores[NUM_STORES];

// Constantes fixas
localparam bit [6:0] LOAD_OPCODE  = 7'b0000011;
localparam bit [2:0] LW_FUNCT3    = 3'b010;
localparam bit [6:0] STORE_OPCODE = 7'b0100011;
localparam bit [2:0] SW_FUNCT3    = 3'b010;

  function new(string name = "RISCV_load_store_seq");
    super.new(name);
  endfunction

  virtual task body();
   // Generate multiple load transactions
    repeat(`NO_OF_TRANSACTIONS) begin
      req = RISCV_transaction_block::type_id::create("req");
      start_item(req);

      foreach (rd_loads[i]) begin
        rd_loads[i] = i;
        rs2_stores[i] = i;
      end

      if (!randomize(rs1_stores, imm_loads, data_to_load, rs1_stores, imm_stores )) begin
        `uvm_fatal(get_type_name(), "Randomization failed!");
      end

      req.instr_data = new[BLOCK_SIZE];
      req.data_rd    = new[BLOCK_SIZE];
      req.instr_name = new[BLOCK_SIZE];

      // Preenche as instruções de LOAD
    for (int i = 0; i < NUM_LOADS; i++) begin
      // Alinha o immediate (opcional)
      imm_loads[i][1:0] = 2'b00;
      
      // Monta a instrução LW
      req.instr_data[i] = {
        imm_loads[i],        // [31:20] immediate
        rs1_loads[i],        // [19:15] base register
        funct3,           // [14:12] funct3
        rd_loads[i],         // [11:7] destination register
        LOAD_OPCODE          // [6:0] opcode
      };
      
      req.data_rd[i] = data_to_load[i]; // Dados que serão lidos
      req.instr_name[i] = $sformatf("LW x%0d, %0d(x%0d)", 
                                         rd_loads[i], 
                                         $signed(imm_loads[i]), 
                                         rs1_loads[i]);
    end
    
    // Preenche as instruções de STORE
    for (int i = 0; i < NUM_STORES; i++) begin
      int idx = NUM_LOADS + i;
      
      // Alinha o immediate
      imm_stores[i][1:0] = 2'b00;
      
      // Monta a instrução SW
      req.instr_data[idx] = {
        imm_stores[i][11:5],  // [31:25] imm[11:5]
        rs2_stores[i],         // [24:20] source register 2
        rs1_stores[i],         // [19:15] base register
        SW_FUNCT3,             // [14:12] funct3
        imm_stores[i][4:0],    // [11:7]  imm[4:0]
        STORE_OPCODE           // [6:0]   opcode
      };
      
      req.data_rd[idx] = 0; // Não usado para stores
      req.instr_name[idx] = $sformatf("SW x%0d, %0d(x%0d)", 
                                           rs2_stores[i], 
                                           $signed(imm_stores[i]), 
                                           rs1_stores[i]);
    end

    foreach (req.instr_name[i]) begin
      $display("%0d =>  instr_data = %08h |  instr_name = %s", i, req.instr_data[i], req.instr_name[i]);
    end

    finish_item(req);
    end
  endtask

endclass

`endif