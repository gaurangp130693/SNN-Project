// Name : Gaurang Pandey
// File : top.sv
// Description :
//


module top;
    logic clk, rst;
    snn_interface vif();

    // DUT instantiation
    snn_core dut (
        .clk(vif.clk),
        .rst(vif.rst),
        .spikes_in(vif.spikes_in),
        .spikes_out(vif.spikes_out)
    );

    // Clock generator
    initial clk = 0;
    always #5 clk = ~clk;

    // UVM run
    initial begin
        run_test("snn_test");
    end
endmodule

