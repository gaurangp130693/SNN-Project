//==============================================================================
//  File name: snn_reset_test.sv
//  Author : Gaurang Pandey
//  Description: This sequence generates random patterns on the SNN.
//==============================================================================

class snn_reset_test extends snn_base_test;
  `uvm_component_utils(snn_reset_test)

  virtual clk_rst_if clk_rst_vif;

  // Constructor
  function new(string name = "snn_reset_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual clk_rst_if)::get(this, "", "vif", clk_rst_vif))
      `uvm_fatal("NOVIF", "Virtual clk_rst_if interface not found")
  endfunction

  task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Starting test sequence", UVM_LOW)
    phase.raise_objection(this);

    gen_traffic();
    gen_reset();
    gen_traffic();

    `uvm_info(get_type_name(), "Test sequence completed", UVM_LOW)
    phase.drop_objection(this);
  endtask

  task gen_traffic();
    snn_random_sequence seq_h;
    snn_reg_rand_sequence reg_wr_rd_seq;
    snn_init_sequence init_seq;

    `uvm_info(get_type_name(), "Register Programming Seqence Starts...", UVM_LOW)
    reg_wr_rd_seq = snn_reg_rand_sequence::type_id::create("reg_wr_rd_seq");
    reg_wr_rd_seq.start(env.snn_vseqr_h);
    `uvm_info(get_type_name(), "Register Programming Seqence Ends", UVM_LOW)

    `uvm_info(get_type_name(), "Initialization Seqence Starts...", UVM_LOW)
    init_seq = snn_init_sequence::type_id::create("init_seq");
    init_seq.start(env.snn_vseqr_h);
    `uvm_info(get_type_name(), "Initialization Seqence Ends", UVM_LOW)

    `uvm_info(get_type_name(), "SNN Pattern Seqence Starts...", UVM_LOW)
    seq_h = snn_random_sequence::type_id::create("seq_h");
    seq_h.start(env.snn_vseqr_h.snn_seqr);
    `uvm_info(get_type_name(), "SNN Pattern Seqence Starts...", UVM_LOW)

  endtask

  task gen_reset();
    clk_rst_vif.rst_n = 0;
    repeat(100) @(posedge clk_rst_vif.clk);
    clk_rst_vif.rst_n = 1;
  endtask

endclass