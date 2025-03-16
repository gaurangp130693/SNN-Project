//==============================================================================
//  File name: synapse_tb.sv
//  Author : Gaurang Pandey
//  Description: Testbench for Synapse Module
//==============================================================================

module synapse_tb;
  import neuron_pkg::*;
  typedef logic [7:0] weight_t;

  // Signal declarations
  logic clk;
  logic rst_n;
  logic learning_enable;
  logic store_final;
  logic pre_spike;
  logic post_spike;
  weight_t weight;
  logic weighted_spike;

  // Instantiate the synapse module (DUT)
  synapse dut (
    .clk(clk),
    .rst_n(rst_n),
    .learning_enable(learning_enable),
    .store_final(store_final),
    .pre_spike(pre_spike),
    .post_spike(post_spike),
    .weight(weight),
    .weighted_spike(weighted_spike)
  );

  // Clock generation: 10 time unit period
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Helper task to wait for a given number of clock cycles
  task wait_cycles(input integer num_cycles);
    integer i;
    for (i = 0; i < num_cycles; i = i + 1)
      @(posedge clk);
  endtask

  // Stimulus generation using clock cycles
  initial begin
    // Initialize signals and hold reset low
    rst_n = 0;
    learning_enable = 1;  // Enable learning initially
    pre_spike = 0;
    post_spike = 0;
    store_final = 0;

    // Hold reset for 2 clock cycles
    wait_cycles(2);
    rst_n = 1;

    // Wait one cycle before starting stimulus
    wait_cycles(1);

    // *** Learning Enabled Phase ***
    // Test Case 1: Both spikes active -> weight should increase
    pre_spike = 1;
    post_spike = 1;
    wait_cycles(1);
    pre_spike = 0;
    post_spike = 0;
    wait_cycles(1);

    // Test Case 2: Only pre_spike active -> weight should decrease
    pre_spike = 1;
    post_spike = 0;
    wait_cycles(1);
    pre_spike = 0;
    post_spike = 0;
    wait_cycles(1);

    // Repeat a few training cycles
    repeat (3) begin
      pre_spike = 1;
      post_spike = 1;
      wait_cycles(1);
      pre_spike = 0;
      post_spike = 0;
      wait_cycles(1);
    end
    // Repeat a few training cycles
    repeat (1) begin
      pre_spike = 1;
      post_spike = 1;
      wait_cycles(3);
    end
    // Now disable learning; weights should freeze
    learning_enable = 0;
    $display("Learning disabled: synaptic weights should now remain fixed.");

    // *** Learning Disabled Phase ***
    // Apply additional pulses; weight should not change
    pre_spike = 1;
    post_spike = 1;
    wait_cycles(1);
    pre_spike = 0;
    post_spike = 0;
    wait_cycles(1);

    // More stimulus to verify no weight update occurs
    repeat (3) begin
      pre_spike = 1;
      post_spike = 0;
      wait_cycles(1);
      pre_spike = 0;
      post_spike = 0;
      wait_cycles(1);
    end
    store_final = 1;

    // End simulation after a few clock cycles
    wait_cycles(2);
    $finish;
  end

  // Monitor signal changes to observe weight updates and freezing
  initial begin
    $monitor("Time: %0t | learning_enable: %b | pre_spike: %b | post_spike: %b | weight: %h | weighted_spike: %b",
             $time, learning_enable, pre_spike, post_spike, weight, weighted_spike);
  end
endmodule