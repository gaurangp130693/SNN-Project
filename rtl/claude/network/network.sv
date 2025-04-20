//==============================================================================
//  File name: network.sv
//  Author : Gaurang Pandey
//  Description: Digit Recognition Spiking Neural Network with
//  One-input layer, one-hidden layer and one-output layer
//  Clock and Reset Generation Module
//  CSR blocks for each layer : hidden and output
//==============================================================================

module spike_neural_network
  import network_pkg::*;
  import neuron_pkg::*;
(
  input  logic                    clk,
  input  logic                    rst_n,
  input  logic [PIXEL_WIDTH-1:0] pixel_input [INPUT_SIZE-1:0],
  input  logic [7:0]             leak_factor,
  output logic                    digit_spikes [OUTPUT_SIZE-1:0],

  // APB Interface
  input logic psel,
  input logic penable,
  input logic pwrite,
  input logic [15:0] paddr,
  input logic [31:0] pwdata,
  output logic [31:0] prdata,
  output logic pready
);

  // Internal signals
  logic input_spikes [INPUT_SIZE-1:0];
  logic hidden_spikes [HIDDEN_SIZE-1:0];
  logic clk_cnt;
  logic rst_clk_cnt_n;
  logic csr_load_done;

  // APB signals for layer_u0 csr
  logic psel0;
  logic penable0;
  logic pready0;
  logic [31:0] prdata0;

  // APB signals for layer_u1 csr
  logic psel1;
  logic penable1;
  logic pready1;
  logic [31:0] prdata1;

  assign psel0 = (paddr >= LAYER_WEIGHT_BASE_ADDR_U0 && paddr < LAYER_WEIGHT_BASE_ADDR_U1) ? psel : 1'b0;
  assign psel1 = (paddr >= LAYER_WEIGHT_BASE_ADDR_U1) ? psel : 1'b0;
  assign penable0 = (paddr >= LAYER_WEIGHT_BASE_ADDR_U0 && paddr < LAYER_WEIGHT_BASE_ADDR_U1) ? penable : 1'b0;
  assign penable1 = (paddr >= LAYER_WEIGHT_BASE_ADDR_U1) ? penable : 1'b0;
  assign pready = (paddr >= LAYER_WEIGHT_BASE_ADDR_U0 && paddr < LAYER_WEIGHT_BASE_ADDR_U1) ? pready0 : pready1;
  assign prdata = (paddr >= LAYER_WEIGHT_BASE_ADDR_U0 && paddr < LAYER_WEIGHT_BASE_ADDR_U1) ? prdata0 : prdata1;

  // Clock Divider
  clock_divider #(
    .DIV_FACTOR(CLOCK_DIVIDER_VAL)
  ) clk_div8 (
    .clk_in(clk),
    .rst_n(rst_n),
    .clk_out(clk_cnt)
  );

  // Reset Synchronizer
  reset_synchronizer u_reset_sync (
      .clk(clk_cnt),
      .enable(csr_load_done),
      .rst_n_async(rst_n),
      .rst_n_sync(rst_clk_cnt_n)
  );

  // Input processing
  input_processor input_proc (
    .clk(clk),
    .rst_n(rst_n),
    .clk_cnt(clk_cnt),
    .pixel_value(pixel_input),
    .spike_out(input_spikes)
  );
 // Registers Outputs
  weight_t weight_reg_u0 [(INPUT_SIZE * HIDDEN_SIZE) - 1:0];
  weight_t spike_threshold_u0 [(INPUT_SIZE * HIDDEN_SIZE) - 1:0];
  weight_t neuron_threshold_u0 [HIDDEN_SIZE-1:0];
  logic [31:0] cntrl_status_csr_u0;

  snn_csr_apb #(
    .INPUT_SIZE(INPUT_SIZE),
    .OUTPUT_SIZE(HIDDEN_SIZE),
    .WEIGHT_BASE_ADDR(LAYER_WEIGHT_BASE_ADDR_U0),
    .SPIKE_THRESH_BASE_ADDR(LAYER_SPIKE_THRESH_BASE_ADDR_U0),
    .NEURON_THRESH_BASE_ADDR(LAYER_NEURON_THRESH_BASE_ADDR_U0),
    .CONTROL_STATUS_BASE_ADDR(CONTROL_STATUS_BASE_ADDR_U0)
  ) snn_csr_layer_u0 (
    .clk(clk),
    .rst_n(rst_n),
    .psel(psel0),
    .penable(penable0),
    .pwrite(pwrite),
    .paddr(paddr),
    .pwdata(pwdata),
    .prdata(prdata0),
    .pready(pready0),
    .weight_reg(weight_reg_u0),
    .spike_threshold(spike_threshold_u0),
    .neuron_threshold(neuron_threshold_u0),
    .cntrl_status_csr(cntrl_status_csr_u0)
  );

  // Hidden layer 1
  neuron_layer #(
    .INPUT_COUNT(INPUT_SIZE),
    .NEURON_COUNT(HIDDEN_SIZE)
  ) hidden (
    .clk(clk_cnt),
    .rst_n(rst_clk_cnt_n),
    .input_spikes(input_spikes),            // [INPUT_COUNT-1:0]
    .weight_reg(weight_reg_u0),             // [INPUT_COUNT-1:0][NEURON_COUNT-1:0]
    .spike_threshold(spike_threshold_u0),   // [INPUT_COUNT-1:0][NEURON_COUNT-1:0]
    .neuron_threshold(neuron_threshold_u0), // [NEURON_COUNT-1:0]
    .leak_factor(leak_factor),
    .output_spikes(hidden_spikes)           // [NEURON_COUNT-1:0]
  );

  // Registers Outputs
  weight_t weight_reg_u1 [(HIDDEN_SIZE * OUTPUT_SIZE) - 1:0];
  weight_t spike_threshold_u1 [(HIDDEN_SIZE * OUTPUT_SIZE) - 1:0];
  weight_t neuron_threshold_u1 [OUTPUT_SIZE-1:0];
  logic [31:0] cntrl_status_csr_u1;

  snn_csr_apb #(
    .INPUT_SIZE(HIDDEN_SIZE),
    .OUTPUT_SIZE(OUTPUT_SIZE),
    .WEIGHT_BASE_ADDR(LAYER_WEIGHT_BASE_ADDR_U1),
    .SPIKE_THRESH_BASE_ADDR(LAYER_SPIKE_THRESH_BASE_ADDR_U1),
    .NEURON_THRESH_BASE_ADDR(LAYER_NEURON_THRESH_BASE_ADDR_U1),
    .CONTROL_STATUS_BASE_ADDR(CONTROL_STATUS_BASE_ADDR_U1)
  ) snn_csr_layer_u1 (
    .clk(clk),
    .rst_n(rst_n),
    .psel(psel1),
    .penable(penable1),
    .pwrite(pwrite),
    .paddr(paddr),
    .pwdata(pwdata),
    .prdata(prdata1),
    .pready(pready1),
    .weight_reg(weight_reg_u1),
    .spike_threshold(spike_threshold_u1),
    .neuron_threshold(neuron_threshold_u1),
    .cntrl_status_csr(cntrl_status_csr_u1)
  );

  // Output layer
  neuron_layer #(
    .INPUT_COUNT(HIDDEN_SIZE),
    .NEURON_COUNT(OUTPUT_SIZE)
  ) output_layer (
    .clk(clk_cnt),
    .rst_n(rst_clk_cnt_n),
    .input_spikes(hidden_spikes),           // [INPUT_COUNT-1:0]
    .weight_reg(weight_reg_u1),             // [INPUT_COUNT-1:0][NEURON_COUNT-1:0]
    .spike_threshold(spike_threshold_u1),   // [INPUT_COUNT-1:0][NEURON_COUNT-1:0]
    .neuron_threshold(neuron_threshold_u1), // [NEURON_COUNT-1:0]
    .leak_factor(leak_factor),
    .output_spikes(digit_spikes)            // [NEURON_COUNT-1:0]
  );

  // Both layer's CSR are programmed
  assign csr_load_done = cntrl_status_csr_u0[0] & cntrl_status_csr_u1[0];

endmodule