//==============================================================================
//  File name: apb_driver.sv
//  Author : Gaurang Pandey
//  Description: APB Driver for SNN UVM testbench
//==============================================================================

class apb_driver extends uvm_driver #(apb_transaction);

  // Registration with factory
  `uvm_component_utils(apb_driver)

  // Virtual interface
  virtual apb_if vif;

  // Constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not found")
  endfunction

  // Run phase
  virtual task run_phase(uvm_phase phase);
    apb_transaction req;

    // Reset APB signals
    reset_apb();

    forever begin
      seq_item_port.get_next_item(req);
      `uvm_info(get_type_name(), $sformatf("Received item:\n%s", req.convert2string()), UVM_HIGH)
      drive_transfer(req);
      seq_item_port.item_done();
      `uvm_info(get_type_name(), $sformatf("item_done:\n"), UVM_HIGH)
    end
  endtask

  // Reset APB signals
  task reset_apb();
    `uvm_info(get_type_name(), "Resetting APB signals", UVM_MEDIUM)
    vif.psel <= 0;
    vif.penable <= 0;
    vif.pwrite <= 0;
    vif.paddr <= 0;
    vif.pwdata <= 0;
    `uvm_info(get_type_name(), "APB reset complete", UVM_MEDIUM)
  endtask

  // Drive APB transfer
  task drive_transfer(apb_transaction tr);
    // Setup phase
    @(posedge vif.clk);
    vif.psel <= 1;
    vif.penable <= 0;
    vif.pwrite <= tr.pwrite;
    vif.paddr <= tr.paddr;
    if (tr.pwrite) vif.pwdata <= tr.pwdata;

    // Access phase
    @(posedge vif.clk);
    vif.penable <= 1;

    // Wait for pready
    do begin
        @(posedge vif.clk);
    end while (!vif.pready);

    // If read operation, capture data
    if (!tr.pwrite) tr.prdata = vif.prdata;

    // End transaction
    @(posedge vif.clk);
    vif.psel <= 0;
    vif.penable <= 0;
    `uvm_info(get_type_name(), $sformatf("Driven Txn - %s", tr.convert2string()), UVM_MEDIUM)
  endtask

endclass