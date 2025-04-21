//==============================================================================
//  File name: snn_base_test.sv
//  Author : Gaurang Pandey
//  Description: Top-level UVM test for SNN
//==============================================================================

class snn_base_test extends uvm_test;

  `uvm_component_utils(snn_base_test)

  snn_env env;
  int neuron_num;
  bit scb_en;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    if ($value$plusargs("NEURON_NUM=%0d", neuron_num)) begin
      `uvm_info(get_type_name(), $sformatf("Selected Output NEURON_NUM=%0d", neuron_num), UVM_LOW)
      if(neuron_num == 0) neuron_num = 'hFF;
    end
    if ($value$plusargs("SCB_EN=%0d", scb_en)) begin
      `uvm_info(get_type_name(), $sformatf("Scoreboard Enabled"), UVM_LOW)
    end
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = snn_env::type_id::create("env", this);
    env.scb_en = scb_en;
    env.neuron_num = neuron_num;
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    #1000ns;
    phase.drop_objection(this);
  endtask

endclass