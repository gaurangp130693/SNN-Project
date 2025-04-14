//============================================================================== 
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
  
endclass