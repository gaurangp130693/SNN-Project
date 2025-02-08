
module neuron #(
    parameter V_WIDTH = 16,
    parameter THRESHOLD = 1000,
    parameter LEAK_FACTOR = 2
)(
    input logic clk,
    input logic rst,
    input logic signed [V_WIDTH-1:0] weighted_input,
    output logic spike
);
    logic signed [V_WIDTH-1:0] membrane_potential;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            membrane_potential <= 0;
            spike <= 0;
        end else begin
            membrane_potential <= membrane_potential + weighted_input - (membrane_potential >>> LEAK_FACTOR);
            if (membrane_potential >= THRESHOLD) begin
                spike <= 1;
                membrane_potential <= 0;
            end else begin
                spike <= 0;
            end
        end
    end
endmodule
