//==============================================================================
//  File name: snn_monitor.sv
//  Author : Gaurang Pandey
//  Description: Monitor for SNN UVM testbench
//==============================================================================

class snn_monitor extends uvm_monitor;

  // Registration with factory
  `uvm_component_utils(snn_monitor)

  // Virtual interface
  virtual snn_if vif;

  // Analysis port to send transactions to scoreboard
  uvm_analysis_port #(snn_transaction) item_collected_port;

  // Constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);
  endfunction

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual snn_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not found")
  endfunction

  // Run phase
  virtual task run_phase(uvm_phase phase);
    fork
      monitor_snn_activity();
    join
  endtask

  // Monitor SNN activity (pixel inputs and output spikes)
  task monitor_snn_activity();
    snn_transaction trans;
    bit last_spikes[network_pkg::OUTPUT_SIZE];
    bit snn_start;

    forever begin
      @(posedge vif.clk);

      if(vif.pixel_valid && vif.rst_n) begin
        snn_start = 1;
        // Capture output spikes
        for(int i = 0; i < network_pkg::OUTPUT_SIZE; i++) begin
          if(vif.digit_spikes[i] == 1) begin
            last_spikes[i] = last_spikes[i] | 1'b1;
          end
        end
      end
      if(!vif.pixel_valid && vif.rst_n && snn_start) begin
        trans = snn_transaction::type_id::create("trans");
        for(int i = 0; i < network_pkg::OUTPUT_SIZE; i++) begin
          trans.digit_spikes[i] = last_spikes[i];
        end
        // Send to scoreboard
        item_collected_port.write(trans);
      end
    end
  endtask

endclass