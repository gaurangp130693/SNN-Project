
module synapse #(
    parameter W = 8,
    parameter V_WIDTH = 16
)(
    input logic clk,
    input logic rst,
    input logic spike_in,
    input logic signed [W-1:0] weight,
    output logic signed [V_WIDTH-1:0] weighted_output
);
    assign weighted_output = spike_in ? weight : 0;
endmodule