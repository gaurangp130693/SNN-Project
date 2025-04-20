// Filename: snn_if.sv
// Author: Gaurang Pandey
// Description: Interface for SNN DUT connections with APB

import network_pkg::*;
interface snn_if ();
    logic clk;
    logic rst_n;

    // Input pixel array
    logic [PIXEL_WIDTH-1:0] pixel_input [INPUT_SIZE-1:0];

    // Leak factor
    logic [7:0] leak_factor;

    // Output digit spikes
    logic digit_spikes [OUTPUT_SIZE-1:0];

    // Driver clocking block
    clocking drv_cb @(posedge clk);
        default input #1ns output #1ns;
        output pixel_input;
        output leak_factor;
        input  digit_spikes;
    endclocking

    // Monitor clocking block
    clocking mon_cb @(posedge clk);
        default input #1ns;
        input pixel_input;
        input leak_factor;
        input digit_spikes;
    endclocking

    // CSR Register Values
    logic [31:0] weight_reg_u0[((network_pkg::INPUT_SIZE * network_pkg::HIDDEN_SIZE) / 4) - 1:0];
    logic [31:0] spike_threshold_u0[((network_pkg::INPUT_SIZE * network_pkg::HIDDEN_SIZE) / 4) - 1:0];
    logic [31:0] neuron_threshold_u0[network_pkg::HIDDEN_SIZE-1:0];

    logic [31:0] weight_reg_u1[((network_pkg::HIDDEN_SIZE * network_pkg::OUTPUT_SIZE) / 4) - 1:0];
    logic [31:0] spike_threshold_u1[((network_pkg::HIDDEN_SIZE * network_pkg::OUTPUT_SIZE) / 4) - 1:0];
    logic [31:0] neuron_threshold_u1[network_pkg::OUTPUT_SIZE-1:0];

    // Control status registers
    logic [31:0] cntrl_status_csr_u0;
    logic [31:0] cntrl_status_csr_u1;
    
endinterface
