//==============================================================================
//  File name: lif_tb_top.sv
//  Author    : Gaurang Pandey
//  Description: Top-level testbench for LIF neuron. Instantiates DUT and connects UVM.
//==============================================================================

`timescale 1ns / 1ps

`include "uvm_macros.svh"
import uvm_pkg::*;
import neuron_pkg::*;

module lif_tb_top;

    // Clock and reset
    bit clk;
    bit rst;

    // Generate clock: 10ns period (100 MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // Interface instance
    lif_if lif_if_inst (.*);

    // DUT instantiation
    lif_neuron dut (
        .clk               (lif_if_inst.clk),
        .rst               (lif_if_inst.rst),
        .enable            (lif_if_inst.enable),
        .input_spike       (lif_if_inst.input_spike),
        .neuron_config     (lif_if_inst.neuron_config),
        .membrane_potential(lif_if_inst.membrane_potential),
        .output_spike      (lif_if_inst.output_spike)
    );

    // Run UVM test
    initial begin
        uvm_config_db#(virtual lif_if)::set(null, "*", "vif", lif_if_inst);
        run_test("lif_base_test");
    end

endmodule
