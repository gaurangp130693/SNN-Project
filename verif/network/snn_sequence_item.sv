//============================================================================== 
//  File name: snn_seq_item.sv 
//  Author : Gaurang Pandey 
//  Description: Sequence item for SNN UVM testbench
//==============================================================================

class snn_seq_item extends uvm_sequence_item;
  
  // Registration with factory
  `uvm_object_utils(snn_seq_item)
  
  typedef enum {PIXEL_INPUT, APB_WRITE, APB_READ} operation_t;
  
  // Operation type
  rand operation_t operation;
  
  // Transaction data
  rand snn_transaction trans;
  
  // Constraints
  constraint c_operation_dist {
    operation dist {
      PIXEL_INPUT := 3,
      APB_WRITE := 5,
      APB_READ := 2
    };
  }
  
  constraint c_apb_write {
    if (operation == APB_WRITE) {
      trans.pwrite == 1;
    }
  }
  
  constraint c_apb_read {
    if (operation == APB_READ) {
      trans.pwrite == 0;
    }
  }
  
  // Constructor
  function new(string name = "snn_seq_item");
    super.new(name);
    trans = new("trans");
  endfunction
  
  // Convert to string for debugging
  virtual function string convert2string();
    string s;
    s = super.convert2string();
    s = {s, $sformatf("\nOperation: %s", operation.name())};
    s = {s, $sformatf("\nTransaction: %s", trans.convert2string())};
    return s;
  endfunction
  
endclass