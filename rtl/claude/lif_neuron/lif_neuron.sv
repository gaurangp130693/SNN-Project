//==============================================================================
//  File name: lif_neuron.sv
//  Author : Gaurang Pandey
//  Description: RTL model of lif neuron
//  This module receives input spike, integrate it and generate output spikes
//  based on threshold value
//==============================================================================

module lif_neuron
  import neuron_pkg::*;
(
  input  logic      clk,
  input  logic      rst_n,
  input  logic      input_spike,  // Input spike from synapse
  input  leak_t     leak_factor,  // Configurable leak factor
  input  weight_t   threshold,    // Threshold for generating spikes
  output logic      output_spike  // Output spike when threshold is reached
);

  membrane_t potential_reg;
  logic      spike_reg;

  // Membrane potential update
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      potential_reg <= RESET_VAL;
      spike_reg <= 1'b0;
    end else begin
      if (potential_reg >= threshold) begin
        // Fire spike and reset potential
        potential_reg <= RESET_VAL;
        spike_reg <= 1'b1;
      end else begin
        // Calculate next potential combining both spike and leak
        potential_reg <= potential_reg +
                        (input_spike ? (threshold >> 2) : 0) -
                        leak_factor;
        spike_reg <= 1'b0;
      end
    end
  end

  assign output_spike = spike_reg;

endmodule