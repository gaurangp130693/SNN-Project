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
      monitor_apb_transactions();
      monitor_snn_activity();
    join
  endtask
  
  // Monitor APB transactions
  task monitor_apb_transactions();
    snn_transaction trans;
    
    forever begin
      // Wait for APB transaction start
      @(posedge vif.clk);
      if(vif.psel && !vif.penable) begin
        trans = snn_transaction::type_id::create("trans");
        
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
  
  // Monitor SNN activity (pixel inputs and output spikes)
  task monitor_snn_activity();
    snn_transaction trans;
    logic [7:0] last_pixels[network_pkg::INPUT_SIZE];
    logic last_spikes[network_pkg::OUTPUT_SIZE];
    bit change_detected;
    
    // Initialize arrays
    for(int i = 0; i < network_pkg::INPUT_SIZE; i++)
      last_pixels[i] = 0;
      
    for(int i = 0; i < network_pkg::OUTPUT_SIZE; i++)
      last_spikes[i] = 0;
    
    forever begin
      @(posedge vif.clk);
      
      // Check for changes in pixel inputs or output spikes
      change_detected = 0;
      
      // Check pixel inputs
      for(int i = 0; i < network_pkg::INPUT_SIZE; i++) begin
        if(vif.pixel_input[i] != last_pixels[i]) begin
          change_detected = 1;
          break;
        end
      end
      
      // Check output spikes
      if(!change_detected) begin
        for(int i = 0; i < network_pkg::OUTPUT_SIZE; i++) begin
          if(vif.digit_spikes[i] != last_spikes[i]) begin
            change_detected = 1;
            break;
          end
        end
      end
      
      if(change_detected) begin
        trans = snn_transaction::type_id::create("trans");
        
        // Capture pixel inputs
        for(int i = 0; i < network_pkg::INPUT_SIZE; i++) begin
          trans.pixel_input[i] = vif.pixel_input[i];
          last_pixels[i] = vif.pixel_input[i];
        end
        
        // Capture leak factor
        trans.leak_factor = vif.leak_factor;
        
        // Capture output spikes
        for(int i = 0; i < network_pkg::OUTPUT_SIZE; i++) begin
          trans.digit_spikes[i] = vif.digit_spikes[i];
          last_spikes[i] = vif.digit_spikes[i];
        end
        
        `uvm_info(get_type_name(), $sformatf("SNN Activity: leak_factor=%0d", trans.leak_factor), UVM_MEDIUM)
        
        // Send to scoreboard
        item_collected_port.write(trans);
      end
    end
  endtask
  
endclass