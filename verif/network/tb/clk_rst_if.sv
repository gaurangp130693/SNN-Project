// Filename: clk_rst_if.sv
// Author: Gaurang Pandey
// Description: Interface for Clock and Reset Generation for DUT

interface clk_rst_if ();
    logic clk;
    logic rst_n;

    // Clock generation (100 MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // Reset generation
    initial begin
        rst_n = 0;
        #100;
        rst_n = 1;
    end

endinterface