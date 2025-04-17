//==============================================================================
//  File name: apb_reg_predictor.sv
//  Description: UVM APB register predictor
//==============================================================================

class apb_reg_predictor extends uvm_reg_predictor#(apb_transaction);
  `uvm_component_utils(apb_reg_predictor)
  
  function new(string name = "apb_reg_predictor", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  // Override to customize if needed
  virtual function void write(apb_transaction t);
    // Skip prediction for transactions that don't have pready asserted
    // as they aren't completing successfully
    if (!t.pready) begin
      `uvm_info(get_type_name(), 
                $sformatf("Skipping prediction for transaction without pready: %s", 
                         t.convert2string()), UVM_HIGH)
      return;
    end
    
    // For read transactions, we need the prdata to update the model
    if (!t.pwrite) begin
      `uvm_info(get_type_name(), 
                $sformatf("Predicting READ: addr=0x%0h, data=0x%0h", 
                         t.paddr, t.prdata), UVM_HIGH)
    } else begin
      `uvm_info(get_type_name(), 
                $sformatf("Predicting WRITE: addr=0x%0h, data=0x%0h", 
                         t.paddr, t.pwdata), UVM_HIGH)
    end
    
    // Call parent method to update the register model
    super.write(t);
  endfunction
endclass