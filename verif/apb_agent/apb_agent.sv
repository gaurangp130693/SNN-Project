//============================================================================== 
//  File name: apb_agent.sv 
//  Author : Gaurang Pandey 
//  Description: APB Agent for SNN UVM testbench
//==============================================================================

class apb_agent extends uvm_agent;
  
  // Registration with factory
  `uvm_component_utils(apb_agent)
  
  // Agent components
  apb_driver    driver;
  apb_sequencer sequencer;
  apb_monitor   monitor;
  
  // Analysis port to forward transactions from monitor
  uvm_analysis_port #(snn_transaction) analysis_port;
  
  // Agent configuration
  bit is_active = 1;  // Default active agent
  
  // Constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // Always create the monitor
    monitor = apb_monitor::type_id::create("monitor", this);
    
    // Create the analysis port
    analysis_port = new("analysis_port", this);
    
    // Create driver and sequencer only for active agent
    if(is_active) begin
      driver = apb_driver::type_id::create("driver", this);
      sequencer = apb_sequencer::type_id::create("sequencer", this);
    end
    
    `uvm_info(get_type_name(), "Build phase complete", UVM_HIGH)
  endfunction
  
  // Connect phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    // Connect monitor to agent's analysis port
    monitor.item_collected_port.connect(analysis_port);
    
    // Connect driver and sequencer for active agent
    if(is_active) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
    
    `uvm_info(get_type_name(), "Connect phase complete", UVM_HIGH)
  endfunction
  
  // Set agent mode (active or passive)
  function void set_mode(bit active);
    is_active = active;
  endfunction
  
endclass