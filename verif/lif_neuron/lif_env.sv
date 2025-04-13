//==============================================================================
//  File name: lif_env.sv
//  Author    : Gaurang Pandey
//  Description: Environment for LIF neuron. Connects agent and scoreboard.
//==============================================================================

`ifndef LIF_ENV_SV
`define LIF_ENV_SV

class lif_env extends uvm_env;

    `uvm_component_utils(lif_env)

    lif_agent       agent;
    lif_scoreboard  scoreboard;

    function new(string name = "lif_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent      = lif_agent::type_id::create("agent", this);
        scoreboard = lif_scoreboard::type_id::create("scoreboard", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        agent.monitor.mon_ap.connect(scoreboard.sb_ap);
    endfunction

endclass : lif_env

`endif
