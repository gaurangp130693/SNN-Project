//==============================================================================
//  File name: snn_csr_apb_tb.sv
//  Author : Gaurang Pandey
//  Description: Testbench for CSR block
//==============================================================================

`timescale 1ns/1ps

module snn_csr_apb_tb;

  // Parameters (Match DUT)
  parameter int INPUT_SIZE = 8;   // Number of input neurons
  parameter int OUTPUT_SIZE = 4;  // Number of output neurons
  parameter int WEIGHT_BASE_ADDR = 16'h0000;
  parameter int SPIKE_THRESH_BASE_ADDR = 16'h1000;
  parameter int NEURON_THRESH_BASE_ADDR = 16'h2000;

  // APB Signals
  logic clk;
  logic rst_n;
  logic psel;
  logic penable;
  logic pwrite;
  logic [15:0] paddr;
  logic [31:0] pwdata;
  logic [31:0] prdata;
  logic pready;

  // DUT Instance
  snn_csr_apb #(
    .INPUT_SIZE(INPUT_SIZE),
    .OUTPUT_SIZE(OUTPUT_SIZE),
    .WEIGHT_BASE_ADDR(WEIGHT_BASE_ADDR),
    .SPIKE_THRESH_BASE_ADDR(SPIKE_THRESH_BASE_ADDR),
    .NEURON_THRESH_BASE_ADDR(NEURON_THRESH_BASE_ADDR)
  ) dut (
    .clk(clk),
    .rst_n(rst_n),
    .psel(psel),
    .penable(penable),
    .pwrite(pwrite),
    .paddr(paddr),
    .pwdata(pwdata),
    .prdata(prdata),
    .pready(pready)
  );

  // Clock Generation
  always #5 clk = ~clk;  // 100MHz Clock (10ns Period)

  // APB Write Task
  task apb_write(input [7:0] addr, input [31:0] data);
    begin
      @(posedge clk);
      psel   = 1;
      pwrite = 1;
      paddr  = addr;
      pwdata = data;
      penable = 1;
      @(posedge clk);
      psel   = 0;
      penable = 0;
    end
  endtask

  // APB Read Task
  task apb_read(input [7:0] addr, output [31:0] data);
    begin
      @(posedge clk);
      psel   = 1;
      pwrite = 0;
      paddr  = addr;
      penable = 1;
      @(posedge clk);
      data = prdata;
      psel   = 0;
      penable = 0;
    end
  endtask

  // Test APB Reads
  logic [31:0] read_data;

  // Test Sequence
  initial begin
    // Initialize Signals
    clk = 0;
    rst_n = 0;
    psel = 0;
    penable = 0;
    pwrite = 0;
    paddr = 0;
    pwdata = 0;

    // Reset DUT
    repeat(2) @(posedge clk);
    rst_n = 1;

    for (int i = 0; i < 32; i = i + 4) begin
      // Test APB Writes
      apb_write(WEIGHT_BASE_ADDR + i, 32'hC0A0_8090 + i);  // Writing weights
      apb_write(SPIKE_THRESH_BASE_ADDR + i, 32'h7050_6090 + i);  // Writing spike thresholds
      apb_write(NEURON_THRESH_BASE_ADDR + i, 32'h8000_4000 + i);  // Writing neuron thresholds
    end
    // apb_write(WEIGHT_BASE_ADDR + 4, 32'hAAAA_BBBB);  // Writing weights
    // apb_write(SPIKE_THRESH_BASE_ADDR + 4, 32'h1111_2222);  // Writing spike thresholds
    // apb_write(NEURON_THRESH_BASE_ADDR + 4, 32'h8333_4444);  // Writing neuron thresholds


    for (int i = 0; i < 32; i = i + 4) begin
      apb_read(WEIGHT_BASE_ADDR + i, read_data);
      $display("WEIGHT Read: %h", read_data);

      apb_read(SPIKE_THRESH_BASE_ADDR + i, read_data);
      $display("SPIKE_THRESH Read: %h", read_data);

      apb_read(NEURON_THRESH_BASE_ADDR + i, read_data);
      $display("NEURON_THRESH Read: %h", read_data);
    end

    //apb_read(WEIGHT_BASE_ADDR + 4, read_data);
    //$display("WEIGHT Read: %h", read_data);

    //apb_read(SPIKE_THRESH_BASE_ADDR + 4, read_data);
    //$display("SPIKE_THRESH Read: %h", read_data);

    //apb_read(NEURON_THRESH_BASE_ADDR + 4, read_data);
    //$display("NEURON_THRESH Read: %h", read_data);

    // End Simulation
    $finish;
  end
endmodule