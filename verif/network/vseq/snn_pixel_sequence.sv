//==============================================================================
//  File name: snn_pixel_sequence.sv
//  Author : Gaurang Pandey
//  Description: Stimulus sequence for pixel inputs
//==============================================================================
class snn_pixel_sequence extends snn_base_sequence;

  // Registration with factory
  `uvm_object_utils(snn_pixel_sequence)

  // Number of pixel input patterns to generate
  int num_patterns = 5;

  // Constructor
  function new(string name = "snn_pixel_sequence");
    super.new(name);
  endfunction

  // Body task for pixel inputs
  virtual task body();
    snn_transaction req;

    repeat(num_patterns) begin
      req = snn_transaction::type_id::create("req");
      start_item(req);
      finish_item(req);

      // Wait some cycles to observe spikes
      #(network_pkg::CLK_PERIOD * 1000);
    end
  endtask

endclass