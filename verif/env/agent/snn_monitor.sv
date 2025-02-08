class snn_monitor extends uvm_monitor;
    virtual snn_interface vif;
    uvm_analysis_port #(snn_transaction) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            snn_transaction trans = snn_transaction::type_id::create("trans");
            trans.spikes_in = vif.spikes_in;
            trans.spikes_out = vif.spikes_out;
            ap.write(trans);
        end
    endtask
endclass