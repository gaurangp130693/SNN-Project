//==============================================================================
//  File name: neuron_layer_tb.sv
//  Author : Gaurang Pandey
//  Description: Testbench for neuron_layer module
//==============================================================================
`timescale 1ns/1ps

module neuron_layer_tb;
  import network_pkg::*;
  import neuron_pkg::*;

  // Testbench parameters
  parameter int INPUT_COUNT = 64;
  parameter int NEURON_COUNT = 10;

  // Signals
  logic clk;
  logic rst_n;
  logic input_spikes [INPUT_COUNT-1:0];
  logic [7:0] leak_factor;
  weight_t weight_reg[INPUT_COUNT-1:0][NEURON_COUNT-1:0];
  weight_t spike_threshold[INPUT_COUNT-1:0][NEURON_COUNT-1:0];
  logic output_spikes [NEURON_COUNT-1:0];
  logic [15:0] neuron_threshold [NEURON_COUNT-1:0];

  // Clock generation
  always #5 clk = ~clk;

  // DUT instantiation
  neuron_layer #(
    .INPUT_COUNT(INPUT_COUNT),
    .NEURON_COUNT(NEURON_COUNT)
  ) dut (
    .clk(clk),
    .rst_n(rst_n),
    .input_spikes(input_spikes),
    .weight_reg(weight_reg),
    .spike_threshold(spike_threshold),
    .neuron_threshold(neuron_threshold),
    .leak_factor(leak_factor),
    .output_spikes(output_spikes)
  );

  // Test procedure
  initial begin
    // Initialize signals
    clk = 0;
    rst_n = 0;
    leak_factor = 8'h05; // Example leak factor
    foreach (input_spikes[i]) input_spikes[i] = 1'b0;
    for(int i = 0; i < NEURON_COUNT; i++)  begin
      for(int j = 0; j < INPUT_COUNT; j++)  begin
        weight_reg[j][i] = $urandom;
        spike_threshold[j][i] = $urandom;
      end
      neuron_threshold[i] = $urandom;
    end

    // Apply reset
    @(posedge clk);
    rst_n = 1;
    @(posedge clk);

    repeat(500) begin
      // Apply stimulus
      @(posedge clk);
      input_spikes = '{16{1, 0, 1, 0}};
      @(posedge clk);
      input_spikes = '{16{0, 1, 0, 1}};
      @(posedge clk);
      input_spikes = '{16{1, 1, 0, 0}};
      @(posedge clk);
      input_spikes = '{16{1, 0, 0, 1}};
    end

    // Deassert data_valid
    @(posedge clk);
    @(posedge clk);

    // End simulation
    $finish;
  end

  // Monitor output spikes
  always @(posedge clk) begin
    $display("[%0t] Output Spikes: %p", $time, output_spikes);
  end

endmodule
