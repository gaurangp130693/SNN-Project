//==============================================================================
//  File name: snn_checkered_sequence_test.sv
//  Author : Gaurang Pandey
//  Description: This sequence generates random patterns on the SNN.
//==============================================================================

class snn_random_sequence_test extends snn_base_test;
  `uvm_component_utils(snn_random_sequence_test)

  // Constructor
  function new(string name = "snn_random_sequence_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  task run_phase(uvm_phase phase);
    snn_random_sequence seq_h;
    snn_reg_rand_sequence reg_wr_rd_seq;
    snn_init_sequence init_seq;
    snn_reg_layer1_sequence reg_layer1_seq;

    phase.raise_objection(this);

    `uvm_info(get_type_name(), "Starting test sequence", UVM_LOW)

    `uvm_info(get_type_name(), "Register Programming Seqence Starts...", UVM_LOW)
    reg_wr_rd_seq = snn_reg_rand_sequence::type_id::create("reg_wr_rd_seq");
    reg_wr_rd_seq.start(env.snn_vseqr_h);

    if(neuron_num != 'hFF) begin
      reg_layer1_seq = snn_reg_layer1_sequence::type_id::create("reg_layer1_seq");
      reg_layer1_seq.neuron_num = neuron_num;
      reg_layer1_seq.start(env.snn_vseqr_h);
    end

    `uvm_info(get_type_name(), "Register Programming Seqence Ends", UVM_LOW)

    `uvm_info(get_type_name(), "Initialization Seqence Starts...", UVM_LOW)
    init_seq = snn_init_sequence::type_id::create("init_seq");
    init_seq.start(env.snn_vseqr_h);
    `uvm_info(get_type_name(), "Initialization Seqence Ends", UVM_LOW)

    `uvm_info(get_type_name(), "SNN Pattern Seqence Starts...", UVM_LOW)
    seq_h = snn_random_sequence::type_id::create("seq_h");
    seq_h.start(env.snn_vseqr_h.snn_seqr);
    `uvm_info(get_type_name(), "SNN Pattern Seqence Starts...", UVM_LOW)

    `uvm_info(get_type_name(), "Test sequence completed", UVM_LOW)
    phase.drop_objection(this);
  endtask

endclass