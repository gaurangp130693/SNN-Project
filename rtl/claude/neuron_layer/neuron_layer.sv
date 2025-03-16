//==============================================================================
//  File name: neuron_layer.sv
//  Author : Gaurang Pandey 
//  Description: Layer module with fixed spike aggregation
//==============================================================================

module neuron_layer
  import network_pkg::*;
  import neuron_pkg::*;
#(
  parameter int INPUT_COUNT,
  parameter int NEURON_COUNT
)(
  input  logic clk,
  input  logic rst_n,
  input  logic input_spikes [INPUT_COUNT-1:0],
  input  logic [7:0] leak_factor,
  input  weight_t weight_reg[INPUT_COUNT-1:0][NEURON_COUNT-1:0],
  input  weight_t spike_threshold[INPUT_COUNT-1:0][NEURON_COUNT-1:0],
  input  logic [15:0] neuron_threshold [NEURON_COUNT-1:0],
  output logic output_spikes [NEURON_COUNT-1:0]
);

  // Synaptic connections
  logic weighted_spikes [INPUT_COUNT-1:0][NEURON_COUNT-1:0];
  logic aggregated_inputs [NEURON_COUNT-1:0];

  // Generate synapses and neurons
  for (genvar i = 0; i < NEURON_COUNT; i++) begin : gen_neurons
    // Temporary array for aggregation
    logic [INPUT_COUNT-1:0] temp_spikes;

    for (genvar j = 0; j < INPUT_COUNT; j++) begin : gen_synapses
      synapse synapse_inst (
        .clk(clk),
        .rst_n(rst_n),
        .pre_spike(input_spikes[j]),
        .weight(weight_reg[j][i]),
        .threshold(spike_threshold[j][i]),
        .weighted_spike(weighted_spikes[j][i])
      );

      // Assign to temporary array for reduction
      assign temp_spikes[j] = weighted_spikes[j][i];
    end

    // Perform reduction OR on the temporary array
    assign aggregated_inputs[i] = |temp_spikes;

    lif_neuron neuron_inst (
      .clk(clk),
      .rst_n(rst_n),
      .input_spike(aggregated_inputs[i]),
      .leak_factor(leak_factor),
      .threshold(neuron_threshold[i]),
      .output_spike(output_spikes[i])
    );
  end
endmodule