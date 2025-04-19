//==============================================================================
//  File name: snn_noise_pattern_sequence_test.sv
//  Author : Gaurang Pandey
//  Description: This sequence generates noise patterns on the SNN.
//==============================================================================

class snn_noise_pattern_sequence_test extends snn_base_test;

  // Constructor
  function new(string name = "snn_noise_pattern_sequence_test");
    super.new(name);
  endfunction

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  task run_phase(uvm_phase phase);
    snn_noise_pattern_sequence seq_h;
    snn_reg_rand_sequence reg_wr_rd_seq;
    snn_init_sequence init_seq;

    phase.raise_objection(this);

    `uvm_info(get_type_name(), "Starting test sequence", UVM_LOW)

    `uvm_info(get_type_name(), "Register Programming Seqence Starts...", UVM_LOW)
    reg_wr_rd_seq = snn_reg_rand_sequence::type_id::create("reg_wr_rd_seq");
    reg_wr_rd_seq.start(env.snn_vseqr_h);

    `uvm_info(get_type_name(), "Register Programming Seqence Ends", UVM_LOW)

    `uvm_info(get_type_name(), "Initialization Seqence Starts...", UVM_LOW)
    init_seq = snn_init_sequence::type_id::create("init_seq");
    init_seq.start(env.snn_vseqr_h);
    `uvm_info(get_type_name(), "Initialization Seqence Ends", UVM_LOW)
    
    `uvm_info(get_type_name(), "SNN Pattern Seqence Starts...", UVM_LOW)
    seq_h = snn_noise_pattern_sequence::type_id::create("seq_h");
    seq_h.start(env.snn_vseqr_h.snn_seqr);
    `uvm_info(get_type_name(), "SNN Pattern Seqence Starts...", UVM_LOW)

    `uvm_info(get_type_name(), "Test sequence completed", UVM_LOW)
    phase.drop_objection(this);
  endtask

endclass