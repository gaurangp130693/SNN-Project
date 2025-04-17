//============================================================================== 
//  File name: snn_sequence.sv 
//  Author : Gaurang Pandey 
//  Description: SNN initialization sequence
//==============================================================================

class snn_init_sequence extends snn_sequence;
  
  // Registration with factory
  `uvm_object_utils(snn_init_sequence)
  
  // Constructor
  function new(string name = "snn_test_sequence");
    super.new(name);
  endfunction
  
  // Body task - run initialization followed by pixel stimuli
  virtual task body();
    `uvm_info(get_type_name(), "Starting test sequence", UVM_MEDIUM)
    
    `uvm_info(get_type_name(), "Test sequence completed", UVM_MEDIUM)
  endtask
  
endclass