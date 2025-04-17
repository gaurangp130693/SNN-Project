//==============================================================================
//  File name: snn_sanity_test.sv
//  Author : Gaurang Pandey
//  Description: Top-level UVM test for SNN
//==============================================================================

class snn_sanity_test extends uvm_test;

  `uvm_component_utils(snn_sanity_test)

  snn_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = snn_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    snn_init_sequence init_seq;
    phase.raise_objection(this);
    init_seq = snn_init_sequence::type_id::create("init_seq");
    init_seq.start(env.snn_vseqr_h);
    phase.drop_objection(this);
  endtask

endclass