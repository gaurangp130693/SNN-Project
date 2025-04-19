//==============================================================================
//  File name: snn_digit_sequence.sv
//  Author : Gaurang Pandey
//  Description: Complete digit pattern sequence for SNN UVM testbench
//==============================================================================

class snn_digit_sequence extends snn_base_sequence;
  
  // Registration with factory
  `uvm_object_utils(snn_digit_sequence)
  
  // Parameters
  int grid_size;     // Square root of INPUT_SIZE (8 for 64 inputs)
  bit [7:0] bg_color = 8'h00;   // Background color (black)
  bit [7:0] fg_color = 8'hFF;   // Foreground color (white)
  
  // Constructor
  function new(string name = "snn_digit_sequence");
    super.new(name);
    grid_size = $sqrt(network_pkg::INPUT_SIZE); // Should be 8 for 64 input pixels
  endfunction
  
  // Create digit 0 pattern
  function void create_digit_0(ref logic [7:0] pixel_array[]);
    // First clear the array
    foreach (pixel_array[i]) pixel_array[i] = bg_color;
    
    // Create oval/circle pattern for digit 0
    for (int row = 0; row < grid_size; row++) begin
      for (int col = 0; col < grid_size; col++) begin
        int idx = row * grid_size + col;
        
        // Top and bottom edges
        if ((row == 1 || row == grid_size-2) && 
            (col >= 2 && col <= grid_size-3)) begin
          pixel_array[idx] = fg_color;
        end
        // Left and right edges
        else if ((col == 1 || col == grid_size-2) && 
                (row >= 2 && row <= grid_size-3)) begin
          pixel_array[idx] = fg_color;
        end
        // Corners
        else if ((row == 2 && col == 1) || (row == 2 && col == grid_size-2) ||
                (row == grid_size-3 && col == 1) || (row == grid_size-3 && col == grid_size-2)) begin
          pixel_array[idx] = fg_color;
        end
      end
    end
  endfunction
  
  // Create digit 1 pattern
  function void create_digit_1(ref logic [7:0] pixel_array[]);
    // First clear the array
    foreach (pixel_array[i]) pixel_array[i] = bg_color;
    
    // Create vertical line for digit 1
    for (int row = 0; row < grid_size; row++) begin
      for (int col = 0; col < grid_size; col++) begin
        int idx = row * grid_size + col;
        
        // Main vertical line
        if (col == grid_size/2 && row >= 1) begin
          pixel_array[idx] = fg_color;
        end
        // Top left diagonal
        else if ((row == 2 && col == grid_size/2-1) || 
                (row == 1 && col == grid_size/2-1)) begin
          pixel_array[idx] = fg_color;
        end
        // Base
        else if (row == grid_size-2 && 
                (col >= grid_size/2-1 && col <= grid_size/2+1)) begin
          pixel_array[idx] = fg_color;
        end
      end
    end
  endfunction
  
  // Create digit 2 pattern
  function void create_digit_2(ref logic [7:0] pixel_array[]);
    // First clear the array
    foreach (pixel_array[i]) pixel_array[i] = bg_color;
    
    // Create pattern for digit 2
    for (int row = 0; row < grid_size; row++) begin
      for (int col = 0; col < grid_size; col++) begin
        int idx = row * grid_size + col;
        
        // Top arc
        if (row == 1 && (col >= 2 && col <= grid_size-3)) begin
          pixel_array[idx] = fg_color;
        end
        // Top right edge
        else if (col == grid_size-2 && (row == 2)) begin
          pixel_array[idx] = fg_color;
        end
        // Middle arc
        else if (row == 3 && (col >= 2 && col <= grid_size-3)) begin
          pixel_array[idx] = fg_color;
        end
        // Bottom left diagonal
        else if ((row == 4 && col == 2) || 
                (row == 5 && col == 3) ||
                (row == 6 && col == 4)) begin
          pixel_array[idx] = fg_color;
        end
        // Bottom line
        else if (row == grid_size-2 && (col >= 1 && col <= grid_size-2)) begin
          pixel_array[idx] = fg_color;
        end
      end
    end
  endfunction
  
  // Create digit 3 pattern
  function void create_digit_3(ref logic [7:0] pixel_array[]);
    // First clear the array
    foreach (pixel_array[i]) pixel_array[i] = bg_color;
    
    // Create pattern for digit 3
    for (int row = 0; row < grid_size; row++) begin
      for (int col = 0; col < grid_size; col++) begin
        int idx = row * grid_size + col;
        
        // Top horizontal line
        if (row == 1 && (col >= 2 && col <= grid_size-3)) begin
          pixel_array[idx] = fg_color;
        end
        // Right vertical line (top half)
        else if (col == grid_size-2 && (row >= 2 && row < grid_size/2)) begin
          pixel_array[idx] = fg_color;
        end
        // Middle horizontal line
        else if (row == grid_size/2 && (col >= 2 && col <= grid_size-3)) begin
          pixel_array[idx] = fg_color;
        end
        // Right vertical line (bottom half)
        else if (col == grid_size-2 && (row > grid_size/2 && row <= grid_size-3)) begin
          pixel_array[idx] = fg_color;
        end
        // Bottom horizontal line
        else if (row == grid_size-2 && (col >= 2 && col <= grid_size-3)) begin
          pixel_array[idx] = fg_color;
        end
      end
    end
  endfunction
  
  // Create digit 4 pattern
  function void create_digit_4(ref logic [7:0] pixel_array[]);
    // First clear the array
    foreach (pixel_array[i]) pixel_array[i] = bg_color;
    
    // Create pattern for digit 4
    for (int row = 0; row < grid_size; row++) begin
      for (int col = 0; col < grid_size; col++) begin
        int idx = row * grid_size + col;
        
        // Left vertical line (top half)
        if (col == 2 && (row >= 1 && row <= grid_size/2)) begin
          pixel_array[idx] = fg_color;
        end
        // Middle horizontal line
        else if (row == grid_size/2 && (col >= 1 && col <= grid_size-2)) begin
          pixel_array[idx] = fg_color;
        end
        // Right vertical line (full height)
        else if (col == grid_size-3 && (row >= 1 && row <= grid_size-2)) begin
          pixel_array[idx] = fg_color;
        end
      end
    end
  endfunction
  
  // Create digit 5 pattern
  function void create_digit_5(ref logic [7:0] pixel_array[]);
    // First clear the array
    foreach (pixel_array[i]) pixel_array[i] = bg_color;
    
    // Create pattern for digit 5
    for (int row = 0; row < grid_size; row++) begin
      for (int col = 0; col < grid_size; col++) begin
        int idx = row * grid_size + col;
        
        // Top horizontal line
        if (row == 1 && (col >= 1 && col <= grid_size-2)) begin
          pixel_array[idx] = fg_color;
        end
        // Left vertical line (top half)
        else if (col == 1 && (row >= 2 && row <= grid_size/2)) begin
          pixel_array[idx] = fg_color;
        end
        // Middle horizontal line
        else if (row == grid_size/2 && (col >= 1 && col <= grid_size-3)) begin
          pixel_array[idx] = fg_color;
        end
        // Right vertical line (bottom half)
        else if (col == grid_size-2 && (row > grid_size/2 && row <= grid_size-3)) begin
          pixel_array[idx] = fg_color;
        end
        // Bottom horizontal line
        else if (row == grid_size-2 && (col >= 1 && col <= grid_size-3)) begin
          pixel_array[idx] = fg_color;
        end
      end
    end
  endfunction
  
  // Create digit 6 pattern
  function void create_digit_6(ref logic [7:0] pixel_array[]);
    // First clear the array
    foreach (pixel_array[i]) pixel_array[i] = bg_color;
    
    // Create pattern for digit 6
    for (int row = 0; row < grid_size; row++) begin
      for (int col = 0; col < grid_size; col++) begin
        int idx = row * grid_size + col;
        
        // Left vertical line (full height)
        if (col == 2 && (row >= 2 && row <= grid_size-3)) begin
          pixel_array[idx] = fg_color;
        end
        // Top horizontal line
        else if (row == 1 && (col >= 3 && col <= grid_size-3)) begin
          pixel_array[idx] = fg_color;
        end
        // Middle horizontal line
        else if (row == grid_size/2 && (col >= 2 && col <= grid_size-3)) begin
          pixel_array[idx] = fg_color;
        end
        // Bottom horizontal line
        else if (row == grid_size-2 && (col >= 2 && col <= grid_size-3)) begin
          pixel_array[idx] = fg_color;
        end
        // Right vertical line (bottom half)
        else if (col == grid_size-2 && (row >= grid_size/2 && row <= grid_size-3)) begin
          pixel_array[idx] = fg_color;
        end
      end
    end
  endfunction
  
  // Create digit 7 pattern
  function void create_digit_7(ref logic [7:0] pixel_array[]);
    // First clear the array
    foreach (pixel_array[i]) pixel_array[i] = bg_color;
    
    // Create pattern for digit 7
    for (int row = 0; row < grid_size; row++) begin
      for (int col = 0; col < grid_size; col++) begin
        int idx = row * grid_size + col;
        
        // Top horizontal line
        if (row == 1 && (col >= 1 && col <= grid_size-2)) begin
          pixel_array[idx] = fg_color;
        end
        // Diagonal
        else if ((row == 2 && col == grid_size-3) ||
                (row == 3 && col == grid_size-4) ||
                (row == 4 && col == grid_size-4) ||
                (row == 5 && col == grid_size-5) ||
                (row == 6 && col == grid_size-5)) begin
          pixel_array[idx] = fg_color;
        end
      end
    end
  endfunction
  
  // Create digit 8 pattern
  function void create_digit_8(ref logic [7:0] pixel_array[]);
    // First clear the array
    foreach (pixel_array[i]) pixel_array[i] = bg_color;
    
    // Create pattern for digit 8
    for (int row = 0; row < grid_size; row++) begin
      for (int col = 0; col < grid_size; col++) begin
        int idx = row * grid_size + col;
        
        // Top horizontal line
        if (row == 1 && (col >= 2 && col <= grid_size-3)) begin
          pixel_array[idx] = fg_color;
        end
        // Middle horizontal line
        else if (row == grid_size/2 && (col >= 2 && col <= grid_size-3)) begin
          pixel_array[idx] = fg_color;
        end
        // Bottom horizontal line
        else if (row == grid_size-2 && (col >= 2 && col <= grid_size-3)) begin
          pixel_array[idx] = fg_color;
        end
        // Left vertical lines
        else if (col == 1 && ((row >= 2 && row < grid_size/2) || 
                             (row > grid_size/2 && row <= grid_size-3))) begin
          pixel_array[idx] = fg_color;
        end
        // Right vertical lines
        else if (col == grid_size-2 && ((row >= 2 && row < grid_size/2) || 
                                       (row > grid_size/2 && row <= grid_size-3))) begin
          pixel_array[idx] = fg_color;
        end
      end
    end
  endfunction
  
  // Create digit 9 pattern
  function void create_digit_9(ref logic [7:0] pixel_array[]);
    // First clear the array
    foreach (pixel_array[i]) pixel_array[i] = bg_color;
    
    // Create pattern for digit 9
    for (int row = 0; row < grid_size; row++) begin
      for (int col = 0; col < grid_size; col++) begin
        int idx = row * grid_size + col;
        
        // Top horizontal line
        if (row == 1 && (col >= 2 && col <= grid_size-3)) begin
          pixel_array[idx] = fg_color;
        end
        // Middle horizontal line
        else if (row == grid_size/2 && (col >= 2 && col <= grid_size-3)) begin
          pixel_array[idx] = fg_color;
        end
        // Left vertical line (top half)
        else if (col == 1 && (row >= 2 && row < grid_size/2)) begin
          pixel_array[idx] = fg_color;
        end
        // Right vertical line (full height)
        else if (col == grid_size-2 && (row >= 2 && row <= grid_size-3)) begin
          pixel_array[idx] = fg_color;
        end
        // Bottom curve
        else if ((row == grid_size-2 && (col >= 2 && col <= grid_size-3))) begin
          pixel_array[idx] = fg_color;
        end
      end
    end
  endfunction
  
  // Create a digit pattern based on the provided digit number
  function void create_digit_pattern(ref logic [7:0] pixel_array[], input int digit);
    case (digit)
      0: create_digit_0(pixel_array);
      1: create_digit_1(pixel_array);
      2: create_digit_2(pixel_array);
      3: create_digit_3(pixel_array);
      4: create_digit_4(pixel_array);
      5: create_digit_5(pixel_array);
      6: create_digit_6(pixel_array);
      7: create_digit_7(pixel_array);
      8: create_digit_8(pixel_array);
      9: create_digit_9(pixel_array);
      default: begin
        // For invalid digits, create a random pattern
        foreach (pixel_array[i]) begin
          pixel_array[i] = $urandom_range(0, 255);
        end
      end
    endcase
  endfunction
  
  // Optional: Add some noise to make patterns more realistic
  function void add_noise(ref logic [7:0] pixel_array[], input int noise_level = 20);
    foreach (pixel_array[i]) begin
      int noise = $urandom_range(-noise_level, noise_level);
      int new_value = pixel_array[i] + noise;
      
      // Clamp to 0-255 range
      if (new_value < 0) new_value = 0;
      if (new_value > 255) new_value = 255;
      
      pixel_array[i] = new_value;
    end
  endfunction
  
  // Optional: Add slight random offset to digit position
  function void add_position_variation(ref logic [7:0] pixel_array[], input int max_offset = 1);
    logic [7:0] temp_array[network_pkg::INPUT_SIZE];
    int row_offset, col_offset;
    
    // Copy original array to temp
    foreach (pixel_array[i]) begin
      temp_array[i] = pixel_array[i];
    end
    
    // Clear original array
    foreach (pixel_array[i]) begin
      pixel_array[i] = bg_color;
    end
    
    // Random offset
    row_offset = $urandom_range(-max_offset, max_offset);
    col_offset = $urandom_range(-max_offset, max_offset);
    
    // Apply offset
    for (int row = 0; row < grid_size; row++) begin
      for (int col = 0; col < grid_size; col++) begin
        int src_idx = row * grid_size + col;
        int new_row = row + row_offset;
        int new_col = col + col_offset;
        
        // Check bounds
        if (new_row >= 0 && new_row < grid_size && 
            new_col >= 0 && new_col < grid_size) begin
          int dst_idx = new_row * grid_size + new_col;
          pixel_array[dst_idx] = temp_array[src_idx];
        end
      end
    end
  endfunction
  
  // Print the digit pattern (for debugging)
  function void print_pattern(logic [7:0] pixel_array[]);
    string s = "\nDigit Pattern:\n";
    
    for (int row = 0; row < grid_size; row++) begin
      for (int col = 0; col < grid_size; col++) begin
        int idx = row * grid_size + col;
        s = {s, (pixel_array[idx] > 127) ? "# " : ". "};
      end
      s = {s, "\n"};
    end
    
    `uvm_info(get_type_name(), s, UVM_MEDIUM)
  endfunction
  
  // Sequence body
  virtual task body();
    snn_transaction tx;
    int digit;
    int variation_type;
    bit add_variations;
    
    // Generate each digit (0-9)
    for (digit = 0; digit < 10; digit++) begin
      // Create multiple variations of each digit
      repeat(3) begin  // 3 variations per digit
        tx = snn_transaction::type_id::create("tx");
        start_item(tx);
        
        if(!tx.randomize() with {
          // Randomize leak factor
          leak_factor inside {[1:32]};
        }) begin
          `uvm_error(get_type_name(), "Randomization failed")
        end
        
        // Create pattern for current digit
        create_digit_pattern(tx.pixel_input, digit);
        
        // Decide what type of variation to add
        variation_type = $urandom_range(0, 3);
        case (variation_type)
          0: begin  // No variation
             // Nothing to do
          end
          1: begin  // Add noise
            add_noise(tx.pixel_input, $urandom_range(10, 30));
          end
          2: begin  // Add position variation
            add_position_variation(tx.pixel_input, 1);
          end
          3: begin  // Add both noise and position variation
            add_noise(tx.pixel_input, $urandom_range(5, 15));
            add_position_variation(tx.pixel_input, 1);
          end
        endcase
        
        // Print the pattern for visualization
        print_pattern(tx.pixel_input);
        
        `uvm_info(get_type_name(), $sformatf("Generated pattern for digit %0d (variation %0d):\n%s", 
                                            digit, variation_type, tx.convert2string()), UVM_MEDIUM)
        finish_item(tx);
      end
    end
    
    // Add some special random patterns that don't represent digits
    repeat(5) begin
      tx = snn_transaction::type_id::create("tx");
      start_item(tx);
      
      if(!tx.randomize()) begin
        `uvm_error(get_type_name(), "Randomization failed")
      end
      
      `uvm_info(get_type_name(), $sformatf("Generated random non-digit pattern:\n%s", 
                                          tx.convert2string()), UVM_MEDIUM)
      finish_item(tx);
    end
  endtask
  
endclass