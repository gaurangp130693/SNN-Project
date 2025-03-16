//==============================================================================
//  File name: network_package.sv
//  Author : Gaurang Pandey
//  Description: Package file for parameters of neural network module
//==============================================================================

// Network parameters
package network_pkg;

  parameter int CLK_PERIOD = 10; // 10ns clock period (100 MHz)
  parameter int CLOCK_DIVIDER_VAL = 8;

  parameter int INPUT_SIZE = 16;    // 2x2 image = 4 inputs
  parameter int HIDDEN_SIZE = 8;   // First hidden layer neurons
  parameter int OUTPUT_SIZE = 4;   // 10 outputs (0-9)

  // Input processing parameters
  parameter int PIXEL_WIDTH = 8;    // 8-bit pixel values
  parameter int SPIKE_WINDOW = 16;  // Time window for rate coding

  //CSR Base Addresses
  parameter int LAYER_WEIGHT_BASE_ADDR_U0 = 16'h0000;
  parameter int LAYER_SPIKE_THRESH_BASE_ADDR_U0 = 16'h1000;
  parameter int LAYER_NEURON_THRESH_BASE_ADDR_U0 = 16'h2000;
  parameter int CONTROL_STATUS_BASE_ADDR_U0 = 16'h3000;

  parameter int LAYER_WEIGHT_BASE_ADDR_U1 = 16'h6000;
  parameter int LAYER_SPIKE_THRESH_BASE_ADDR_U1 = 16'h7000;
  parameter int LAYER_NEURON_THRESH_BASE_ADDR_U1 = 16'h8000;
  parameter int CONTROL_STATUS_BASE_ADDR_U1 = 16'h9000;
endpackage