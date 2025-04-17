//==============================================================================
//  File name: snn_base_sequence.sv
//  Author : Gaurang Pandey
//  Description: Base sequence for SNN UVM testbench
//==============================================================================

class snn_base_sequence extends uvm_sequence;

  // Registration with factory
  `uvm_object_utils(snn_base_sequence)
  `uvm_declare_p_sequencer(snn_vseqr)

  snn_reg_block_c reg_model;
  virtual apb_if apb_vif;

  // Constructor
  function new(string name = "snn_base_sequence");
    super.new(name);
    if ((!uvm_config_db#(snn_reg_block_c#())::get( uvm_root::get(), "*", "reg_model", reg_model)) || (reg_model == null))
      `uvm_fatal(get_type_name(), "reg_model is not set")

    if (!uvm_config_db#(virtual apb_if)::get(uvm_root::get(), "*", "vif", apb_vif)) begin
      `uvm_fatal(get_type_name(), "apb_if is not set!")
    end
  endfunction

  // Body task
  virtual task body();
    // Base sequence is empty
  endtask

endclass