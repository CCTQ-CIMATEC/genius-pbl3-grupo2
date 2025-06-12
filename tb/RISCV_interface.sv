`ifndef RISCV_INTERFACE
`define RISCV_INTERFACE

interface RISCV_interface
#(
    parameter P_DATA_WIDTH = 32,
    parameter P_IMEM_ADDR_WIDTH = 9,
    parameter P_DMEM_ADDR_WIDTH = 8
)
(input logic clk, reset);

  ////////////////////////////////////////////////////////////////////////////
  // Declaration of Signals
  ////////////////////////////////////////////////////////////////////////////

  // Instruction memory interface (to DUT)
  logic [P_DATA_WIDTH-1:0] instr_data;
  logic [P_IMEM_ADDR_WIDTH-1:0] inst_addr;

  // Data memory interface (to DUT)
  logic [P_DATA_WIDTH-1:0] data_rd;
  logic [P_DATA_WIDTH-1:0] data_wr;
  logic [P_DMEM_ADDR_WIDTH-1:0] data_addr;
  logic data_wr_en_ma;

  ////////////////////////////////////////////////////////////////////////////
  // clocking block and modport declaration for driver 
  ////////////////////////////////////////////////////////////////////////////
  clocking dr_cb @(posedge clk);
    output instr_data;
    output data_rd;
    input  inst_addr; 
    input  data_wr;
    input  data_addr;
    input  data_wr_en_ma;
  endclocking

  modport drv (clocking dr_cb, input clk, reset);

  ////////////////////////////////////////////////////////////////////////////
  // clocking block and modport declaration for monitor 
  ////////////////////////////////////////////////////////////////////////////
  clocking rc_cb @(negedge clk);
    input instr_data;
    input data_rd;
    input inst_addr; 
    input data_wr;
    input data_addr;
    input data_wr_en_ma;
  endclocking

  modport rcv (clocking rc_cb, input clk, reset);

endinterface

`endif