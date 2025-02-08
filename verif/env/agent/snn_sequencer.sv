class snn_sequencer extends uvm_sequencer #(snn_sequence_item);
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass