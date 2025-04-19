//==============================================================================
//  File name: snn_reg_bitbash_test.sv
//  Author : Gaurang Pandey
//  Description: Top-level UVM test for SNN
//==============================================================================

class snn_reg_bitbash_test extends snn_base_test;

  `uvm_component_utils(snn_reg_bitbash_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  task run_phase(uvm_phase phase);
    snn_reg_bitbash_sequence bitbash_seq;
    phase.raise_objection(this);
    bitbash_seq = snn_reg_bitbash_sequence::type_id::create("bitbash_seq");
    bitbash_seq.model = env.reg_model;
    bitbash_seq.start(env.snn_vseqr_h);
    phase.drop_objection(this);
  endtask

endclass