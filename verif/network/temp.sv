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
  
endclass//============================================================================== 
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
  
endclass//============================================================================== 
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
  
endclass//============================================================================== 
//  File name: snn_sequence.sv 
//  Author : Gaurang Pandey 
//  Description: Base sequence for SNN UVM testbench
//==============================================================================

class snn_sequence extends uvm_sequence #(snn_seq_item);
  
  // Registration with factory
  `uvm_object_utils(snn_sequence)
  
  // Constructor
  function new(string name = "snn_sequence");
    super.new(name);
  endfunction
  
  // Body task
  virtual task body();
    // Base sequence is empty
  endtask
  
endclass

//------------------------------------------------------------------------------
// Initialize all registers sequence
//------------------------------------------------------------------------------
class snn_init_sequence extends snn_sequence;
  
  // Registration with factory
  `uvm_object_utils(snn_init_sequence)
  
  // Constructor
  function new(string name = "snn_init_sequence");
    super.new(name);
  endfunction
  
  // Body task to initialize all registers
  virtual task body();
    int i;
    snn_seq_item req;
    
    // Initialize layer 0 weights
    for (i = 0; i < (network_pkg::INPUT_SIZE * network_pkg::HIDDEN_SIZE); i += 4) begin
      req = snn_seq_item::type_id::create("req");
      start_item(req);
      
      assert(req.randomize() with {
        operation == snn_seq_item::APB_WRITE;
        trans.paddr == network_pkg::LAYER_WEIGHT_BASE_ADDR_U0 + i;
        trans.pwdata == 32'h10000000 + i;
      });
      
      finish_item(req);
    end
    
    // Initialize layer 0 spike thresholds
    for (i = 0; i < (network_pkg::INPUT_SIZE * network_pkg::HIDDEN_SIZE); i += 4) begin
      req = snn_seq_item::type_id::create("req");
      start_item(req);
      
      assert(req.randomize() with {
        operation == snn_seq_item::APB_WRITE;
        trans.paddr == network_pkg::LAYER_SPIKE_THRESH_BASE_ADDR_U0 + i;
        trans.pwdata == 32'h20000000 + i;
      });
      
      finish_item(req);
    end
    
    // Initialize layer 0 neuron thresholds
    for (i = 0; i < network_pkg::HIDDEN_SIZE; i++) begin
      req = snn_seq_item::type_id::create("req");
      start_item(req);
      
      assert(req.randomize() with {
        operation == snn_seq_item::APB_WRITE;
        trans.paddr == network_pkg::LAYER_NEURON_THRESH_BASE_ADDR_U0 + (i*4);
        trans.pwdata == 32'h30000000 + i;
      });
      
      finish_item(req);
    end
    
    // Set control status for layer 0
    req = snn_seq_item::type_id::create("req");
    start_item(req);
    
    assert(req.randomize() with {
      operation == snn_seq_item::APB_WRITE;
      trans.paddr == network_pkg::CONTROL_STATUS_BASE_ADDR_U0;
      trans.pwdata == 32'hFFFFFFFF;
    });
    
    finish_item(req);
    
    // Initialize layer 1 weights
    for (i = 0; i < (network_pkg::HIDDEN_SIZE * network_pkg::OUTPUT_SIZE); i += 4) begin
      req = snn_seq_item::type_id::create("req");
      start_item(req);
      
      assert(req.randomize() with {
        operation == snn_seq_item::APB_WRITE;
        trans.paddr == network_pkg::LAYER_WEIGHT_BASE_ADDR_U1 + i;
        trans.pwdata == 32'h60000000 + i;
      });
      
      finish_item(req);
    end
    
    // Initialize layer 1 spike thresholds
    for (i = 0; i < (network_pkg::HIDDEN_SIZE * network_pkg::OUTPUT_SIZE); i += 4) begin
      req = snn_seq_item::type_id::create("req");
      start_item(req);
      
      assert(req.randomize() with {
        operation == snn_seq_item::APB_WRITE;
        trans.paddr == network_pkg::LAYER_SPIKE_THRESH_BASE_ADDR_U1 + i;
        trans.pwdata == 32'h70000000 + i;
      });
      
      finish_item(req);
    end
    
    // Initialize layer 1 neuron thresholds
    for (i = 0; i < network_pkg::OUTPUT_SIZE; i++) begin
      req = snn_seq_item::type_id::create("req");
      start_item(req);
      
      assert(req.randomize() with {
        operation == snn_seq_item::APB_WRITE;
        trans.paddr == network_pkg::LAYER_NEURON_THRESH_BASE_ADDR_U1 + (i*4);
        trans.pwdata == 32'h80000000 + i;
      });
      
      finish_item(req);
    end
    
    // Set control status for layer 1
    req = snn_seq_item::type_id::create("req");
    start_item(req);
    
    assert(req.randomize() with {
      operation == snn_seq_item::APB_WRITE;
      trans.paddr == network_pkg::CONTROL_STATUS_BASE_ADDR_U1;
      trans.pwdata == 32'hFFFFFFFF;
    });
    
    finish_item(req);
  endtask
  
endclass

//------------------------------------------------------------------------------
// Stimulus sequence for pixel inputs
//------------------------------------------------------------------------------
class snn_pixel_sequence extends snn_sequence;
  
  // Registration with factory
  `uvm_object_utils(snn_pixel_sequence)
  
  // Number of pixel input patterns to generate
  int num_patterns = 5;
  
  // Constructor
  function new(string name = "snn_pixel_sequence");
    super.new(name);
  endfunction
  
  // Body task for pixel inputs
  virtual task body();
    snn_seq_item req;
    
    repeat(num_patterns) begin
      req = snn_seq_item::type_id::create("req");
      start_item(req);
      
      assert(req.randomize() with {
        operation == snn_seq_item::PIXEL_INPUT;
      });
      
      finish_item(req);
      
      // Wait some cycles to observe spikes
      #(network_pkg::CLK_PERIOD * 1000);
    end
  endtask
  
endclass

//------------------------------------------------------------------------------
// Comprehensive test sequence
//------------------------------------------------------------------------------
class snn_test_sequence extends snn_sequence;
  
  // Registration with factory
  `uvm_object_utils(snn_test_sequence)
  
  // Sequences to run
  snn_init_sequence init_seq;
  snn_pixel_sequence pixel_seq;
  
  // Constructor
  function new(string name = "snn_test_sequence");
    super.new(name);
  endfunction
  
  // Body task - run initialization followed by pixel stimuli
  virtual task body();
    `uvm_info(get_type_name(), "Starting test sequence", UVM_MEDIUM)
    
    // Initialize the network
    init_seq = snn_init_sequence::type_id::create("init_seq");
    init_seq.start(m_sequencer);
    
    // Wait for initialization to complete
    #(network_pkg::CLK_PERIOD * 100);
    
    // Apply pixel inputs
    pixel_seq = snn_pixel_sequence::type_id::create("pixel_seq");
    pixel_seq.num_patterns = 10;  // Test with 10 patterns
    pixel_seq.start(m_sequencer);
    
    `uvm_info(get_type_name(), "Test sequence completed", UVM_MEDIUM)
  endtask
  
endclass//============================================================================== 
//  File name: snn_seq_item.sv 
//  Author : Gaurang Pandey 
//  Description: Sequence item for SNN UVM testbench
//==============================================================================

class snn_seq_item extends uvm_sequence_item;
  
  // Registration with factory
  `uvm_object_utils(snn_seq_item)
  
  typedef enum {PIXEL_INPUT, APB_WRITE, APB_READ} operation_t;
  
  // Operation type
  rand operation_t operation;
  
  // Transaction data
  rand snn_transaction trans;
  
  // Constraints
  constraint c_operation_dist {
    operation dist {
      PIXEL_INPUT := 3,
      APB_WRITE := 5,
      APB_READ := 2
    };
  }
  
  constraint c_apb_write {
    if (operation == APB_WRITE) {
      trans.pwrite == 1;
    }
  }
  
  constraint c_apb_read {
    if (operation == APB_READ) {
      trans.pwrite == 0;
    }
  }
  
  // Constructor
  function new(string name = "snn_seq_item");
    super.new(name);
    trans = new("trans");
  endfunction
  
  // Convert to string for debugging
  virtual function string convert2string();
    string s;
    s = super.convert2string();
    s = {s, $sformatf("\nOperation: %s", operation.name())};
    s = {s, $sformatf("\nTransaction: %s", trans.convert2string())};
    return s;
  endfunction
  
endclass//============================================================================== 
//  File name: snn_transaction.sv 
//  Author : Gaurang Pandey 
//  Description: Transaction class for SNN UVM testbench
//==============================================================================

class snn_transaction extends uvm_sequence_item;
  
  // Registration with factory
  `uvm_object_utils(snn_transaction)
  
  // Pixel input array
  rand logic [7:0] pixel_input[];
  
  // Leak factor
  rand logic [7:0] leak_factor;
  
  // Output spikes
  logic digit_spikes[];
  
  // APB interface signals
  rand logic [15:0] paddr;
  rand logic [31:0] pwdata;
  rand logic        pwrite;
  logic [31:0]      prdata;
  logic             pready;
  
  // Constraints
  constraint c_pixel_array_size {
    pixel_input.size == network_pkg::INPUT_SIZE;
  }
  
  constraint c_digit_spikes_size {
    digit_spikes.size == network_pkg::OUTPUT_SIZE;
  }
  
  constraint c_pixel_values {
    foreach(pixel_input[i]) {
      pixel_input[i] inside {[0:255]};
    }
  }
  
  constraint c_leak_factor {
    leak_factor inside {[1:32]};
  }
  
  constraint c_apb_addr {
    paddr inside {
      [network_pkg::LAYER_WEIGHT_BASE_ADDR_U0:network_pkg::LAYER_WEIGHT_BASE_ADDR_U0 + 4*((network_pkg::INPUT_SIZE*network_pkg::HIDDEN_SIZE)/4 - 1)],
      [network_pkg::LAYER_SPIKE_THRESH_BASE_ADDR_U0:network_pkg::LAYER_SPIKE_THRESH_BASE_ADDR_U0 + 4*((network_pkg::INPUT_SIZE*network_pkg::HIDDEN_SIZE)/4 - 1)],
      [network_pkg::LAYER_NEURON_THRESH_BASE_ADDR_U0:network_pkg::LAYER_NEURON_THRESH_BASE_ADDR_U0 + 4*(network_pkg::HIDDEN_SIZE - 1)],
      [network_pkg::CONTROL_STATUS_BASE_ADDR_U0:network_pkg::CONTROL_STATUS_BASE_ADDR_U0 + 3],
      [network_pkg::LAYER_WEIGHT_BASE_ADDR_U1:network_pkg::LAYER_WEIGHT_BASE_ADDR_U1 + 4*((network_pkg::HIDDEN_SIZE*network_pkg::OUTPUT_SIZE)/4 - 1)],
      [network_pkg::LAYER_SPIKE_THRESH_BASE_ADDR_U1:network_pkg::LAYER_SPIKE_THRESH_BASE_ADDR_U1 + 4*((network_pkg::HIDDEN_SIZE*network_pkg::OUTPUT_SIZE)/4 - 1)],
      [network_pkg::LAYER_NEURON_THRESH_BASE_ADDR_U1:network_pkg::LAYER_NEURON_THRESH_BASE_ADDR_U1 + 4*(network_pkg::OUTPUT_SIZE - 1)],
      [network_pkg::CONTROL_STATUS_BASE_ADDR_U1:network_pkg::CONTROL_STATUS_BASE_ADDR_U1 + 3]
    };
  }
  
  constraint c_apb_addr_alignment {
    paddr % 4 == 0; // Word-aligned addresses
  }
  
  // Constructor
  function new(string name = "snn_transaction");
    super.new(name);
    pixel_input = new[network_pkg::INPUT_SIZE];
    digit_spikes = new[network_pkg::OUTPUT_SIZE];
  endfunction
  
  // Convert to string for debugging
  virtual function string convert2string();
    string s;
    s = super.convert2string();
    s = {s, $sformatf("\nPixel Input: ")};
    foreach(pixel_input[i])
      s = {s, $sformatf("%0d ", pixel_input[i])};
    s = {s, $sformatf("\nLeak Factor: %0d", leak_factor)};
    s = {s, $sformatf("\nDigit Spikes: ")};
    foreach(digit_spikes[i])
      s = {s, $sformatf("%0b ", digit_spikes[i])};
    s = {s, $sformatf("\nAPB - paddr: 0x%0h, pwdata: 0x%0h, pwrite: %0b, prdata: 0x%0h, pready: %0b", 
                      paddr, pwdata, pwrite, prdata, pready)};
    return s;
  endfunction
  
  // Copy
  virtual function void do_copy(uvm_object rhs);
    snn_transaction rhs_cast;
    if(!$cast(rhs_cast, rhs)) begin
      `uvm_error("do_copy", "Cast failed")
      return;
    end
    super.do_copy(rhs);
    leak_factor = rhs_cast.leak_factor;
    paddr = rhs_cast.paddr;
    pwdata = rhs_cast.pwdata;
    pwrite = rhs_cast.pwrite;
    prdata = rhs_cast.prdata;
    pready = rhs_cast.pready;
    
    // Handle dynamic arrays
    pixel_input = new[rhs_cast.pixel_input.size()];
    foreach(rhs_cast.pixel_input[i])
      pixel_input[i] = rhs_cast.pixel_input[i];
      
    digit_spikes = new[rhs_cast.digit_spikes.size()];
    foreach(rhs_cast.digit_spikes[i])
      digit_spikes[i] = rhs_cast.digit_spikes[i];
  endfunction
  
  // Compare
  virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    snn_transaction rhs_cast;
    bit result;
    
    if(!$cast(rhs_cast, rhs)) begin
      `uvm_error("do_compare", "Cast failed")
      return 0;
    end
    
    result = super.do_compare(rhs, comparer) &&
             (leak_factor == rhs_cast.leak_factor) &&
             (paddr == rhs_cast.paddr) &&
             (pwdata == rhs_cast.pwdata) &&
             (pwrite == rhs_cast.pwrite) &&
             (prdata == rhs_cast.prdata) &&
             (pready == rhs_cast.pready);
    
    // Compare dynamic arrays
    if(pixel_input.size() != rhs_cast.pixel_input.size())
      return 0;
      
    foreach(pixel_input[i])
      if(pixel_input[i] != rhs_cast.pixel_input[i])
        return 0;
        
    if(digit_spikes.size() != rhs_cast.digit_spikes.size())
      return 0;
      
    foreach(digit_spikes[i])
      if(digit_spikes[i] != rhs_cast.digit_spikes[i])
        return 0;
        
    return result;
  endfunction
  
endclass