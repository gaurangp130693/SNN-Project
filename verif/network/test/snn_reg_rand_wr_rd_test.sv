//==============================================================================
//  File name: snn_reg_rand_wr_rd_test.sv
//  Author : Gaurang Pandey
//  Description: Top-level UVM test for SNN
//==============================================================================

class snn_reg_rand_wr_rd_test extends snn_base_test;

  `uvm_component_utils(snn_reg_rand_wr_rd_test)

  snn_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = snn_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    snn_reg_rand_sequence reg_wr_rd_seq;
    phase.raise_objection(this);
    `uvm_info(get_type_name(), "Starting test sequence", UVM_MEDIUM)
    reg_wr_rd_seq = snn_reg_rand_sequence::type_id::create("reg_wr_rd_seq");
    reg_wr_rd_seq.start(p_sequencer);
    `uvm_info(get_type_name(), "Test sequence completed", UVM_MEDIUM)
    phase.drop_objection(this);
  endtask

endclass