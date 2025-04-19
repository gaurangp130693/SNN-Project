//==============================================================================
//  File name: snn_noise_pattern_sequence.sv
//  Description: Noise pattern sequence for SNN UVM testbench
//==============================================================================

class snn_noise_pattern_sequence extends snn_base_sequence;
  
  // Registration with factory
  `uvm_object_utils(snn_noise_pattern_sequence)
  
  // Constructor
  function new(string name = "snn_noise_pattern_sequence");
    super.new(name);
  endfunction
  
  // Sequence body
  virtual task body();
    snn_transaction tx;
    int grid_size;
    int base_value;
    int noise_range;
    
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
      
      // Randomize base value and noise range
      base_value = $urandom_range(100, 150);
      noise_range = $urandom_range(20, 80);
      
      // Create noise pattern around base value
      foreach (tx.pixel_input[i]) begin
        // Add random noise to base value, ensuring we stay within 0-255 range
        int pixel_value = base_value + $urandom_range(-noise_range, noise_range);
        tx.pixel_input[i] = (pixel_value < 0) ? 0 : 
                           (pixel_value > 255) ? 255 : pixel_value;
      end
      
      `uvm_info(get_type_name(), $sformatf("Generated noise pattern with base %0d and range %0d:\n%s", 
                                          base_value, noise_range, tx.convert2string()), UVM_MEDIUM)
      finish_item(tx);
    end
  endtask
  
endclass