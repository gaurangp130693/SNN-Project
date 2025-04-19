//==============================================================================
//  File name: snn_random_sequence.sv
//  Author : Gaurang Pandey
//  Description: Random pattern sequence for SNN UVM testbench
//==============================================================================

class snn_random_sequence extends uvm_sequence;
  
  // Registration with factory
  `uvm_object_utils(snn_random_sequence)
  
  // Constructor
  function new(string name = "snn_random_sequence");
    super.new(name);
  endfunction
  
  // Sequence body
  virtual task body();
    snn_transaction tx;
    
    repeat(10) begin  // Generate 10 transactions
      tx = snn_transaction::type_id::create("tx");
      start_item(tx);
      
      // Randomize transaction with default constraints
      // This will generate completely random pixel patterns
      if(!tx.randomize()) begin
        `uvm_error(get_type_name(), "Randomization failed")
      end
      
      `uvm_info(get_type_name(), $sformatf("Generated random transaction:\n%s", tx.convert2string()), UVM_MEDIUM)
      finish_item(tx);
    end
  endtask
  
endclass