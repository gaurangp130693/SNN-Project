//==============================================================================
//  File name: neuron_pkg.sv
//  Author : Gaurang Pandey
//  Description: Package file containing parameters for synapse module
//==============================================================================

// Parameters and types
package neuron_pkg;
  parameter int MEMBRANE_WIDTH = 16;  // Membrane potential width
  parameter int WEIGHT_WIDTH = 8;     // Synaptic weight width
  parameter int LEAK_WIDTH = 8;       // Leak factor width
  parameter int THRESHOLD = 16'h8000;  // Firing threshold
  parameter int RESET_VAL = 16'h0000;  // Reset value after spike

  typedef logic [MEMBRANE_WIDTH-1:0] membrane_t;
  typedef logic [WEIGHT_WIDTH-1:0] weight_t;
  typedef logic [LEAK_WIDTH-1:0] leak_t;
endpackage