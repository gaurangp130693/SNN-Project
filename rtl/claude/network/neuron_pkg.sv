//==============================================================================
//  File name: neuron_pkg.sv
//  Author : Gaurang Pandey
//  Description: Package file for parameters of lif_neuron module
//==============================================================================

// Parameters and types
package neuron_pkg;
  parameter int MEMBRANE_WIDTH = 32;  // Membrane potential width
  parameter int WEIGHT_WIDTH = 32;     // Synaptic weight width
  parameter int LEAK_WIDTH = 8;       // Leak factor width
  parameter int THRESHOLD = 32'h00008000;  // Firing threshold
  parameter int RESET_VAL = 32'h00000000;  // Reset value after spike

  typedef logic [MEMBRANE_WIDTH-1:0] membrane_t;
  typedef logic [WEIGHT_WIDTH-1:0] weight_t;
  typedef logic [LEAK_WIDTH-1:0] leak_t;
endpackage