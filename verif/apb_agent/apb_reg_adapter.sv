//==============================================================================
//  File name: apb_reg_adapter.sv
//  Author : Gaurang Pandey 
//  Description: UVM APB register adapter
//==============================================================================

class apb_reg_adapter extends uvm_reg_adapter;
  `uvm_object_utils(apb_reg_adapter)
  
  function new(string name = "apb_reg_adapter");
    super.new(name);
  endfunction
  
  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    apb_transaction apb_tx = apb_transaction::type_id::create("apb_tx");
    
    // Convert register operation to APB transaction
    apb_tx.pwrite = (rw.kind == UVM_WRITE) ? 1'b1 : 1'b0;
    apb_tx.paddr = rw.addr;
    apb_tx.operation = apb_tx.pwrite ? APB_WRITE : APB_READ;
    
    if (apb_tx.pwrite)
      apb_tx.pwdata = rw.data;
    
    `uvm_info(get_type_name(), $sformatf("Converted reg op to APB: %s", apb_tx.convert2string()), UVM_HIGH)
    
    return apb_tx;
  endfunction
  
  virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    apb_transaction apb_tx;
    
    if (!$cast(apb_tx, bus_item)) begin
      `uvm_fatal(get_type_name(), "Failed to cast bus_item to apb_transaction")
      return;
    end
    
    // Convert APB transaction to register operation
    rw.kind = apb_tx.pwrite ? UVM_WRITE : UVM_READ;
    rw.addr = apb_tx.paddr;
    rw.data = apb_tx.pwrite ? apb_tx.pwdata : apb_tx.prdata;
    rw.status = UVM_IS_OK;
    
    `uvm_info(get_type_name(), $sformatf("Converted APB to reg op: %s", apb_tx.convert2string()), UVM_HIGH)
  endfunction
endclass