`ifndef RISCV_INTERFACE
`define RISCV_INTERFACE

interface RISCV_interface(input logic clk, reset);

  ////////////////////////////////////////////////////////////////////////////
  // Declaration of Signals
  ////////////////////////////////////////////////////////////////////////////

  // Instruction memory interface (to DUT)
  logic instr_ready;
  logic [31:0] instr_data;

  // Data memory interface (to DUT)
  logic data_ready;
  logic [31:0] data_rd;

  // Outputs from DUT
  logic inst_rd_en;
  logic [3:0] inst_ctrl_cpu;
  logic [31:0] inst_addr;
  logic [31:0] data_wr;
  logic [31:0] data_addr;
  logic [3:0] data_rd_en_ctrl;
  logic data_rd_en_ma;
  logic data_wr_en_ma;

  ////////////////////////////////////////////////////////////////////////////
  // clocking block and modport declaration for driver 
  ////////////////////////////////////////////////////////////////////////////
  clocking dr_cb @(posedge clk);
    output instr_ready;
    output instr_data;
    output data_ready;
    output data_rd;
    input  inst_rd_en; 
    input  inst_addr; 
    input  data_wr;
    input  data_addr;
    input  data_rd_en_ctrl; 
    input  data_rd_en_ma;
    input  data_wr_en_ma;
  endclocking

  modport drv (clocking dr_cb, input clk, reset);

  ////////////////////////////////////////////////////////////////////////////
  // clocking block and modport declaration for monitor 
  ////////////////////////////////////////////////////////////////////////////
  clocking rc_cb @(negedge clk);
    input instr_ready;
    input instr_data;
    input data_ready;
    input data_rd;
    input inst_rd_en; 
    input inst_addr; 
    input data_wr;
    input data_addr;
    input data_rd_en_ctrl; 
    input data_rd_en_ma;
    input data_wr_en_ma;
  endclocking

  modport rcv (clocking rc_cb, input clk, reset);

endinterface

`endif