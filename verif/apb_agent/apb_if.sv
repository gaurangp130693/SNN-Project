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
  clocking apb_cb @(posedge clk);
    output psel;
    output penable;
    output pwrite;
    output paddr;
    output pwdata;
    input  prdata;
    input  pready;
  endclocking
  
  // APB monitor clocking block
  clocking apb_monitor_cb @(posedge clk);
    input psel;
    input penable;
    input pwrite;
    input paddr;
    input pwdata;
    input prdata;
    input pready;
  endclocking
  
  // Modport for driver
  modport driver (clocking apb_cb, input clk, input rst_n);
  
  // Modport for monitor
  modport monitor (clocking apb_monitor_cb, input clk, input rst_n);
  
  // Assertions for APB protocol checking
  // PSEL must be asserted before PENABLE
  property psel_before_penable;
    @(posedge clk) disable iff(!rst_n)
      penable |-> $past(psel);
  endproperty
  
  // PENABLE should be asserted for only one cycle per transfer
  property penable_one_cycle;
    @(posedge clk) disable iff(!rst_n)
      (psel && penable && pready) |=> !penable;
  endproperty
  
  // Address and data should remain stable during access phase
  property stable_addr_data;
    @(posedge clk) disable iff(!rst_n)
      (psel && !penable) |=> (psel && penable && (paddr == $past(paddr)) && 
                             (pwrite == $past(pwrite)) && 
                             (pwrite |-> (pwdata == $past(pwdata))));
  endproperty
  
  // Assert the properties
  assert property(psel_before_penable)
    else $error("APB Protocol Violation: PENABLE asserted without PSEL");
    
  assert property(penable_one_cycle)
    else $error("APB Protocol Violation: PENABLE asserted for more than one cycle");
    
  assert property(stable_addr_data)
    else $error("APB Protocol Violation: Address or data not stable during access phase");
  
endinterface