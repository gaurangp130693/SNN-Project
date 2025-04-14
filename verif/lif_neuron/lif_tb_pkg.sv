//==============================================================================
//  File name: lif_tb_pkg.sv
//  Author    : Gaurang Pandey
//  Description: Package including all UVM testbench components for LIF neuron.
//==============================================================================

`ifndef LIF_TB_PKG_SV
`define LIF_TB_PKG_SV

package lif_tb_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // Include neuron-specific package
    import neuron_pkg::*;

    // Include TB components
    `include "lif_txn.sv"
    `include "lif_sequence.sv"
    `include "lif_driver.sv"
    `include "lif_monitor.sv"
    `include "lif_sequencer.sv"
    `include "lif_agent.sv"
    `include "lif_scoreboard.sv"
    `include "lif_env.sv"
    `include "lif_base_test.sv"

endpackage : lif_tb_pkg

`endif