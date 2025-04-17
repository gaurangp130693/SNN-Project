//============================================================================== 
//  File name: apb_sequences.sv 
//  Author : Gaurang Pandey 
//  Description: APB Sequences for SNN UVM testbench
//==============================================================================

// Import APB package
import apb_pkg::*;

// Base APB sequence
class apb_base_sequence extends uvm_sequence #(apb_transaction);
  
  // Registration with factory
  `uvm_object_utils(apb_base_sequence)
  
  // Constructor
  function new(string name = "apb_base_sequence");
    super.new(name);
  endfunction
  
  // Pre-start routine - configure default settings
  virtual task pre_start();
    super.pre_start();
    if (starting_phase != null)
      starting_phase.raise_objection(this);
  endtask
  
  // Post-start routine - clean up
  virtual task post_start();
    super.post_start();
    if (starting_phase != null)
      starting_phase.drop_objection(this);
  endtask
  
endclass

// APB Write sequence
class apb_write_sequence extends apb_base_sequence;
  
  // Registration with factory
  `uvm_object_utils(apb_write_sequence)
  
  // Sequence parameters
  rand bit [31:0] addr;
  rand bit [31:0] data;
  
  // Constructor
  function new(string name = "apb_write_sequence");
    super.new(name);
  endfunction
  
  // Body of the sequence
  virtual task body();
    apb_transaction req;
    
    req = apb_transaction::type_id::create("req");
    start_item(req);
    
    req.operation = APB_WRITE;
    req.pwrite = 1;
    req.paddr = addr;
    req.pwdata = data;
    
    finish_item(req);
    
    `uvm_info(get_type_name(), $sformatf("APB Write completed: addr=0x%0h, data=0x%0h", addr, data), UVM_MEDIUM)
  endtask
  
endclass

// APB Read sequence
class apb_read_sequence extends apb_base_sequence;
  
  // Registration with factory
  `uvm_object_utils(apb_read_sequence)
  
  // Sequence parameters
  rand bit [31:0] addr;
  bit [31:0] data;  // Output - read data
  
  // Constructor
  function new(string name = "apb_read_sequence");
    super.new(name);
  endfunction
  
  // Body of the sequence
  virtual task body();
    apb_transaction req;
    
    req = apb_transaction::type_id::create("req");
    start_item(req);
    
    req.operation = APB_READ;
    req.pwrite = 0;
    req.paddr = addr;
    
    finish_item(req);
    
    // Get the read data from response
    data = req.prdata;
    
    `uvm_info(get_type_name(), $sformatf("APB Read completed: addr=0x%0h, data=0x%0h", addr, data), UVM_MEDIUM)
  endtask
  
endclass

// APB Memory test sequence - performs multiple reads and writes
class apb_memory_test_sequence extends apb_base_sequence;
  
  // Registration with factory
  `uvm_object_utils(apb_memory_test_sequence)
  
  // Sequence parameters
  rand int unsigned num_transactions;
  rand bit [31:0] start_addr;
  
  // Sub-sequences
  apb_read_sequence read_seq;
  apb_write_sequence write_seq;
  
  // Constructor
  function new(string name = "apb_memory_test_sequence");
    super.new(name);
  endfunction
  
  // Constraints
  constraint c_num_trans {
    num_transactions inside {[5:20]};
  }
  
  constraint c_addr {
    start_addr[1:0] == 2'b00;  // Word-aligned
  }
  
  // Body of the sequence
  virtual task body();
    bit [31:0] addr;
    bit [31:0] data;
    bit [31:0] read_data;
    
    read_seq = apb_read_sequence::type_id::create("read_seq");
    write_seq = apb_write_sequence::type_id::create("write_seq");
    
    // Write data to consecutive addresses
    for (int i = 0; i < num_transactions; i++) begin
      addr = start_addr + (i << 2);  // Word-aligned addresses
      data = $urandom;
      
      // Write data
      write_seq.addr = addr;
      write_seq.data = data;
      write_seq.start(m_sequencer);
      
      // Read and verify
      read_seq.addr = addr;
      read_seq.start(m_sequencer);
      read_data = read_seq.data;
      
      // Check if read data matches write data
      if (read_data !== data) begin
        `uvm_error(get_type_name(), 
                  $sformatf("Data mismatch at addr 0x%0h: Expected=0x%0h, Actual=0x%0h",
                  addr, data, read_data))
      end
    end
    
    `uvm_info(get_type_name(), $sformatf("APB Memory test completed: %0d transactions", num_transactions), UVM_MEDIUM)
  endtask
  
endclass