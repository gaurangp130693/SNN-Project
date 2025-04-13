//==============================================================================
//  File name: lif_sequence.sv
//  Author    : Gaurang Pandey
//  Description: Sequence to generate input stimulus for LIF neuron
//==============================================================================

`ifndef LIF_SEQUENCE_SV
`define LIF_SEQUENCE_SV

class lif_sequence extends uvm_sequence #(lif_txn);

    `uvm_object_utils(lif_sequence)

    function new(string name = "lif_sequence");
        super.new(name);
    endfunction

    virtual task body();
        lif_txn txn;

        repeat (10) begin // Send 10 transactions
            txn = lif_txn::type_id::create("txn");
            assert(txn.randomize());
            start_item(txn);
            finish_item(txn);
        end
    endtask

endclass : lif_sequence

`endif
