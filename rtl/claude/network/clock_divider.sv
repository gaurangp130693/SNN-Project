//==============================================================================
//  File name: clock_divider.sv
//  Author : Gaurang Pandey
//  Description: Clock Divider Module
//==============================================================================

module clock_divider #(
    parameter int DIV_FACTOR = 4  // Clock division factor (must be even)
)(
    input  logic clk_in,          // Input clock
    input  logic rst_n,           // Active-low reset
    output logic clk_out          // Divided clock output
);

    logic [31:0] counter;          // Counter to divide clock

    always_ff @(posedge clk_in or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            clk_out <= 0;
        end else begin
            if (counter == (DIV_FACTOR / 2) - 1) begin
                clk_out <= ~clk_out;  // Toggle output clock
                counter <= 0;         // Reset counter
            end else begin
                counter <= counter + 1;
            end
        end
    end

endmodule