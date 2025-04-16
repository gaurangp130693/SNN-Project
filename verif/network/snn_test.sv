//==============================================================================
//  File name: snn_test.sv
//  Author : Gaurang Pandey
//  Description: Top-level UVM test for SNN
//==============================================================================

class snn_test extends uvm_test;

  `uvm_component_utils(snn_test)

  snn_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = snn_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    snn_init_sequence seq_init;
    snn_pixel_sequence seq_pixel;

    phase.raise_objection(this);

    seq_init = snn_init_sequence::type_id::create("seq_init");
    seq_init.start(env.agent.sequencer);

    seq_pixel = snn_pixel_sequence::type_id::create("seq_pixel");
    seq_pixel.start(env.agent.sequencer);
    phase.drop_objection(this);
  endtask

endclass
