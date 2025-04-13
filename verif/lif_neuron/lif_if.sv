//==============================================================================
//  File name: lif_if.sv
//  Author    : Gaurang Pandey
//  Description: Interface to connect DUT and UVM Testbench
//==============================================================================

interface lif_if(input logic clk, input logic rst);

    logic        enable;
    logic        input_spike;
    logic [15:0] neuron_config; // Assumed size, adjust as per RTL
    logic        output_spike;
    logic [15:0] membrane_potential;

endinterface : lif_if