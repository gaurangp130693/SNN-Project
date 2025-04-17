//============================================================================== 
//  File name: snn_transaction.sv 
//  Author : Gaurang Pandey 
//  Description: Transaction class for SNN UVM testbench
//==============================================================================

class snn_transaction extends uvm_sequence_item;
  
  // Registration with factory
  `uvm_object_utils(snn_transaction)
  
  // Pixel input array
  rand logic [7:0] pixel_input[];
  
  // Leak factor
  rand logic [7:0] leak_factor;
  
  // Output spikes
  logic digit_spikes[];
  
  // Constraints
  constraint c_pixel_array_size {
    pixel_input.size == network_pkg::INPUT_SIZE;
  }
  
  constraint c_digit_spikes_size {
    digit_spikes.size == network_pkg::OUTPUT_SIZE;
  }
  
  constraint c_pixel_values {
    foreach(pixel_input[i]) {
      pixel_input[i] inside {[0:255]};
    }
  }
  
  constraint c_leak_factor {
    leak_factor inside {[1:32]};
  }
  
  // Constructor
  function new(string name = "snn_transaction");
    super.new(name);
    pixel_input = new[network_pkg::INPUT_SIZE];
    digit_spikes = new[network_pkg::OUTPUT_SIZE];
  endfunction
  
  // Convert to string for debugging
  virtual function string convert2string();
    string s;
    s = super.convert2string();
    s = {s, $sformatf("\nPixel Input: ")};
    foreach(pixel_input[i])
      s = {s, $sformatf("%0d ", pixel_input[i])};
    s = {s, $sformatf("\nLeak Factor: %0d", leak_factor)};
    s = {s, $sformatf("\nDigit Spikes: ")};
    foreach(digit_spikes[i])
      s = {s, $sformatf("%0b ", digit_spikes[i])};
    return s;
  endfunction
  
  // Copy
  virtual function void do_copy(uvm_object rhs);
    snn_transaction rhs_cast;
    if(!$cast(rhs_cast, rhs)) begin
      `uvm_error("do_copy", "Cast failed")
      return;
    end
    super.do_copy(rhs);
    leak_factor = rhs_cast.leak_factor;
    
    // Handle dynamic arrays
    pixel_input = new[rhs_cast.pixel_input.size()];
    foreach(rhs_cast.pixel_input[i])
      pixel_input[i] = rhs_cast.pixel_input[i];
      
    digit_spikes = new[rhs_cast.digit_spikes.size()];
    foreach(rhs_cast.digit_spikes[i])
      digit_spikes[i] = rhs_cast.digit_spikes[i];
  endfunction
  
  // Compare
  virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    snn_transaction rhs_cast;
    bit result;
    
    if(!$cast(rhs_cast, rhs)) begin
      `uvm_error("do_compare", "Cast failed")
      return 0;
    end
    
    result = super.do_compare(rhs, comparer) &&
             (leak_factor == rhs_cast.leak_factor);
    
    // Compare dynamic arrays
    if(pixel_input.size() != rhs_cast.pixel_input.size())
      return 0;
      
    foreach(pixel_input[i])
      if(pixel_input[i] != rhs_cast.pixel_input[i])
        return 0;
        
    if(digit_spikes.size() != rhs_cast.digit_spikes.size())
      return 0;
      
    foreach(digit_spikes[i])
      if(digit_spikes[i] != rhs_cast.digit_spikes[i])
        return 0;
        
    return result;
  endfunction
  
endclass