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
        bit [15:0] threshold_value, leak_value;
        threshold_value = 16'h0004;
        repeat (16) begin
          repeat (100) begin // Send 10 transactions
              `uvm_info("lif_sequence", "sending transactions.", UVM_LOW)
              txn = lif_txn::type_id::create("txn");
              assert(txn.randomize() with { threshold == threshold_value; leak_factor == 0; });
              start_item(txn);
              finish_item(txn);
          end
         threshold_value = threshold_value << 1;
        end
    endtask

endclass : lif_sequence

`endif
