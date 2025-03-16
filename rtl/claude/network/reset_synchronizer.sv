//==============================================================================
//  File name: reset_synchronizer.sv
//  Author : Gaurang Pandey
//  Description: Reset Synchronizer using 2FF
//==============================================================================

module reset_synchronizer (
    input  logic clk,          // Destination clock domain
    input  logic enable,       // output enable
    input  logic rst_n_async,  // Asynchronous active-low reset from clk1 domain
    output logic rst_n_sync    // Synchronized active-low reset in clk2 domain
);

    // Two-stage synchronizer registers
    logic rst_n_ff1, rst_n_ff2;

    always_ff @(posedge clk or negedge rst_n_async) begin
        if (!rst_n_async) begin
            rst_n_ff1 <= 1'b0;
            rst_n_ff2 <= 1'b0;
        end else begin
            rst_n_ff1 <= 1'b1;
            rst_n_ff2 <= rst_n_ff1;
        end
    end

    // Assign synchronized reset
    assign rst_n_sync = enable ? rst_n_ff2 : 1'b0;

endmodule