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

  virtual task body();
    uvm_status_e status;
    uvm_reg_data_t data;

    super.body();

    // Write to control status register, bit-0 to enable the SNN
    data = '1;
    reg_model.layer0_block.control_status_reg.write(status, data);
    reg_model.layer1_block.control_status_reg.write(status, data);

    reg_model.layer0_block.control_status_reg.read(status, data);
    reg_model.layer1_block.control_status_reg.read(status, data);   
  endtask

endclass