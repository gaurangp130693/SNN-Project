//==============================================================================
//  File name: lif_driver.sv
//  Author    : Gaurang Pandey
//  Description: Driver for LIF neuron. Drives inputs to DUT from sequencer.
//==============================================================================

`ifndef LIF_DRIVER_SV
`define LIF_DRIVER_SV

class lif_driver extends uvm_driver #(lif_txn);

    `uvm_component_utils(lif_driver)

    virtual lif_if vif;

    function new(string name = "lif_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual lif_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "Virtual interface not set in driver")
    endfunction

    virtual task run_phase(uvm_phase phase);
        lif_txn txn;
        `uvm_info("lif_driver", "Starting run_phase...", UVM_LOW)
        forever begin
            @(posedge vif.clk);
            if(vif.rst_n == 1) begin
              seq_item_port.get_next_item(txn);

              // Apply transaction
              vif.leak_factor = txn.leak_factor;
              vif.input_spike = txn.input_spike;
              vif.threshold   = txn.threshold;


              seq_item_port.item_done();
            end
            else begin
              vif.leak_factor = 0;
              vif.input_spike = 0;
              vif.threshold   = 0;
            end
        end
    endtask

endclass : lif_driver

`endif
