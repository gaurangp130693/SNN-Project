//==============================================================================
//  File name: apb_monitor.sv
//  Author : Gaurang Pandey
//  Description: APB Monitor for SNN UVM testbench
//==============================================================================

class apb_monitor extends uvm_monitor;

  // Registration with factory
  `uvm_component_utils(apb_monitor)

  // Virtual interface
  virtual apb_if vif;

  // Analysis port to send transactions to scoreboard
  uvm_analysis_port #(apb_transaction) item_collected_port;

  // Constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);
  endfunction

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not found")
  endfunction

  // Run phase
  virtual task run_phase(uvm_phase phase);
    monitor_apb_transactions();
  endtask

  // Monitor APB transactions
  task monitor_apb_transactions();
    apb_transaction trans;

    forever begin
      // Wait for APB transaction start
      @(posedge vif.clk);
      if(vif.psel && !vif.penable) begin
        trans = apb_transaction::type_id::create("trans");

        // Capture address and write data
        trans.paddr = vif.paddr;
        trans.pwdata = vif.pwdata;
        trans.pwrite = vif.pwrite;

        // Wait for access phase
        @(posedge vif.clk);

        // Capture read data if applicable
        if(!vif.pwrite) begin
          wait(vif.pready);
          trans.prdata = vif.prdata;
        end

        // Capture ready signal
        trans.pready = vif.pready;

        `uvm_info(get_type_name(), $sformatf("APB Transaction: addr=0x%0h, data=0x%0h, write=%0b",
                 trans.paddr, vif.pwrite ? trans.pwdata : trans.prdata, trans.pwrite), UVM_MEDIUM)

        // Send to scoreboard
        item_collected_port.write(trans);
      end
    end
  endtask

endclass