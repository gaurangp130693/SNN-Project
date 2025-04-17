//==============================================================================
//  File name: snn_base_test.sv
//  Author : Gaurang Pandey
//  Description: Top-level UVM test for SNN
//==============================================================================

class snn_base_test extends uvm_test;

  `uvm_component_utils(snn_base_test)

  snn_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = snn_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    #1000ns;
    phase.drop_objection(this);
  endtask

endclass
