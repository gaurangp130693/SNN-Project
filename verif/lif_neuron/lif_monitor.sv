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

        `uvm_info("lif_monitor", "Starting run_phase...", UVM_LOW)
        forever begin
            @(posedge vif.clk);
            if(vif.rst_n == 1) begin
              txn = lif_txn::type_id::create("txn");
              txn.leak_factor        = vif.leak_factor;
              txn.input_spike        = vif.input_spike;
              txn.threshold          = vif.threshold;
              txn.output_spike       = vif.output_spike;

              mon_ap.write(txn);
            end
        end
    endtask

endclass : lif_monitor

`endif
