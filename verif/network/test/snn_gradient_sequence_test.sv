//==============================================================================
//  File name: snn_gradient_sequence_test.sv
//  Author : Gaurang Pandey
//  Description: 
//==============================================================================
class snn_gradient_sequence_test extends snn_base_test;

  // Constructor
  function new(string name = "snn_gradient_sequence_test");
    super.new(name);
  endfunction

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  task run_phase(uvm_phase phase);
    snn_reg_bitbash_sequence bitbash_seq;
    phase.raise_objection(this);
    bitbash_seq = snn_reg_bitbash_sequence::type_id::create("bitbash_seq");
    bitbash_seq.start(env.snn_vseqr_h);
    phase.drop_objection(this);
  endtask

endclass