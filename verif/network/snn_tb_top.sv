//==============================================================================
//  File name: snn_top.sv
//  Author : Gaurang Pandey
//  Description: Top-level testbench module for SNN
//==============================================================================

`timescale 1ns/1ps

`include "uvm_macros.svh"
import uvm_pkg::*;
import snn_tb_pkg::*;

module snn_tb_top;

    // Parameters (should match DUT)
    parameter INPUT_SIZE   = 64;
    parameter OUTPUT_SIZE  = 16;
    parameter PIXEL_WIDTH  = 8;

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

    // Interface instantiation
    snn_if #(
        .INPUT_SIZE(INPUT_SIZE),
        .OUTPUT_SIZE(OUTPUT_SIZE),
        .PIXEL_WIDTH(PIXEL_WIDTH)
    ) snn_vif (
        .clk(clk),
        .rst_n(rst_n)
    );

    // DUT instantiation
    network dut (
        .clk(clk),
        .rst_n(rst_n),
        .pixel_input(snn_vif.pixel_input),
        .leak_factor(snn_vif.leak_factor),
        .digit_spikes(snn_vif.digit_spikes),

        // APB connections
        .pclk(clk),
        .preset_n(rst_n),
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
        run_test();
    end

endmodule

