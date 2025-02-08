
module lif_neuron #(
    parameter WIDTH = 16,         // Width of the potential
    parameter THRESHOLD = 1000,   // Threshold value
    parameter LEAK_FACTOR = 2     // Leakage factor (1/τ)
)(
    input logic clk,
    input logic rst,
    input logic signed [WIDTH-1:0] input_current,
    output logic spike
);
    logic signed [WIDTH-1:0] membrane_potential;
    logic signed [WIDTH-1:0] leakage;

    // Leakage calculation
    assign leakage = membrane_potential >>> LEAK_FACTOR;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            membrane_potential <= 0;
            spike <= 0;
        end else begin
            // Integrate input current and apply leakage
            membrane_potential <= membrane_potential + input_current - leakage;

            // Check for threshold crossing
            if (membrane_potential >= THRESHOLD) begin
                spike <= 1;                 // Generate spike
                membrane_potential <= 0;    // Reset potential
            end else begin
                spike <= 0;
            end
        end
    end
endmodule
