//==============================================================================
//  File name: lif_txn.sv
//  Author    : Gaurang Pandey
//  Description: Transaction class for LIF neuron. Carries input config and spike.
//==============================================================================

`ifndef LIF_TXN_SV
`define LIF_TXN_SV

class lif_txn extends uvm_sequence_item;

    rand bit        enable;
    rand bit        input_spike;
    rand bit [15:0] threshold;
    rand bit [15:0] leak_factor;

    bit             output_spike;

    `uvm_object_utils(lif_txn)

    function new(string name = "lif_txn");
        super.new(name);
    endfunction

endclass : lif_txn

`endif
