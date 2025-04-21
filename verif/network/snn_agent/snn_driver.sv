//==============================================================================
//  File name: snn_driver.sv
//  Author : Gaurang Pandey
//  Description: Pixel Driver for SNN UVM testbench
//==============================================================================

class snn_driver extends uvm_driver #(snn_transaction);

  // Registration with factory
  `uvm_component_utils(snn_driver)

  // Virtual interface
  virtual snn_if vif;

  // Constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual snn_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not found")
  endfunction

  // Run phase
  virtual task run_phase(uvm_phase phase);
    snn_transaction req;

    // Reset DUT
    reset_dut();

    forever begin
      seq_item_port.get_next_item(req);

      `uvm_info(get_type_name(), $sformatf("Received item:\n%s", req.convert2string()), UVM_HIGH)

      // Only handle pixel input operations
      drive_pixel_input(req);

      seq_item_port.item_done();
    end
  endtask

  // Reset the DUT
  task reset_dut();
    `uvm_info(get_type_name(), "Resetting DUT", UVM_MEDIUM)

    vif.rst_n = 0;

    // Initialize pixel inputs
    for(int i = 0; i < network_pkg::INPUT_SIZE; i++)
      vif.pixel_input[i] = 0;

    vif.leak_factor = 8'h00; // Default leak factor

    repeat(5) @(posedge vif.clk);
    vif.rst_n = 1;

    `uvm_info(get_type_name(), "Reset complete", UVM_MEDIUM)
  endtask

  // Drive pixel input
  task drive_pixel_input(snn_transaction req);
    `uvm_info(get_type_name(), "Driving pixel input", UVM_MEDIUM)

    @(posedge vif.clk);

    // Set pixel values
    for(int i = 0; i < network_pkg::INPUT_SIZE; i++)
      vif.pixel_input[i] = req.pixel_input[i];

    // Set leak factor
    vif.leak_factor = req.leak_factor;
    vif.pixel_valid = 1;

    `uvm_info(get_type_name(), $sformatf("Pixel values: %p, Leak factor: %0d",
             req.pixel_input, req.leak_factor), UVM_MEDIUM)

    // Drive for "spike_window" # of clock cycle
    repeat (req.spike_window) begin
      @(posedge vif.clk);
    end
    vif.pixel_valid = 0;

  endtask

endclass