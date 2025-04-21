//==============================================================================
//  File name: snn_scoreboard.sv
//  Author : Gaurang Pandey
//  Description: UVM Scoreboard for SNN design
//==============================================================================

class snn_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(snn_scoreboard)

  `uvm_analysis_imp_decl(_actual)
  `uvm_analysis_imp_decl(_apb)

  // Analysis ports
  uvm_analysis_imp_actual #(snn_transaction, snn_scoreboard) actual_export;
  uvm_analysis_imp_apb #(apb_transaction, snn_scoreboard) apb_export;

  // Statistics
  int num_transactions;
  int num_matches;
  int num_mismatches;
  bit csr_configured;
  int neuron_num;

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
  endfunction

  // Function to handle APB transactions for CSR configuration
  virtual function void write_apb(apb_transaction tr);
    // Process APB
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

    expected_spikes = new[network_pkg::OUTPUT_SIZE];
    foreach (expected_spikes[i]) begin
      if(i == neuron_num) expected_spikes[i] = 1;
      else  expected_spikes[i] = 0;
    end

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
              $sformatf({"\n----- SNN Scoreboard Statistics -----\n",
                        "Total Transactions: %0d\n",
                        "Matches:            %0d\n",
                        "Mismatches:         %0d\n",
                        "--------------------------------------"},
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
  endfunction
endclass