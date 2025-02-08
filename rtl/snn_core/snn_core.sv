// Name : Gaurang Pandey
// File : snn_core.sv
// Description : 
//


module snn_core #(
    parameter N = 16,
    parameter W = 8,
    parameter V_WIDTH = 16
)(
    input logic clk,
    input logic rst,
    input logic signed [W-1:0] weights [N-1:0][N-1:0],
    output logic spikes [N-1:0]
);
    logic signed [V_WIDTH-1:0] neuron_inputs [N-1:0];
    logic signed [V_WIDTH-1:0] synapse_outputs [N-1:0][N-1:0];

    // Instantiate neurons
    genvar i;
    generate
        for (i = 0; i < N; i++) begin : neuron_gen
            neuron #(.V_WIDTH(V_WIDTH)) neuron_inst (
                .clk(clk),
                .rst(rst),
                .weighted_input(neuron_inputs[i]),
                .spike(spikes[i])
            );
        end
    endgenerate

    // Instantiate synapses
    genvar j;
    generate
        for (i = 0; i < N; i++) begin : synapse_gen_row
            for (j = 0; j < N; j++) begin : synapse_gen_col
                synapse #(.W(W), .V_WIDTH(V_WIDTH)) synapse_inst (
                    .clk(clk),
                    .rst(rst),
                    .spike_in(spikes[j]),
                    .weight(weights[i][j]),
                    .weighted_output(synapse_outputs[i][j])
                );
            end
        end
    endgenerate

    // Accumulate synapse outputs for each neuron
    integer k;
    always_comb begin
        for (i = 0; i < N; i++) begin
            neuron_inputs[i] = 0;
            for (k = 0; k < N; k++) begin
                neuron_inputs[i] += synapse_outputs[i][k];
            end
        end
    end
endmodule
