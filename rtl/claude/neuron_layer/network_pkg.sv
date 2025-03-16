//==============================================================================
//  File name: network_package.sv
//  Author : Gaurang Pandey
//  Description: Package for parametes in neuron_layer related to network
//
//
//==============================================================================

// Network parameters
package network_pkg;

  parameter int INPUT_SIZE = 4;    // 2x2 image = 4 inputs
  parameter int HIDDEN_SIZE = 2;   // First hidden layer neurons
  parameter int OUTPUT_SIZE = 1;   // 10 outputs (0-9)

  // Input processing parameters
  parameter int PIXEL_WIDTH = 8;    // 8-bit pixel values
  parameter int SPIKE_WINDOW = 16;  // Time window for rate coding
endpackage