//==============================================================================
//  File name: snn_radial_sequence_test.sv
//  Author : Gaurang Pandey
//  Description: This sequence generates radial patterns on the SNN.
//==============================================================================

class snn_radial_sequence_test extends snn_base_test;
  `uvm_component_utils(snn_radial_sequence_test)

  // Constructor
  function new(string name = "snn_radial_sequence_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  task run_phase(uvm_phase phase);
    snn_radial_sequence seq_h;
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
    seq_h = snn_radial_sequence::type_id::create("seq_h");
    seq_h.start(env.snn_vseqr_h.snn_seqr);
    `uvm_info(get_type_name(), "SNN Pattern Seqence Starts...", UVM_LOW)

    `uvm_info(get_type_name(), "Test sequence completed", UVM_LOW)
    phase.drop_objection(this);
  endtask

endclass