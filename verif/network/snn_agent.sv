//============================================================================== 
//  File name: snn_agent.sv 
//  Author : Gaurang Pandey 
//  Description: Agent for SNN UVM testbench
//==============================================================================

class snn_agent extends uvm_agent;
  
  // Registration with factory
  `uvm_component_utils(snn_agent)
  
  // Components
  snn_driver    driver;
  snn_sequencer sequencer;
  snn_monitor   monitor;
  
  // Agent configuration (active/passive)
  uvm_active_passive_enum is_active = UVM_ACTIVE;
  
  // Constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // Always create monitor
    monitor = snn_monitor::type_id::create("monitor", this);
    
    // Create driver and sequencer only for active agent
    if(is_active == UVM_ACTIVE) begin
      driver = snn_driver::type_id::create("driver", this);
      sequencer = snn_sequencer::type_id::create("sequencer", this);
    end
  endfunction
  
  // Connect phase
  function void connect_phase(uvm_phase phase);
    if(is_active == UVM_ACTIVE) begin
      // Connect driver and sequencer
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction
  
endclass