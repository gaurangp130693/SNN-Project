//==============================================================================
//  File name: lif_monitor.sv
//  Author    : Gaurang Pandey
//  Description: Monitor for LIF neuron. Captures inputs and outputs for scoreboard.
//==============================================================================

`ifndef LIF_MONITOR_SV
`define LIF_MONITOR_SV

class lif_monitor extends uvm_component;

    `uvm_component_utils(lif_monitor)

    virtual lif_if vif;

    uvm_analysis_port #(lif_txn) mon_ap;

    function new(string name = "lif_monitor", uvm_component parent = null);
        super.new(name, parent);
        mon_ap = new("mon_ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual lif_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "Virtual interface not set in monitor")
    endfunction

    virtual task run_phase(uvm_phase phase);
        lif_txn txn;

        forever begin
            @(posedge vif.clk);

            txn = lif_txn::type_id::create("txn");
            txn.enable             = vif.enable;
            txn.input_spike        = vif.input_spike;
            txn.neuron_config      = vif.neuron_config;
            txn.output_spike       = vif.output_spike;
            txn.membrane_potential = vif.membrane_potential;

            mon_ap.write(txn);
        end
    endtask

endclass : lif_monitor

`endif
