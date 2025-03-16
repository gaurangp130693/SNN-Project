//==============================================================================
//  File name: network_tb.sv
//  Author : Gaurang Pandey
//  Description: Testbench for Digit Recognition Spiking Neural Network
//==============================================================================

module tb_digit_recognition_network;
  import network_pkg::*;

  // Signals
  logic clk;
  logic rst_n;
  logic [PIXEL_WIDTH-1:0] pixel_input [INPUT_SIZE-1:0];
  logic [7:0] leak_factor;
  logic digit_spikes [OUTPUT_SIZE-1:0];
  logic psel;
  logic penable;
  logic pwrite;
  logic [15:0] paddr;
  logic [31:0] pwdata;
  logic [31:0] prdata;
  logic pready;

  // Test APB Reads
  logic [31:0] read_data;

  // Instantiate DUT
  digit_recognition_network dut (
    .clk(clk),
    .rst_n(rst_n),
    .pixel_input(pixel_input),
    .leak_factor(leak_factor),
    .digit_spikes(digit_spikes),
    .psel(psel),
    .penable(penable),
    .pwrite(pwrite),
    .paddr(paddr),
    .pwdata(pwdata),
    .prdata(prdata),
    .pready(pready)
  );

  // Clock generation (100 MHz)
  always # (CLK_PERIOD / 2) clk = ~clk;

  // Reset sequence
  initial begin
    clk   = 0;
    rst_n = 0;
    leak_factor = 8'h10;  // Example leak factor
    pixel_input = '{default: 0}; // Initialize inputs to zero

    repeat (5) @(posedge clk);  // Hold reset for 5 clock cycles
    rst_n = 1;

    $display("Reset deasserted, starting test...");
  end

  // Stimulus generation
  initial begin
    @(posedge rst_n); // Wait for reset to be deasserted

    for (int i = 0; i < (INPUT_SIZE*HIDDEN_SIZE); i = i + 4) begin
      // Test APB Writes
      apb_write(LAYER_WEIGHT_BASE_ADDR_U0 + i       , 32'h1000_0000 + i);  // Writing weights
      apb_write(LAYER_SPIKE_THRESH_BASE_ADDR_U0 + i , 32'h2000_0000 + i);  // Writing spike thresholds
      apb_write(LAYER_NEURON_THRESH_BASE_ADDR_U0 + i, 32'h3000_0000 + i);  // Writing neuron thresholds
    end
    apb_write(CONTROL_STATUS_BASE_ADDR_U0, 32'hFFFFFFFFF);  // Writing control status csr
    for (int i = 0; i < (INPUT_SIZE*HIDDEN_SIZE); i = i + 4) begin
      apb_read(LAYER_WEIGHT_BASE_ADDR_U0 + i, read_data);
      $display("WEIGHT Read: %h", read_data);
      apb_read(LAYER_SPIKE_THRESH_BASE_ADDR_U0 + i, read_data);
      $display("SPIKE_THRESH Read: %h", read_data);
      apb_read(LAYER_NEURON_THRESH_BASE_ADDR_U0 + i, read_data);
      $display("NEURON_THRESH Read: %h", read_data);
    end
    apb_read(CONTROL_STATUS_BASE_ADDR_U0, read_data);
    $display("CONTROL_STATUS Read: %h", read_data);

   for (int i = 0; i < (HIDDEN_SIZE*OUTPUT_SIZE); i = i + 4) begin
      // Test APB Writes
      apb_write(LAYER_WEIGHT_BASE_ADDR_U1 + i       , 32'h6000_0000 + i);  // Writing weights
      apb_write(LAYER_SPIKE_THRESH_BASE_ADDR_U1 + i , 32'h7000_0000 + i);  // Writing spike thresholds
      apb_write(LAYER_NEURON_THRESH_BASE_ADDR_U1 + i, 32'h8000_0000 + i);  // Writing neuron thresholds
    end
    apb_write(CONTROL_STATUS_BASE_ADDR_U1, 32'hFFFFFFFFF);  // Writing control status csr
    for (int i = 0; i < (HIDDEN_SIZE*OUTPUT_SIZE); i = i + 4) begin
      apb_read(LAYER_WEIGHT_BASE_ADDR_U1 + i, read_data);
      $display("WEIGHT Read: %h", read_data);
      apb_read(LAYER_SPIKE_THRESH_BASE_ADDR_U1 + i, read_data);
      $display("SPIKE_THRESH Read: %h", read_data);
      apb_read(LAYER_NEURON_THRESH_BASE_ADDR_U1 + i, read_data);
      $display("NEURON_THRESH Read: %h", read_data);
    end
    apb_read(CONTROL_STATUS_BASE_ADDR_U1, read_data);
    $display("CONTROL_STATUS Read: %h", read_data);
    repeat (1000) @(posedge clk);

    // Apply test cases on clock edges
    for (int i = 0; i < 5; i++) begin
      pixel_input[0] = $urandom_range(0, 255);
      pixel_input[1] = $urandom_range(0, 255);
      pixel_input[2] = $urandom_range(0, 255);
      pixel_input[3] = $urandom_range(0, 255);
      pixel_input[4] = $urandom_range(0, 255);
      pixel_input[5] = $urandom_range(0, 255);
      pixel_input[6] = $urandom_range(0, 255);
      pixel_input[7] = $urandom_range(0, 255);

      $display("Cycle %0d: Inputs = [%0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d]",
               i, pixel_input[0], pixel_input[1], pixel_input[2], pixel_input[3],
               pixel_input[4], pixel_input[5], pixel_input[6], pixel_input[7]);
      // Wait for some cycles to observe output spikes
      repeat (1000) @(posedge clk);
    end


    // Display output spikes
    $monitor("Final Output Spikes: [%b, %b]", digit_spikes[0], digit_spikes[1]);

    $stop; // End simulation
  end

  task apb_write(input [15:0] addr, input [31:0] data);
    begin
      @(posedge clk);
      psel   = 1;
      penable = 0;
      pwrite = 1;
      paddr  = addr;
      pwdata = data;

      @(posedge clk);  // Setup phase
      penable = 1;     // Enable the transfer

      @(posedge clk);  // Data phase
      penable = 0;     // Deassert enable
      psel   = 0;      // Deassert select
    end
  endtask


  task apb_read(input [15:0] addr, output [31:0] data);
    begin
      @(posedge clk);
      psel   = 1;
      penable = 0;
      pwrite = 0;
      paddr  = addr;

      @(posedge clk);  // Setup phase
      penable = 1;     // Enable the transfer

      @(posedge clk);  // Data phase
      data = prdata;   // Read data now
      penable = 0;     // Deassert enable
      psel   = 0;      // Deassert select
    end
  endtask

endmodule