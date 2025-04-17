//==============================================================================
//  File name: snn_init_sequence.sv
//  Author : Gaurang Pandey
//  Description: SNN initialization sequence
//==============================================================================

class snn_init_sequence extends snn_base_sequence;

  // Registration with factory
  `uvm_object_utils(snn_init_sequence)

  // Constructor
  function new(string name = "snn_init_sequence");
    super.new(name);
  endfunction

  // Body task - run initialization followed by pixel stimuli
  virtual task body();
    snn_reg_sequence reg_seq;
    `uvm_info(get_type_name(), "Starting test sequence", UVM_MEDIUM)
    wait(apb_vif.rst_n == 1);
    reg_seq = snn_reg_sequence::type_id::create("reg_seq");
    reg_seq.start(p_sequencer);
    `uvm_info(get_type_name(), "Test sequence completed", UVM_MEDIUM)
  endtask

endclass