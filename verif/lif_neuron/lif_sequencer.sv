//==============================================================================
//  File name: lif_sequencer.sv
//  Author    : Gaurang Pandey
//  Description: Sequencer for LIF neuron. Coordinates between sequence and driver.
//==============================================================================

`ifndef LIF_SEQUENCER_SV
`define LIF_SEQUENCER_SV

class lif_sequencer extends uvm_sequencer #(lif_txn);

    `uvm_component_utils(lif_sequencer)

    function new(string name = "lif_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction

endclass : lif_sequencer

`endif