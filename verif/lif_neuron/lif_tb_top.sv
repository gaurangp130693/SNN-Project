//==============================================================================
//  File name: lif_tb_top.sv
//  Author    : Gaurang Pandey
//  Description: Top-level testbench for LIF neuron. Instantiates DUT and connects UVM.
//==============================================================================

`timescale 1ns / 1ps

`include "uvm_macros.svh"
import uvm_pkg::*;
import neuron_pkg::*;
import lif_tb_pkg::*;

module lif_tb_top;

    // Clock and reset
    bit clk;
    bit rst_n;

    // Generate clock: 10ns period (100 MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // Interface instance
    lif_if lif_if_inst (clk, rst_n);

    // DUT instantiation
    lif_neuron dut (
        .clk               (lif_if_inst.clk),
        .rst_n             (lif_if_inst.rst_n),
        .input_spike       (lif_if_inst.input_spike),
        .threshold         (lif_if_inst.threshold),
        .leak_factor       (lif_if_inst.leak_factor),
        .output_spike      (lif_if_inst.output_spike)
    );

    // Run UVM test
    initial begin
        uvm_config_db#(virtual lif_if)::set(null, "*", "vif", lif_if_inst);
        run_test("lif_base_test");
    end

    initial begin
      rst_n = 0;
      repeat(20) @(posedge clk);
      rst_n = 1;
    end

endmodule
