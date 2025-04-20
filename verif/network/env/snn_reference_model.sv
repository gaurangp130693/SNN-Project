//==============================================================================
//  File name: snn_reference_model.sv
//  Author : Gaurang Pandey
//  Description: SNN Reference Model for expected transaction generation
//==============================================================================

class snn_reference_model extends uvm_component;
  `uvm_component_utils(snn_reference_model)
  
  // Network parameters
  protected int INPUT_SIZE;
  protected int HIDDEN_SIZE;
  protected int OUTPUT_SIZE;
  protected int SPIKE_WINDOW;
  protected int MEMBRANE_WIDTH;
  protected int WEIGHT_WIDTH;
  protected int THRESHOLD;
  
  // Input processing
  protected logic [$clog2(SPIKE_WINDOW)-1:0] input_counters[];
  
  // Model internal state - use full width as in RTL
  protected logic [15:0] hidden_potentials[]; // Membrane potentials for hidden layer
  protected logic [15:0] output_potentials[]; // Membrane potentials for output layer
  
  // CSR values - weights and thresholds
  protected logic [7:0] hidden_weights[][];      // [INPUT_SIZE][HIDDEN_SIZE]
  protected logic [7:0] hidden_spike_thresh[][]; // [INPUT_SIZE][HIDDEN_SIZE]
  protected logic [15:0] hidden_neuron_thresh[]; // [HIDDEN_SIZE]
  
  protected logic [7:0] output_weights[][];      // [HIDDEN_SIZE][OUTPUT_SIZE]
  protected logic [7:0] output_spike_thresh[][]; // [HIDDEN_SIZE][OUTPUT_SIZE]
  protected logic [15:0] output_neuron_thresh[]; // [OUTPUT_SIZE]
  
  // Constructor
  function new(string name = "snn_reference_model", uvm_component parent);
    super.new(name, parent);
    
    // Set default network parameters based on packages
    INPUT_SIZE = network_pkg::INPUT_SIZE;
    HIDDEN_SIZE = network_pkg::HIDDEN_SIZE;
    OUTPUT_SIZE = network_pkg::OUTPUT_SIZE;
    SPIKE_WINDOW = network_pkg::SPIKE_WINDOW;
    MEMBRANE_WIDTH = neuron_pkg::MEMBRANE_WIDTH;
    WEIGHT_WIDTH = neuron_pkg::WEIGHT_WIDTH;
    THRESHOLD = neuron_pkg::THRESHOLD;
    
    // Initialize arrays
    input_counters = new[INPUT_SIZE];
    hidden_potentials = new[HIDDEN_SIZE];
    output_potentials = new[OUTPUT_SIZE];
    
    hidden_weights = new[INPUT_SIZE];
    hidden_spike_thresh = new[INPUT_SIZE];
    foreach (hidden_weights[i]) begin
      hidden_weights[i] = new[HIDDEN_SIZE];
      hidden_spike_thresh[i] = new[HIDDEN_SIZE];
    end
    hidden_neuron_thresh = new[HIDDEN_SIZE];
    
    output_weights = new[HIDDEN_SIZE];
    output_spike_thresh = new[HIDDEN_SIZE];
    foreach (output_weights[i]) begin
      output_weights[i] = new[OUTPUT_SIZE];
      output_spike_thresh[i] = new[OUTPUT_SIZE];
    end
    output_neuron_thresh = new[OUTPUT_SIZE];
    
    // Initialize states to zero
    foreach (input_counters[i]) input_counters[i] = 0;
    foreach (hidden_potentials[i]) hidden_potentials[i] = 0;
    foreach (output_potentials[i]) output_potentials[i] = 0;
  endfunction
  
  // Initialize the reference model from 32-bit CSR register values
  function void init_from_csr_registers(
    logic [31:0] weight_reg_u0[], 
    logic [31:0] spike_threshold_u0[], 
    logic [31:0] neuron_threshold_u0[],
    logic [31:0] weight_reg_u1[], 
    logic [31:0] spike_threshold_u1[], 
    logic [31:0] neuron_threshold_u1[]
  );
    int idx;
    int offset;

    // Extract hidden layer (u0) weights and thresholds
    for (int i = 0; i < INPUT_SIZE; i++) begin
      for (int j = 0; j < HIDDEN_SIZE; j++) begin
        idx = (i * HIDDEN_SIZE + j) >> 2;  // Divide by 4
        offset = (j % 4) * 8;              // Byte offset in 32-bit word
        hidden_weights[i][j] = (weight_reg_u0[idx] >> offset) & 8'hFF;
        hidden_spike_thresh[i][j] = (spike_threshold_u0[idx] >> offset) & 8'hFF;
      end
    end
    
    // Extract hidden layer neuron thresholds
    for (int j = 0; j < HIDDEN_SIZE; j++) begin
      hidden_neuron_thresh[j] = neuron_threshold_u0[j] & 16'hFFFF;
    end
    
    // Extract output layer (u1) weights and thresholds
    for (int i = 0; i < HIDDEN_SIZE; i++) begin
      for (int j = 0; j < OUTPUT_SIZE; j++) begin
        idx = (i * OUTPUT_SIZE + j) >> 2;  // Divide by 4
        offset = (j % 4) * 8;              // Byte offset in 32-bit word
        output_weights[i][j] = (weight_reg_u1[idx] >> offset) & 8'hFF;
        output_spike_thresh[i][j] = (spike_threshold_u1[idx] >> offset) & 8'hFF;
      end
    end
    
    // Extract output layer neuron thresholds
    for (int j = 0; j < OUTPUT_SIZE; j++) begin
      output_neuron_thresh[j] = neuron_threshold_u1[j] & 16'hFFFF;
    end
  endfunction
  
  // Reset the internal state
  function void reset();
    foreach (input_counters[i]) input_counters[i] = 0;
    foreach (hidden_potentials[i]) hidden_potentials[i] = 0;
    foreach (output_potentials[i]) output_potentials[i] = 0;
  endfunction
  
  // Calculate input-to-spike conversion based on rate coding
  // Similar to input_processor module in RTL
  protected function logic [INPUT_SIZE-1:0] pixel_to_spikes(logic [7:0] pixel_values[INPUT_SIZE-1:0]);
    logic [INPUT_SIZE-1:0] spikes;
    
    for (int i = 0; i < INPUT_SIZE; i++) begin
      // Compute dynamic threshold (pixel_value * SPIKE_WINDOW / 256)
      logic [$clog2(SPIKE_WINDOW):0] threshold;  // Extra bit to avoid overflow
      threshold = (pixel_values[i] * SPIKE_WINDOW) >> 8; // Equivalent to / 256
      
      // Generate spike based on pixel intensity threshold
      spikes[i] = (input_counters[i] < threshold);
      
      // Update counter for next time
      if (input_counters[i] >= SPIKE_WINDOW-1)
        input_counters[i] = 0;
      else
        input_counters[i] = input_counters[i] + 1;
    end
    
    return spikes;
  endfunction
  
  // Synapse model
  protected function logic synapse_output(
    logic pre_spike, 
    logic [7:0] weight, 
    logic [7:0] threshold
  );
    // Simplified synapse model - in reality there's a time window
    return (pre_spike && (weight > threshold));
  endfunction
  
  // LIF neuron model
  protected function logic neuron_update(
    ref logic [15:0] potential,
    logic input_spike,
    logic [15:0] threshold,
    logic [7:0] leak_factor
  );
    logic output_spike;
    logic [15:0] leak_value;
    
    // Compute leak (potential >> leak_factor)
    leak_value = (potential >> leak_factor);
    
    // Check for spike generation
    if (potential >= threshold) begin
      output_spike = 1;
      potential = 0; // Reset after spike
    end else begin
      // Update potential with leak and input contribution
      potential = potential + (input_spike ? (threshold >> 2) : 0) - leak_value;
      output_spike = 0;
    end
    
    return output_spike;
  endfunction
  
  // Process pixel inputs to compute expected outputs
  function void process_transaction(snn_transaction tr, ref logic expected_spikes[]);
    // Local variables
    logic [INPUT_SIZE-1:0] input_spikes;
    logic [HIDDEN_SIZE-1:0] hidden_layer_inputs;
    logic [HIDDEN_SIZE-1:0] hidden_spikes;
    logic [OUTPUT_SIZE-1:0] output_layer_inputs;
    
    expected_spikes = new[OUTPUT_SIZE];
    
    // Convert pixel values to input spikes (rate coding)
    input_spikes = pixel_to_spikes(tr.pixel_input);
    
    // Process synaptic connections to hidden layer
    for (int h = 0; h < HIDDEN_SIZE; h++) begin
      // Default no spike input to this hidden neuron
      hidden_layer_inputs[h] = 0;
      
      // Check each input synapse
      for (int i = 0; i < INPUT_SIZE; i++) begin
        // If any synapse fires, the OR gate sets input to 1
        if (synapse_output(input_spikes[i], hidden_weights[i][h], hidden_spike_thresh[i][h])) begin
          hidden_layer_inputs[h] = 1;
          break; // OR behavior - one is enough
        end
      end
      
      // Update hidden neuron and check for spike
      hidden_spikes[h] = neuron_update(
        hidden_potentials[h], 
        hidden_layer_inputs[h],
        hidden_neuron_thresh[h],
        tr.leak_factor
      );
    end
    
    // Process synaptic connections to output layer
    for (int o = 0; o < OUTPUT_SIZE; o++) begin
      // Default no spike input to this output neuron
      output_layer_inputs[o] = 0;
      
      // Check each hidden layer synapse
      for (int h = 0; h < HIDDEN_SIZE; h++) begin
        // If any synapse fires, the OR gate sets input to 1
        if (synapse_output(hidden_spikes[h], output_weights[h][o], output_spike_thresh[h][o])) begin
          output_layer_inputs[o] = 1;
          break; // OR behavior - one is enough
        end
      end
      
      // Update output neuron and check for spike
      expected_spikes[o] = neuron_update(
        output_potentials[o], 
        output_layer_inputs[o],
        output_neuron_thresh[o],
        tr.leak_factor
      );
    end
  endfunction
endclass