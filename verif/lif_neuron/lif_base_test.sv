//==============================================================================
//  File name: lif_base_test.sv
//  Author    : Gaurang Pandey
//  Description: Base test for LIF neuron with reset and test sequence
//==============================================================================

`ifndef LIF_BASE_TEST_SV
`define LIF_BASE_TEST_SV

class lif_base_test extends uvm_test;

    `uvm_component_utils(lif_base_test)

    lif_env        env;
    lif_sequence   seq;

    function new(string name = "lif_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = lif_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        // Reset Sequence
        `uvm_info("TEST", "Starting reset...", UVM_MEDIUM)
        env.agent.vif.rst <= 1;
        env.agent.vif.enable <= 0;
        repeat (5) @(posedge env.agent.vif.clk);
        env.agent.vif.rst <= 0;
        repeat (2) @(posedge env.agent.vif.clk);

        // Start test sequence
        `uvm_info("TEST", "Starting lif_sequence...", UVM_MEDIUM)
        seq = lif_sequence::type_id::create("seq");
        seq.start(env.agent.sequencer);

        phase.drop_objection(this);
    endtask

endclass : lif_base_test

`endif
