//==============================================================================
//  File name: apb_if.sv
//  Author : Gaurang Pandey
//  Description: APB Interface for SNN UVM testbench
//==============================================================================

interface apb_if (input logic clk, input logic rst_n);

  // APB signals
  logic        psel;
  logic        penable;
  logic        pwrite;
  logic [31:0] paddr;
  logic [31:0] pwdata;
  logic [31:0] prdata;
  logic        pready;

  // APB write clocking block
  clocking apb_drv_cb @(posedge clk);
    output psel;
    output penable;
    output pwrite;
    output paddr;
    output pwdata;
    input  prdata;
    input  pready;
  endclocking

  // APB monitor clocking block
  clocking apb_mon_cb @(posedge clk);
    input psel;
    input penable;
    input pwrite;
    input paddr;
    input pwdata;
    input prdata;
    input pready;
  endclocking

  // Modport for driver
  modport driver (clocking apb_drv_cb, input clk, input rst_n);

  // Modport for monitor
  modport monitor (clocking apb_mon_cb, input clk, input rst_n);

endinterface