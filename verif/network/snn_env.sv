//==============================================================================
//  File name: snn_env.sv
//  Author : Gaurang Pandey
//  Description: Environment for SNN UVM testbench
//==============================================================================

class snn_env extends uvm_env;

  `uvm_component_utils(snn_env)

  snn_agent agent;
  snn_scoreboard scoreboard;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    agent = snn_agent::type_id::create("agent", this);
    scoreboard = snn_scoreboard::type_id::create("scoreboard", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    agent.monitor.ap.connect(scoreboard.analysis_export);
  endfunction

endclass
