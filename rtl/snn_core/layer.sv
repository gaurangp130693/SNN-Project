
module layer #(
    parameter N_NEURONS = 8,      // Number of neurons in the layer
    parameter PREV_NEURONS = 8,  // Number of neurons in the previous layer
    parameter W = 8,             // Weight width
    parameter V_WIDTH = 16       // Membrane potential width
)(
    input logic clk,
    input logic rst,
    input logic spikes_in [PREV_NEURONS-1:0],
    input logic signed [W-1:0] weights [N_NEURONS-1:0][PREV_NEURONS-1:0],
    output logic spikes_out [N_NEURONS-1:0]
);
    logic signed [V_WIDTH-1:0] neuron_inputs [N_NEURONS-1:0];
    logic signed [V_WIDTH-1:0] synapse_outputs [N_NEURONS-1:0][PREV_NEURONS-1:0];

    // Instantiate synapses
    genvar i, j;
    generate
        for (i = 0; i < N_NEURONS; i++) begin : synapse_gen_row
            for (j = 0; j < PREV_NEURONS; j++) begin : synapse_gen_col
                synapse #(.W(W), .V_WIDTH(V_WIDTH)) synapse_inst (
                    .clk(clk),
                    .rst(rst),
                    .spike_in(spikes_in[j]),
                    .weight(weights[i][j]),
                    .weighted_output(synapse_outputs[i][j])
                );
            end
        end
    endgenerate

    // Accumulate synapse outputs for each neuron
    integer k;
    always_comb begin
        for (i = 0; i < N_NEURONS; i++) begin
            neuron_inputs[i] = 0;
            for (k = 0; k < PREV_NEURONS; k++) begin
                neuron_inputs[i] += synapse_outputs[i][k];
            end
        end
    endgenerate

    // Instantiate neurons
    generate
        for (i = 0; i < N_NEURONS; i++) begin : neuron_gen
            neuron #(.V_WIDTH(V_WIDTH)) neuron_inst (
                .clk(clk),
                .rst(rst),
                .weighted_input(neuron_inputs[i]),
                .spike(spikes_out[i])
            );
        end
    endgenerate
endmodule
