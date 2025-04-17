//==============================================================================
//  File name: snn_top.sv
//  Author : Gaurang Pandey
//  Description: Top-level testbench module for SNN
//==============================================================================

`timescale 1ns/1ps

`include "uvm_macros.svh"
import uvm_pkg::*;
import network_pkg::*;
import neuron_pkg::*;
import snn_tb_pkg::*;

module snn_tb_top;

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

    assign snn_vif.clk = clk;
    assign snn_vif.rst_n = rst_n;

    // DUT instantiation
    spike_neural_network dut (
        .clk(clk),
        .rst_n(rst_n),
        .pixel_input(snn_vif.pixel_input),
        .leak_factor(snn_vif.leak_factor),
        .digit_spikes(snn_vif.digit_spikes),

        // APB connections
        .paddr(snn_vif.paddr),
        .psel(snn_vif.psel),
        .penable(snn_vif.penable),
        .pwrite(snn_vif.pwrite),
        .pwdata(snn_vif.pwdata),
        .prdata(snn_vif.prdata),
        .pready(snn_vif.pready)
    );

    // UVM test start
    initial begin
        uvm_config_db#(virtual snn_if)::set(null, "*", "vif", snn_vif);
        run_test("snn_base_test");
    end

endmodule

