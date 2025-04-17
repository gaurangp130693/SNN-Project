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

      // Only handle APB operations
      case(req.operation)
        APB_WRITE: drive_apb_write(req);
        APB_READ:  drive_apb_read(req);
        default: `uvm_error(get_type_name(), $sformatf("Unsupported operation type %s", req.operation.name()))
      endcase

      seq_item_port.item_done();
    end
  endtask

  // Reset APB signals
  task reset_apb();
    `uvm_info(get_type_name(), "Resetting APB signals", UVM_MEDIUM)

    vif.psel = 0;
    vif.penable = 0;
    vif.pwrite = 0;
    vif.paddr = 0;
    vif.pwdata = 0;

    `uvm_info(get_type_name(), "APB reset complete", UVM_MEDIUM)
  endtask

  // APB Write Transaction
  task drive_apb_write(apb_transaction req);
    `uvm_info(get_type_name(), $sformatf("APB Write to addr 0x%0h, data 0x%0h",
             req.paddr, req.pwdata), UVM_MEDIUM)

    // Setup phase
    @(posedge vif.clk);
    vif.psel = 1;
    vif.penable = 0;
    vif.pwrite = 1;
    vif.paddr = req.paddr;
    vif.pwdata = req.pwdata;

    // Access phase
    @(posedge vif.clk);
    vif.penable = 1;

    // Wait for ready
    wait(vif.pready);

    // Complete transaction
    @(posedge vif.clk);
    vif.psel = 0;
    vif.penable = 0;
  endtask

  // APB Read Transaction
  task drive_apb_read(apb_transaction req);
    `uvm_info(get_type_name(), $sformatf("APB Read from addr 0x%0h", req.paddr), UVM_MEDIUM)

    // Setup phase
    @(posedge vif.clk);
    vif.psel = 1;
    vif.penable = 0;
    vif.pwrite = 0;
    vif.paddr = req.paddr;

    // Access phase
    @(posedge vif.clk);
    vif.penable = 1;

    // Wait for ready
    wait(vif.pready);

    // Capture read data
    req.prdata = vif.prdata;

    `uvm_info(get_type_name(), $sformatf("Read data: 0x%0h", req.prdata), UVM_MEDIUM)

    // Complete transaction
    @(posedge vif.clk);
    vif.psel = 0;
    vif.penable = 0;
  endtask

endclass