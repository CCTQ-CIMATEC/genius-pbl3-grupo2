//------------------------------------------------------------------------------
// Store sequence for RISCV
//------------------------------------------------------------------------------
// This sequence generates randomized transactions for the RISCV UVM verification.
//
// Author: Gustavo Santiago
// Date  : July 2025
//------------------------------------------------------------------------------

`ifndef RISCV_BEQ_SEQ 
`define RISCV_BEQ_SEQ

class RISCV_beq_seq extends uvm_sequence#(RISCV_transaction);
   
  `uvm_object_utils(RISCV_beq_seq)

  function new(string name = "RISCV_beq_seq");
    super.new(name);
  endfunction

  // Fields to be randomized
  rand bit [4:0] rs1;
  rand bit [4:0] rs2;
  rand bit [11:0] imm;

  // Fixed opcode and funct3 for beq instructions
  localparam bit [6:0] BEQ_OPCODE = 7'b1100011;
  rand bit [2:0] funct3;
  string instr_name_str;

  constraint funct3_allowed_values {
    funct3 inside {3'b000, 3'b001, 3'b100, 3'b101, 3'b110, 3'b111};
  }

  virtual task body();
    // Generate multiple beq transactions
    repeat(`NO_OF_TRANSACTIONS) begin
      req = RISCV_transaction::type_id::create("req");
      start_item(req);

      // Randomize the fields
      if (!randomize(rs1, rs2, imm, funct3)) 
        `uvm_fatal(get_type_name(), "Randomization failed!");

      imm[1:0] = 2'b00; // Align to word boundary for SW instruction

      // Build the beq instruction (S-type encoding)
      req.instr_data = {
        imm[11:5], rs2, rs1, funct3, imm[4:0], BEQ_OPCODE
      };
      

      case (funct3)
        3'b000: instr_name_str = "BEQ";
        3'b001: instr_name_str = "BNE";
        3'b100: instr_name_str = "BLT";
        3'b101: instr_name_str = "BGE";
        3'b110: instr_name_str = "BLTU";
        3'b111: instr_name_str = "BGEU";
        default: instr_name_str = "UNKNOWN";
      endcase

      req.instr_name = $sformatf("%s x%0d, x%0d, 0x%0h", instr_name_str, rs1, rs2, imm);

      `uvm_info(get_full_name(), $sformatf("Generated BEQ instruction: %s", req.instr_name), UVM_LOW);
      
      finish_item(req);
    end
  endtask
   
endclass

`endif