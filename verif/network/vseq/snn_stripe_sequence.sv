//==============================================================================
//  File name: snn_stripe_sequence.sv
//  Author : Gaurang Pandey
//  Description: Stripe pattern sequence for SNN UVM testbench
//==============================================================================

class snn_stripe_sequence extends uvm_sequence;
  
  // Registration with factory
  `uvm_object_utils(snn_stripe_sequence)
  
  // Constructor
  function new(string name = "snn_stripe_sequence");
    super.new(name);
  endfunction
  
  // Sequence body
  virtual task body();
    snn_transaction tx;
    int grid_size;
    int stripe_width;
    
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
      
      // Randomize stripe width between 1 and grid_size/2
      stripe_width = $urandom_range(1, grid_size/2);
      
      // Create stripe pattern (alternating vertical stripes)
      for (int row = 0; row < grid_size; row++) begin
        for (int col = 0; col < grid_size; col++) begin
          int idx = row * grid_size + col;
          // Determine if this pixel is in a light or dark stripe
          if ((col / stripe_width) % 2 == 0) begin
            tx.pixel_input[idx] = 240;  // Light stripe
          end else begin
            tx.pixel_input[idx] = 15;   // Dark stripe
          end
        end
      end
      
      `uvm_info(get_type_name(), $sformatf("Generated stripe pattern transaction with width %0d:\n%s", 
                                          stripe_width, tx.convert2string()), UVM_MEDIUM)
      finish_item(tx);
    end
  endtask
  
endclass