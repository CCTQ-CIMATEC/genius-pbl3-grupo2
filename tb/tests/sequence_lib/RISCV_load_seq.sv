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

class RISCV_load_seq extends uvm_sequence #(RISCV_transaction);
   
  `uvm_object_utils(RISCV_load_seq)

  function new(string name = "RISCV_load_seq");
    super.new(name);
  endfunction


// Fields to be randomized
  rand bit [11:0] imm;
  rand bit [4:0]  rs1;
  rand bit [2:0]  funct3;
  rand bit [4:0]  rd;
       bit        instr_ready;
       bit        instr_data;

  // Fixed opcode for_load instructions
  localparam bit [6:0] LOAD_OPCODE = 7'b0000011;

  // Constraints
  constraint valid_load {
    
    imm inside {[0:4095]}; // 12-bit immediate
    
    rs1 inside    {[0:31]};
    funct3 inside {3'b000, 3'b001, 3'b010, 3'b100, 3'b101};         // LB, LH, LW, LBU, LHU
    rd inside     {[0:31]}; 
    
  }

  // Optionally, align imm for LW to word boundaries
  constraint consistent_load {
    // Se for LW, imm deve ser alinhado
    (funct3 == 3'b010) -> (imm[1:0] == 2'b00);
  
    // Se for LH/LHU, imm deve ter bit[0] = 0
    (funct3 inside {3'b001, 3'b101}) -> (imm[0] == 0);
  }


  virtual task body();
    for (int i = 0; i < `NO_OF_TRANSACTIONS; i++) begin
      
      req = RISCV_transaction::type_id::create("req");
      start_item(req);

      assert(req.randomize()) else `uvm_fatal(get_type_name(), "Randomization failed!");

      // Build the_load instruction (l-type encoding)
      instr_ready = 1'b1;
      instr_data = {imm[11:0], rs1, funct3, rd, LOAD_OPCODE  // Running LW instruction
      };

      // Optional: for debug/coverage
      case (funct3)
        3'b000: req.instr_name = $sformatf("LB x%0d, %0d(x%0d)", rd, imm, rs1);
        3'b001: req.instr_name = $sformatf("LH x%0d, %0d(x%0d)", rd, imm, rs1);
        3'b010: req.instr_name = $sformatf("LW x%0d, %0d(x%0d)", rd, imm, rs1);
        3'b100: req.instr_name = $sformatf("LBU x%0d, %0d(x%0d)",rd, imm, rs1);
        3'b101: req.instr_name = $sformatf("LHU x%0d, %0d(x%0d)",rd, imm, rs1);
        default: req.instr_name = "UNKNOWN_LOAD";
      endcase

      `uvm_info(get_full_name(), $sformatf("Sending_load instruction: %s", req.instr_name), UVM_LOW);
      req.print();

      finish_item(req);
      get_response(rsp);
    end
  endtask
   
endclass

`endif

