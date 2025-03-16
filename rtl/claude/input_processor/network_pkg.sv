//==============================================================================
//  File name: network_package.sv
//  Author : Gaurang Pandey
//  Description: Package file for input_processor parameters
//==============================================================================

// Network parameters
package network_pkg;

  parameter int INPUT_SIZE = 4;    // 8x8 image = 64 inputs
  parameter int HIDDEN_SIZE = 2;   // First hidden layer neurons
  parameter int OUTPUT_SIZE = 1;   // 10 outputs (0-9)

  // Input processing parameters
  parameter int PIXEL_WIDTH = 8;    // 8-bit pixel values
  parameter int SPIKE_WINDOW = 16;  // Time window for rate coding
endpackage