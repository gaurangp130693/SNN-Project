//==============================================================================
//  File name: lif_agent.sv
//  Author    : Gaurang Pandey
//  Description: Agent for LIF neuron. Instantiates driver, monitor, and sequencer.
//==============================================================================

`ifndef LIF_AGENT_SV
`define LIF_AGENT_SV

class lif_agent extends uvm_component;

    `uvm_component_utils(lif_agent)

    lif_driver    driver;
    lif_monitor   monitor;
    lif_sequencer sequencer;

    virtual lif_if vif;

    function new(string name = "lif_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual lif_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "Virtual interface not set in agent")

        driver     = lif_driver::type_id::create("driver", this);
        monitor    = lif_monitor::type_id::create("monitor", this);
        sequencer  = lif_sequencer::type_id::create("sequencer", this);

        uvm_config_db#(virtual lif_if)::set(this, "driver", "vif", vif);
        uvm_config_db#(virtual lif_if)::set(this, "monitor", "vif", vif);
    endfunction

    function void connect_phase(uvm_phase phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction

endclass : lif_agent

`endif
