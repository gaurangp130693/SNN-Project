//==============================================================================
//  File name: snn_tb_pkg.sv
//  Author : Gaurang Pandey
//  Description: UVM Package for SNN testbench
//==============================================================================

package snn_tb_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Import APB agent files
  import apb_pkg::*;

  // SNN Register Model files
  import snn_reg_pkg::*;

  // SNN Agent files
  `include "snn_agent/snn_transaction.sv"
  `include "snn_agent/snn_driver.sv"
  `include "snn_agent/snn_monitor.sv"
  `include "snn_agent/snn_sequencer.sv"
  `include "snn_agent/snn_agent.sv"

  // SNN Environment files
  `include "snn_env/snn_env.sv"

  // SNN Sequence files
  `include "vseq/snn_seq_lib.sv"

  // SNN Test files
  `include "test/snn_base_test.sv"

endpackage
