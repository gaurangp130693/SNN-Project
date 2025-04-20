//==============================================================================
//  File name: snn_scoreboard.sv
//  Author : Gaurang Pandey
//  Description: UVM Scoreboard for SNN design
//==============================================================================

class snn_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(snn_scoreboard)
  
  // Analysis ports
  uvm_analysis_imp_actual #(snn_transaction, snn_scoreboard) actual_export;
  uvm_analysis_imp_apb #(apb_transaction, snn_scoreboard) apb_export;
  
  // Reference model
  snn_reference_model ref_model;

  // Virtual interface
  virtual snn_if vif;

  // CSR Register Values
  logic [31:0] weight_reg_u0[((network_pkg::INPUT_SIZE * network_pkg::HIDDEN_SIZE) / 4) - 1:0];
  logic [31:0] spike_threshold_u0[((network_pkg::INPUT_SIZE * network_pkg::HIDDEN_SIZE) / 4) - 1:0];
  logic [31:0] neuron_threshold_u0[network_pkg::HIDDEN_SIZE-1:0];
  
  logic [31:0] weight_reg_u1[((network_pkg::HIDDEN_SIZE * network_pkg::OUTPUT_SIZE) / 4) - 1:0];
  logic [31:0] spike_threshold_u1[((network_pkg::HIDDEN_SIZE * network_pkg::OUTPUT_SIZE) / 4) - 1:0];
  logic [31:0] neuron_threshold_u1[network_pkg::OUTPUT_SIZE-1:0];
  
  // Control status registers
  logic [31:0] cntrl_status_csr_u0;
  logic [31:0] cntrl_status_csr_u1;
  
  // Statistics
  int num_transactions;
  int num_matches;
  int num_mismatches;
  bit csr_configured;
  
  // Queue to store pending transactions
  snn_transaction pending_transactions[$];
  
  // Constructor
  function new(string name = "snn_scoreboard", uvm_component parent);
    super.new(name, parent);
    actual_export = new("actual_export", this);
    apb_export = new("apb_export", this);
    num_transactions = 0;
    num_matches = 0;
    num_mismatches = 0;
    csr_configured = 0;
  endfunction
  
  // Build phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ref_model = snn_reference_model::type_id::create("ref_model", this);

    if(!uvm_config_db#(virtual snn_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not found")
  endfunction
  
  // Function to handle APB transactions for CSR configuration
  virtual function void write_apb(apb_transaction tr);
    int idx;
    // Only process write transactions
    if (!tr.pwrite) return;
    
    // Determine which CSR register to update based on address
    if (tr.paddr >= network_pkg::LAYER_WEIGHT_BASE_ADDR_U0 && 
        tr.paddr < network_pkg::LAYER_WEIGHT_BASE_ADDR_U0 + 
        ((network_pkg::INPUT_SIZE * network_pkg::HIDDEN_SIZE * 4) / 4)) begin
      
      idx = (tr.paddr - network_pkg::LAYER_WEIGHT_BASE_ADDR_U0) >> 2;
      weight_reg_u0[idx] = tr.pwdata;
      `uvm_info(get_type_name(), $sformatf("Updated U0 weight reg[%0d] = 0x%8h", idx, tr.pwdata), UVM_HIGH)
    end
    else if (tr.paddr >= network_pkg::LAYER_SPIKE_THRESH_BASE_ADDR_U0 && 
             tr.paddr < network_pkg::LAYER_SPIKE_THRESH_BASE_ADDR_U0 + 
             ((network_pkg::INPUT_SIZE * network_pkg::HIDDEN_SIZE * 4) / 4)) begin
      
      idx = (tr.paddr - network_pkg::LAYER_SPIKE_THRESH_BASE_ADDR_U0) >> 2;
      spike_threshold_u0[idx] = tr.pwdata;
      `uvm_info(get_type_name(), $sformatf("Updated U0 spike threshold[%0d] = 0x%8h", idx, tr.pwdata), UVM_HIGH)
    end
    else if (tr.paddr >= network_pkg::LAYER_NEURON_THRESH_BASE_ADDR_U0 && 
             tr.paddr < network_pkg::LAYER_NEURON_THRESH_BASE_ADDR_U0 + 
             (network_pkg::HIDDEN_SIZE * 4)) begin
      
      idx = (tr.paddr - network_pkg::LAYER_NEURON_THRESH_BASE_ADDR_U0) >> 2;
      neuron_threshold_u0[idx] = tr.pwdata;
      `uvm_info(get_type_name(), $sformatf("Updated U0 neuron threshold[%0d] = 0x%8h", idx, tr.pwdata), UVM_HIGH)
    end
    else if (tr.paddr == network_pkg::CONTROL_STATUS_BASE_ADDR_U0) begin
      cntrl_status_csr_u0 = tr.pwdata;
      `uvm_info(get_type_name(), $sformatf("Updated U0 control status = 0x%8h", tr.pwdata), UVM_HIGH)
    end
    // Layer U1 registers
    else if (tr.paddr >= network_pkg::LAYER_WEIGHT_BASE_ADDR_U1 && 
             tr.paddr < network_pkg::LAYER_WEIGHT_BASE_ADDR_U1 + 
             ((network_pkg::HIDDEN_SIZE * network_pkg::OUTPUT_SIZE * 4) / 4)) begin
      
      idx = (tr.paddr - network_pkg::LAYER_WEIGHT_BASE_ADDR_U1) >> 2;
      weight_reg_u1[idx] = tr.pwdata;
      `uvm_info(get_type_name(), $sformatf("Updated U1 weight reg[%0d] = 0x%8h", idx, tr.pwdata), UVM_HIGH)
    end
    else if (tr.paddr >= network_pkg::LAYER_SPIKE_THRESH_BASE_ADDR_U1 && 
             tr.paddr < network_pkg::LAYER_SPIKE_THRESH_BASE_ADDR_U1 + 
             ((network_pkg::HIDDEN_SIZE * network_pkg::OUTPUT_SIZE * 4) / 4)) begin
      
      idx = (tr.paddr - network_pkg::LAYER_SPIKE_THRESH_BASE_ADDR_U1) >> 2;
      spike_threshold_u1[idx] = tr.pwdata;
      `uvm_info(get_type_name(), $sformatf("Updated U1 spike threshold[%0d] = 0x%8h", idx, tr.pwdata), UVM_HIGH)
    end
    else if (tr.paddr >= network_pkg::LAYER_NEURON_THRESH_BASE_ADDR_U1 && 
             tr.paddr < network_pkg::LAYER_NEURON_THRESH_BASE_ADDR_U1 + 
             (network_pkg::OUTPUT_SIZE * 4)) begin
      
      idx = (tr.paddr - network_pkg::LAYER_NEURON_THRESH_BASE_ADDR_U1) >> 2;
      neuron_threshold_u1[idx] = tr.pwdata;
      `uvm_info(get_type_name(), $sformatf("Updated U1 neuron threshold[%0d] = 0x%8h", idx, tr.pwdata), UVM_HIGH)
    end
    else if (tr.paddr == network_pkg::CONTROL_STATUS_BASE_ADDR_U1) begin
      cntrl_status_csr_u1 = tr.pwdata;
      `uvm_info(get_type_name(), $sformatf("Updated U1 control status = 0x%8h", tr.pwdata), UVM_HIGH)
    end
    
    // Check if both CSRs are configured
    if (cntrl_status_csr_u0[0] && cntrl_status_csr_u1[0]) begin
      if (!csr_configured) begin
        csr_configured = 1;
        `uvm_info(get_type_name(), "CSR configuration complete, initializing reference model", UVM_MEDIUM)
        
        // Initialize reference model with CSR values
        ref_model.init_from_csr_registers(
          weight_reg_u0, 
          spike_threshold_u0, 
          neuron_threshold_u0,
          weight_reg_u1, 
          spike_threshold_u1, 
          neuron_threshold_u1
        );
      end
    end

    snn_vif.cntrl_status_csr_u0 = cntrl_status_csr_u0;
    snn_vif.cntrl_status_csr_u1 = cntrl_status_csr_u1;
    snn_vif.weight_reg_u0 = weight_reg_u0;
    snn_vif.spike_threshold_u0 = spike_threshold_u0;
    snn_vif.neuron_threshold_u0 = neuron_threshold_u0;
    snn_vif.weight_reg_u1 = weight_reg_u1;
    snn_vif.spike_threshold_u1 = spike_threshold_u1;
    snn_vif.neuron_threshold_u1 = neuron_threshold_u1;
  endfunction
  
  // Function to handle SNN transaction from monitor
  virtual function void write_actual(snn_transaction tr);
    num_transactions++; 
    compare_transaction(tr);
  endfunction
  
  // Compare actual transaction with expected results
  virtual function void compare_transaction(snn_transaction tr);
    logic expected_spikes[];
    string result_str;
    bit match = 1;
    
    // Process transaction in reference model
    ref_model.process_transaction(tr, expected_spikes);
    
    // Compare outputs
    result_str = "\nComparison results:";
    result_str = {result_str, "\nExpected spikes: "};
    foreach (expected_spikes[i]) begin
      result_str = {result_str, $sformatf("%0b ", expected_spikes[i])};
      if (expected_spikes[i] !== tr.digit_spikes[i]) begin
        match = 0;
      end
    end
    
    result_str = {result_str, "\nActual spikes:   "};
    foreach (tr.digit_spikes[i]) begin
      result_str = {result_str, $sformatf("%0b ", tr.digit_spikes[i])};
    end
    
    // Update statistics
    if (match) begin
      num_matches++;
      `uvm_info(get_type_name(), 
                $sformatf("Transaction %0d MATCH!%s", num_transactions, result_str), 
                UVM_MEDIUM)
    end else begin
      num_mismatches++;
      `uvm_error(get_type_name(), 
                 $sformatf("Transaction %0d MISMATCH!%s", num_transactions, result_str))
    end
  endfunction
  
  // Check phase - report statistics
  virtual function void check_phase(uvm_phase phase);
    super.check_phase(phase);
    
    `uvm_info(get_type_name(), 
              $sformatf("\n----- SNN Scoreboard Statistics -----\n" 
                        "Total Transactions: %0d\n" 
                        "Matches:            %0d\n" 
                        "Mismatches:         %0d\n" 
                        "--------------------------------------", 
                        num_transactions, num_matches, num_mismatches), 
              UVM_LOW)
    
    if (num_mismatches > 0) begin
      `uvm_error(get_type_name(), $sformatf("Test FAILED with %0d mismatches", num_mismatches))
    end else begin
      `uvm_info(get_type_name(), "Test PASSED - All transactions matched", UVM_LOW)
    end
  endfunction
  
  // Reset the scoreboard
  virtual function void reset();
    num_transactions = 0;
    num_matches = 0;
    num_mismatches = 0;
    csr_configured = 0;
    pending_transactions.delete();
    ref_model.reset();
  endfunction
endclass