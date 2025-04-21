//==============================================================================
//  File name: snn_tb_pkg.sv
//  Author : Gaurang Pandey
//  Description: UVM Package for SNN testbench
//==============================================================================
`timescale 1ns/1ps

package snn_tb_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Import APB agent files
  import apb_pkg::*;

  // SNN Register Model files
  import snn_reg_pkg::*;

  // SNN Agent files
  `include "snn_transaction.sv"
  `include "snn_driver.sv"
  `include "snn_monitor.sv"
  `include "snn_sequencer.sv"
  `include "snn_agent.sv"

  // SNN Environment files
  `include "snn_vseqr.sv"
  `include "snn_scoreboard.sv"
  `include "snn_env.sv"

  // SNN Sequence files
  `include "snn_seq_lib.sv"

  // SNN Test files
  `include "snn_base_test.sv"
  `include "snn_sanity_test.sv"
  `include "snn_reg_bitbash_test.sv"
  `include "snn_reg_rand_wr_rd_test.sv"
  `include "snn_digit_sequence_test.sv"
  `include "snn_checkered_sequence_test.sv"
  `include "snn_random_sequence_test.sv"
  `include "snn_noise_pattern_sequence_test.sv"
  `include "snn_radial_sequence_test.sv"
  `include "snn_gradient_sequence_test.sv"
  `include "snn_stripe_sequence_test.sv"
  `include "snn_reset_test.sv"

endpackage
