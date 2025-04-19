//==============================================================================
//  File name: snn_top.sv
//  Author : Gaurang Pandey
//  Description: Top-level testbench module for SNN
//==============================================================================

`timescale 1ns/1ps

module snn_tb_top;

    `include "uvm_macros.svh"
    import uvm_pkg::*;
    import network_pkg::*;
    import neuron_pkg::*;
    import snn_tb_pkg::*;
    // Clock and reset
    logic clk;
    logic rst_n;

    // Clock generation (100 MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // Reset generation
    initial begin
        rst_n = 0;
        #100;
        rst_n = 1;
    end

    snn_if snn_vif ();
    apb_if apb_vif (clk, rst_n);

    assign snn_vif.clk = dut.clk_cnt;
    assign snn_vif.rst_n = dut.u_reset_sync.rst_n_sync;

    // DUT instantiation
    spike_neural_network dut (
        .clk(clk),
        .rst_n(rst_n),
        .pixel_input(snn_vif.pixel_input),
        .leak_factor(snn_vif.leak_factor),
        .digit_spikes(snn_vif.digit_spikes),

        // APB connections
        .paddr(apb_vif.paddr),
        .psel(apb_vif.psel),
        .penable(apb_vif.penable),
        .pwrite(apb_vif.pwrite),
        .pwdata(apb_vif.pwdata),
        .prdata(apb_vif.prdata),
        .pready(apb_vif.pready)
    );

    // UVM test start
    initial begin
        uvm_config_db#(virtual snn_if)::set(null, "*", "vif", snn_vif);
        uvm_config_db#(virtual apb_if)::set(null, "*", "vif", apb_vif);
        run_test("snn_base_test");
    end

endmodule