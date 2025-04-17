//==============================================================================
//  File name: snn_base_sequence.sv
//  Author : Gaurang Pandey
//  Description: Base sequence for SNN UVM testbench
//==============================================================================

class snn_base_sequence extends uvm_sequence #(snn_transaction);

  // Registration with factory
  `uvm_object_utils(snn_base_sequence)

  // Constructor
  function new(string name = "snn_base_sequence");
    super.new(name);
  endfunction

  // Body task
  virtual task body();
    // Base sequence is empty
  endtask

endclass