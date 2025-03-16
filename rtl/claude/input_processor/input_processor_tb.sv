//==============================================================================
//  File name: input_processor_tb.sv
//  Author : Gaurang Pandey
//  Description: Testbench for Input Processor module
//==============================================================================

module input_processor_tb;
  import network_pkg::*;

  // Testbench signals
  logic clk;
  logic rst_n;
  logic clk_cnt;
  logic [PIXEL_WIDTH-1:0] pixel_value [INPUT_SIZE-1:0];
  logic spike_out [INPUT_SIZE-1:0];

  // DUT (Device Under Test)
  input_processor uut (
    .clk(clk),
    .rst_n(rst_n),
    .clk_cnt(clk_cnt),
    .pixel_value(pixel_value),
    .spike_out(spike_out)
  );

  // Clock generation (50MHz)
  always #10 clk = ~clk;      // 20ns period

  // Slow counter clock (2MHz)
  always #250 clk_cnt = ~clk_cnt; // 500ns period

  // Testbench process
  initial begin
    // Initialize signals
    clk = 0;
    clk_cnt = 0;
    rst_n = 0;
    for (int i = 0; i < INPUT_SIZE; i++) pixel_value[i] = 0;

    // Reset the system
    #50;
    rst_n = 1;
    #50;

    // Test Case 1: Low pixel values (small number of spikes)
    pixel_value[0] = 32;   // Should spike for ~2 cycles in 16
    pixel_value[1] = 64;   // Should spike for ~4 cycles in 16
    pixel_value[2] = 128;  // Should spike for ~8 cycles in 16
    pixel_value[3] = 255;  // Should spike for all 16 cycles
    // Run for multiple spike cycles
    repeat(32) @(posedge clk_cnt);

    // Test Case 2: Random values
    pixel_value[0] = 10;
    pixel_value[1] = 120;
    pixel_value[2] = 200;
    pixel_value[3] = 250;
    // Run for multiple spike cycles
    repeat(32) @(posedge clk_cnt);

    // Test Case 3: All pixels at max intensity (continuous spiking)
    for (int i = 0; i < INPUT_SIZE; i++) pixel_value[i] = 255;
    // Run for multiple spike cycles
    repeat(32) @(posedge clk_cnt);

    // End Simulation
    $finish;
  end

  // Monitor spikes for debugging
  always @(posedge clk) begin
    $display("Time: %0t | Spikes: %p", $time, spike_out);
  end
endmodule

