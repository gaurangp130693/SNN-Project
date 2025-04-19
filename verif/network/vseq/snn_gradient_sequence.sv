//==============================================================================
//  File name: snn_gradient_sequence.sv
//  Author : Gaurang Pandey
//  Description: Gradient pattern sequence for SNN UVM testbench
//==============================================================================

class snn_gradient_sequence extends snn_base_sequence;
  
  // Registration with factory
  `uvm_object_utils(snn_gradient_sequence)
  
  // Constructor
  function new(string name = "snn_gradient_sequence");
    super.new(name);
  endfunction
  
  // Sequence body
  virtual task body();
    snn_transaction tx;
    int grid_size;
    
    // Assuming INPUT_SIZE is a perfect square (64 = 8x8)
    grid_size = $sqrt(network_pkg::INPUT_SIZE);
    
    repeat(5) begin  // Generate 5 transactions
      tx = snn_transaction::type_id::create("tx");
      start_item(tx);
      
      if(!tx.randomize() with {
        // Randomize leak factor
        leak_factor inside {[1:32]};
      }) begin
        `uvm_error(get_type_name(), "Randomization failed")
      end
      
      // Create horizontal gradient pattern
      for (int row = 0; row < grid_size; row++) begin
        for (int col = 0; col < grid_size; col++) begin
          int idx = row * grid_size + col;
          // Map column position to a gradient from 0 to 255
          tx.pixel_input[idx] = (col * 256) / grid_size;
        end
      end
      
      `uvm_info(get_type_name(), $sformatf("Generated gradient pattern transaction:\n%s", tx.convert2string()), UVM_MEDIUM)
      finish_item(tx);
    end
  endtask
  
endclass