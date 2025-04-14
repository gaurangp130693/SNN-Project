//============================================================================== 
//  File name: snn_driver.sv 
//  Author : Gaurang Pandey 
//  Description: Driver for SNN UVM testbench
//==============================================================================

class snn_driver extends uvm_driver #(snn_seq_item);
  
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
    snn_seq_item req;
    
    // Reset DUT
    reset_dut();
    
    forever begin
      seq_item_port.get_next_item(req);
      
      `uvm_info(get_type_name(), $sformatf("Received item:\n%s", req.convert2string()), UVM_HIGH)
      
      case(req.operation)
        snn_seq_item::PIXEL_INPUT: drive_pixel_input(req);
        snn_seq_item::APB_WRITE:   drive_apb_write(req);
        snn_seq_item::APB_READ:    drive_apb_read(req);
      endcase
      
      seq_item_port.item_done();
    end
  endtask
  
  // Reset the DUT
  task reset_dut();
    `uvm_info(get_type_name(), "Resetting DUT", UVM_MEDIUM)
    
    vif.rst_n = 0;
    vif.psel = 0;
    vif.penable = 0;
    vif.pwrite = 0;
    vif.paddr = 0;
    vif.pwdata = 0;
    
    // Initialize pixel inputs
    for(int i = 0; i < network_pkg::INPUT_SIZE; i++)
      vif.pixel_input[i] = 0;
      
    vif.leak_factor = 8'h10; // Default leak factor
    
    repeat(5) @(posedge vif.clk);
    vif.rst_n = 1;
    
    `uvm_info(get_type_name(), "Reset complete", UVM_MEDIUM)
  endtask
  
  // Drive pixel input
  task drive_pixel_input(snn_seq_item req);
    `uvm_info(get_type_name(), "Driving pixel input", UVM_MEDIUM)
    
    @(posedge vif.clk);
    
    // Set pixel values
    for(int i = 0; i < network_pkg::INPUT_SIZE; i++)
      vif.pixel_input[i] = req.trans.pixel_input[i];
      
    // Set leak factor
    vif.leak_factor = req.trans.leak_factor;
    
    `uvm_info(get_type_name(), $sformatf("Pixel values: %p, Leak factor: %0d", 
             req.trans.pixel_input, req.trans.leak_factor), UVM_MEDIUM)
             
    // Drive for one clock cycle
    @(posedge vif.clk);
  endtask
  
  // APB Write Transaction
  task drive_apb_write(snn_seq_item req);
    `uvm_info(get_type_name(), $sformatf("APB Write to addr 0x%0h, data 0x%0h", 
             req.trans.paddr, req.trans.pwdata), UVM_MEDIUM)
    
    // Setup phase
    @(posedge vif.clk);
    vif.psel = 1;
    vif.penable = 0;
    vif.pwrite = 1;
    vif.paddr = req.trans.paddr;
    vif.pwdata = req.trans.pwdata;
    
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
  task drive_apb_read(snn_seq_item req);
    `uvm_info(get_type_name(), $sformatf("APB Read from addr 0x%0h", req.trans.paddr), UVM_MEDIUM)
    
    // Setup phase
    @(posedge vif.clk);
    vif.psel = 1;
    vif.penable = 0;
    vif.pwrite = 0;
    vif.paddr = req.trans.paddr;
    
    // Access phase
    @(posedge vif.clk);
    vif.penable = 1;
    
    // Wait for ready
    wait(vif.pready);
    
    // Capture read data
    req.trans.prdata = vif.prdata;
    
    `uvm_info(get_type_name(), $sformatf("Read data: 0x%0h", req.trans.prdata), UVM_MEDIUM)
    
    // Complete transaction
    @(posedge vif.clk);
    vif.psel = 0;
    vif.penable = 0;
  endtask
  
endclass