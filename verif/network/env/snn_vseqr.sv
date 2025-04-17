//==============================================================================
// File: snn_vseqr.sv
// Author: Gaurang Pandey
// Description: Virtual sequencer to coordinate multiple sequencers
//==============================================================================

class snn_vseqr extends uvm_sequencer;
  `uvm_component_utils(snn_vseqr)

  // Sub-sequencers
  snn_sequencer  snn_seqr;
  apb_sequencer  apb_seqr;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

endclass