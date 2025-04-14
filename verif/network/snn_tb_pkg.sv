//==============================================================================
//  File name: snn_tb_pkg.sv
//  Author : Gaurang Pandey
//  Description: UVM Package for SNN testbench
//==============================================================================

package snn_tb_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `include "snn_seq_item.sv"
  `include "snn_sequence.sv"
  `include "snn_driver.sv"
  `include "snn_monitor.sv"
  `include "snn_scoreboard.sv"
  `include "snn_sequencer.sv"
  `include "snn_agent.sv"
  `include "snn_env.sv"
  `include "snn_test.sv"

endpackage
