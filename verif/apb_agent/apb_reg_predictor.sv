//==============================================================================
//  File name: apb_reg_predictor.sv
//  Description: UVM APB register predictor
//==============================================================================

class apb_reg_predictor extends uvm_reg_predictor#(apb_transaction);
  `uvm_component_utils(apb_reg_predictor)
  
  function new(string name = "apb_reg_predictor", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
endclass