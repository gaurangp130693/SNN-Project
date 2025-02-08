
module snn_core #(
    parameter INPUT_NEURONS = 8,
    parameter HIDDEN_NEURONS = 16,
    parameter OUTPUT_NEURONS = 4,
    parameter W = 8,
    parameter V_WIDTH = 16
)(
    input logic clk,
    input logic rst,
    input logic spikes_in [INPUT_NEURONS-1:0],
    input logic signed [W-1:0] weights_input_to_hidden [HIDDEN_NEURONS-1:0][INPUT_NEURONS-1:0],
    input logic signed [W-1:0] weights_hidden_to_output [OUTPUT_NEURONS-1:0][HIDDEN_NEURONS-1:0],
    output logic spikes_out [OUTPUT_NEURONS-1:0]
);
    logic spikes_hidden [HIDDEN_NEURONS-1:0];

    // Input to Hidden Layer
    layer #(
        .N_NEURONS(HIDDEN_NEURONS),
        .PREV_NEURONS(INPUT_NEURONS),
        .W(W),
        .V_WIDTH(V_WIDTH)
    ) input_to_hidden_layer (
        .clk(clk),
        .rst(rst),
        .spikes_in(spikes_in),
        .weights(weights_input_to_hidden),
        .spikes_out(spikes_hidden)
    );

    // Hidden to Output Layer
    layer #(
        .N_NEURONS(OUTPUT_NEURONS),
        .PREV_NEURONS(HIDDEN_NEURONS),
        .W(W),
        .V_WIDTH(V_WIDTH)
    ) hidden_to_output_layer (
        .clk(clk),
        .rst(rst),
        .spikes_in(spikes_hidden),
        .weights(weights_hidden_to_output),
        .spikes_out(spikes_out)
    );
endmodule
