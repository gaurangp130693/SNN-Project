//============================================================================== 
//  File name: apb_sequencer.sv 
//  Author : Gaurang Pandey 
//  Description: APB Sequencer for SNN UVM testbench
//==============================================================================

class apb_sequencer extends uvm_sequencer #(snn_seq_item);
  
  // Registration with factory
  `uvm_component_utils(apb_sequencer)
  
  // Constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "Build phase complete", UVM_HIGH)
  endfunction
  
endclass