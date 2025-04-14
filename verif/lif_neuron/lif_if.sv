//==============================================================================
//  File name: lif_if.sv
//  Author    : Gaurang Pandey
//  Description: Interface to connect DUT and UVM Testbench
//==============================================================================

interface lif_if(input logic clk, input logic rst_n);

    logic        input_spike;
    logic [15:0] threshold; // Assumed size, adjust as per RTL
    logic        output_spike;
    logic [15:0] leak_factor;

endinterface : lif_if