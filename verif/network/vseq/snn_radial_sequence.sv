//==============================================================================
//  File name: snn_radial_sequence.sv
//  Description: Radial pattern sequence for SNN UVM testbench
//==============================================================================

class snn_radial_sequence extends snn_base_sequence;
  
  // Registration with factory
  `uvm_object_utils(snn_radial_sequence)
  
  // Constructor
  function new(string name = "snn_radial_sequence");
    super.new(name);
  endfunction
  
  // Sequence body
  virtual task body();
    snn_transaction tx;
    int grid_size;
    real center_x, center_y, max_dist, dist;
    
    // Assuming INPUT_SIZE is a perfect square (64 = 8x8)
    grid_size = $sqrt(network_pkg::INPUT_SIZE);
    center_x = center_y = (grid_size - 1) / 2.0; // Center of the grid
    max_dist = $sqrt((center_x * center_x) + (center_y * center_y)); // Max distance from center
    
    repeat(5) begin  // Generate 5 transactions
      tx = snn_transaction::type_id::create("tx");
      start_item(tx);
      
      if(!tx.randomize() with {
        // Randomize leak factor
        leak_factor inside {[1:32]};
      }) begin
        `uvm_error(get_type_name(), "Randomization failed")
      end
      
      // Create radial pattern (light in center, darker at edges)
      for (int row = 0; row < grid_size; row++) begin
        for (int col = 0; col < grid_size; col++) begin
          int idx = row * grid_size + col;
          dist = $sqrt(((row - center_x) * (row - center_x)) + 
                      ((col - center_y) * (col - center_y)));
          // Convert distance to pixel value (center is brightest)
          tx.pixel_input[idx] = 255 - ((dist * 255) / max_dist);
        end
      end
      
      `uvm_info(get_type_name(), $sformatf("Generated radial pattern transaction:\n%s", tx.convert2string()), UVM_MEDIUM)
      finish_item(tx);
    end
  endtask
  
endclass