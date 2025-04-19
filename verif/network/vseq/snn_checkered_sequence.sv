//==============================================================================
//  File name: snn_checkered_sequence.sv
//  Author : Gaurang Pandey
//  Description: Checkered pattern sequence for SNN UVM testbench
//==============================================================================

class snn_checkered_sequence extends uvm_sequence;
  
  // Registration with factory
  `uvm_object_utils(snn_checkered_sequence)
  
  // Constructor
  function new(string name = "snn_checkered_sequence");
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
      
      // Create checkered pattern (alternating high and low values)
      for (int row = 0; row < grid_size; row++) begin
        for (int col = 0; col < grid_size; col++) begin
          int idx = row * grid_size + col;
          if ((row + col) % 2 == 0) begin
            tx.pixel_input[idx] = 250;  // High value for white squares
          end else begin
            tx.pixel_input[idx] = 5;    // Low value for black squares
          end
        end
      end
      
      `uvm_info(get_type_name(), $sformatf("Generated checkered pattern transaction:\n%s", tx.convert2string()), UVM_MEDIUM)
      finish_item(tx);
    end
  endtask
  
endclass