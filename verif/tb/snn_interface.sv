interface snn_interface #(
    parameter INPUT_NEURONS = 8,
    parameter OUTPUT_NEURONS = 4
)(
    input logic clk,
    input logic rst,
    input logic [INPUT_NEURONS-1:0] spikes_in,
    output logic [OUTPUT_NEURONS-1:0] spikes_out
);
    logic signed [7:0] weights [15:0][7:0];
endinterface