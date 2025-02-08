class snn_driver extends uvm_driver #(snn_sequence_item);
    virtual snn_interface vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            vif.spikes_in <= req.spikes_in;
            seq_item_port.item_done();
        end
    endtask
endclass