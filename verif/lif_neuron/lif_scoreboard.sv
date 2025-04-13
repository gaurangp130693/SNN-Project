//==============================================================================
//  File name: lif_scoreboard.sv
//  Author    : Gaurang Pandey
//  Description: Scoreboard for LIF neuron. Compares actual output with expected.
//==============================================================================

`ifndef LIF_SCOREBOARD_SV
`define LIF_SCOREBOARD_SV

class lif_scoreboard extends uvm_component;

    `uvm_component_utils(lif_scoreboard)

    uvm_analysis_imp #(lif_txn, lif_scoreboard) sb_ap;

    function new(string name = "lif_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        sb_ap = new("sb_ap", this);
    endfunction

    virtual function void write(lif_txn txn);
        // Basic check: If enabled and input_spike active, expect output_spike at some point
        if (txn.enable && txn.input_spike) begin
            if (!txn.output_spike)
                `uvm_error("SCOREBOARD", $sformatf("Expected output_spike HIGH but got LOW. txn: %s", txn.convert2string()))
        end
    endfunction

endclass : lif_scoreboard

`endif
