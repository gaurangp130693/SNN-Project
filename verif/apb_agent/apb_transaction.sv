//============================================================================== 
//  File name: apb_types.sv 
//  Author : Gaurang Pandey 
//  Description: Definition of APB transactions
//==============================================================================

  // APB Transaction class for sequence items
  class apb_transaction extends uvm_sequence_item;
    // Registration with factory
    `uvm_object_utils(apb_transaction)
    
    // APB transaction fields
    rand bit          pwrite;    // 0: Read, 1: Write
    rand bit [31:0]   paddr;     // APB address
    rand bit [31:0]   pwdata;    // Write data
    bit [31:0]        prdata;    // Read data (not randomized)
    bit               pready;    // Slave ready signal
    
    // Operation type
    rand apb_operation_t operation;
    
    // Constructor
    function new(string name = "apb_transaction");
      super.new(name);
    endfunction
    
    // Constraints
    constraint addr_alignment {
      paddr[1:0] == 2'b00;  // Word-aligned addresses
    }
    
    constraint op_constraints {
      pwrite == (operation == APB_WRITE);
    }
    
    // Convert to string for debug
    virtual function string convert2string();
      return $sformatf("APB %s: addr=0x%0h, data=0x%0h, ready=%0b",
                      pwrite ? "WRITE" : "READ", 
                      paddr,
                      pwrite ? pwdata : prdata,
                      pready);
    endfunction
    
    // Compare transactions
    virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
      apb_transaction t;
      
      if(!$cast(t, rhs))
        return 0;
        
      return (super.do_compare(rhs, comparer) &&
              pwrite == t.pwrite &&
              paddr == t.paddr &&
              (pwrite ? (pwdata == t.pwdata) : (prdata == t.prdata)));
    endfunction
    
    // Copy transaction
    virtual function void do_copy(uvm_object rhs);
      apb_transaction t;
      
      if(!$cast(t, rhs))
        return;
        
      super.do_copy(rhs);
      pwrite = t.pwrite;
      paddr = t.paddr;
      pwdata = t.pwdata;
      prdata = t.prdata;
      pready = t.pready;
      operation = t.operation;
    endfunction
    
  endclass