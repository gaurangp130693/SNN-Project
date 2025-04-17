//==============================================================================
//  File name: snn_sequencer.sv
//  Author : Gaurang Pandey
//  Description: Sequencer for SNN UVM testbench
//==============================================================================

class snn_sequencer extends uvm_sequencer #(snn_seq_item);

  `uvm_component_utils(snn_sequencer)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

endclass
