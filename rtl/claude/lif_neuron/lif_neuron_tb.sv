//==============================================================================
//  File name: lif_neuron_tb.sv
//  Author : Gaurang Pandey
//  Description: Testbench for lif_neuron module
//==============================================================================
`timescale 1ns/1ps

module lif_neuron_tb;
  import neuron_pkg::*;

  logic clk;
  logic rst_n;
  logic input_spike;
  leak_t leak_factor;
  logic output_spike;
  membrane_t membrane_potential;

  // DUT Instantiation
  lif_neuron uut (
    .clk(clk),
    .rst_n(rst_n),
    .input_spike(input_spike),
    .leak_factor(leak_factor),
    .output_spike(output_spike),
    .membrane_potential(membrane_potential)
  );

  // Clock Generation
  always #5 clk = ~clk;

  // Test Procedure
  initial begin
    // Initialize signals
    clk = 0;
    rst_n = 0;
    input_spike = 0;
    leak_factor = 8'd6; // Example leak factor

    // Reset sequence
    @(negedge clk) rst_n = 1;

    // Apply input spikes and observe membrane potential
    repeat (4) begin
      @(posedge clk) input_spike = 1;
      @(posedge clk) input_spike = 0;
    end

    // Allow potential to decay
    repeat (20) begin
      @(posedge clk) input_spike = 0;
    end

    // Apply continuous spikes until threshold is reached
    repeat (20) begin
      @(posedge clk) input_spike = 1;
    end
      @(posedge clk) input_spike = 0;

    // Stop simulation
    @(posedge clk); @(posedge clk); @(posedge clk); @(posedge clk); @(posedge clk); $finish;
  end

  // Monitor outputs
  initial begin
    $monitor("Time=%0t, Membrane Potential=%0h, Output Spike=%b", $time, membrane_potential, output_spike);
  end

endmodule
