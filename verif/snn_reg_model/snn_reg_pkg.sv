//==============================================================================
//  File name: snn_reg_model.sv
//  Description: UVM RAL model for SNN register blocks
//==============================================================================

package snn_reg_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  //----------------------------------------------------------------------------
  // Register definitions for an SNN layer
  //----------------------------------------------------------------------------
  
  // Weight register
  class weight_reg_c extends uvm_reg;
    `uvm_object_utils(weight_reg_c)
    
    rand uvm_reg_field weight;
    
    function new(string name = "weight_reg_c");
      super.new(name, 32, UVM_NO_COVERAGE);
    endfunction
    
    virtual function void build();
      weight = uvm_reg_field::type_id::create("weight");
      weight.configure(this, 32, 0, "RW", 0, 32'h0, 1, 1, 1);
    endfunction
  endclass

  // Spike threshold register
  class spike_threshold_reg_c extends uvm_reg;
    `uvm_object_utils(spike_threshold_reg_c)
    
    rand uvm_reg_field threshold;
    
    function new(string name = "spike_threshold_reg_c");
      super.new(name, 32, UVM_NO_COVERAGE);
    endfunction
    
    virtual function void build();
      threshold = uvm_reg_field::type_id::create("threshold");
      threshold.configure(this, 32, 0, "RW", 0, 32'h0, 1, 1, 1);
    endfunction
  endclass

  // Neuron threshold register
  class neuron_threshold_reg_c extends uvm_reg;
    `uvm_object_utils(neuron_threshold_reg_c)
    
    rand uvm_reg_field threshold;
    
    function new(string name = "neuron_threshold_reg_c");
      super.new(name, 32, UVM_NO_COVERAGE);
    endfunction
    
    virtual function void build();
      threshold = uvm_reg_field::type_id::create("threshold");
      threshold.configure(this, 32, 0, "RW", 0, 32'h0, 1, 1, 1);
    endfunction
  endclass

  // Control/Status register
  class control_status_reg_c extends uvm_reg;
    `uvm_object_utils(control_status_reg_c)
    
    rand uvm_reg_field control_status;
    
    function new(string name = "control_status_reg_c");
      super.new(name, 32, UVM_NO_COVERAGE);
    endfunction
    
    virtual function void build();
      control_status = uvm_reg_field::type_id::create("control_status");
      control_status.configure(this, 32, 0, "RW", 0, 32'h0, 1, 1, 1);
    endfunction
  endclass

  //----------------------------------------------------------------------------
  // SNN Layer block for a single CSR instance
  //----------------------------------------------------------------------------
  class snn_layer_block_c extends uvm_reg_block;
    `uvm_object_utils(snn_layer_block_c)
    
    rand weight_reg_c weight_regs[];
    rand spike_threshold_reg_c spike_threshold_regs[];
    rand neuron_threshold_reg_c neuron_threshold_regs[];
    rand control_status_reg_c control_status_reg;
    
    int input_size;
    int output_size;
    int weight_base_addr;
    int spike_thresh_base_addr;
    int neuron_thresh_base_addr;
    int control_status_base_addr;
    
    function new(string name = "snn_layer_block_c");
      super.new(name, UVM_NO_COVERAGE);
    endfunction
    
    virtual function void build(int input_size, int output_size, 
                               int weight_base_addr, int spike_thresh_base_addr,
                               int neuron_thresh_base_addr, int control_status_base_addr);
      this.input_size = input_size;
      this.output_size = output_size;
      this.weight_base_addr = weight_base_addr;
      this.spike_thresh_base_addr = spike_thresh_base_addr;
      this.neuron_thresh_base_addr = neuron_thresh_base_addr;
      this.control_status_base_addr = control_status_base_addr;
      
      // Default APB map
      default_map = create_map("default_map", 0, 4, UVM_LITTLE_ENDIAN);
      
      // Calculate number of weight/spike registers (4 values per register)
      int num_weight_regs = ((input_size * output_size) + 3) / 4;
      
      // Create weight registers
      weight_regs = new[num_weight_regs];
      for (int i = 0; i < num_weight_regs; i++) begin
        weight_regs[i] = weight_reg_c::type_id::create($sformatf("weight_reg_%0d", i));
        weight_regs[i].configure(this);
        weight_regs[i].build();
        default_map.add_reg(weight_regs[i], weight_base_addr + (i*4));
      end
      
      // Create spike threshold registers
      spike_threshold_regs = new[num_weight_regs];
      for (int i = 0; i < num_weight_regs; i++) begin
        spike_threshold_regs[i] = spike_threshold_reg_c::type_id::create($sformatf("spike_threshold_reg_%0d", i));
        spike_threshold_regs[i].configure(this);
        spike_threshold_regs[i].build();
        default_map.add_reg(spike_threshold_regs[i], spike_thresh_base_addr + (i*4));
      end
      
      // Create neuron threshold registers
      neuron_threshold_regs = new[output_size];
      for (int i = 0; i < output_size; i++) begin
        neuron_threshold_regs[i] = neuron_threshold_reg_c::type_id::create($sformatf("neuron_threshold_reg_%0d", i));
        neuron_threshold_regs[i].configure(this);
        neuron_threshold_regs[i].build();
        default_map.add_reg(neuron_threshold_regs[i], neuron_thresh_base_addr + (i*4));
      end
      
      // Create control/status register
      control_status_reg = control_status_reg_c::type_id::create("control_status_reg");
      control_status_reg.configure(this);
      control_status_reg.build();
      default_map.add_reg(control_status_reg, control_status_base_addr);
      
      // Lock the model
      lock_model();
    endfunction
  endclass

  //----------------------------------------------------------------------------
  // Top-level SNN register model
  //----------------------------------------------------------------------------
  class snn_reg_block_c extends uvm_reg_block;
    `uvm_object_utils(snn_reg_block_c)
    
    rand snn_layer_block_c layer0_block;
    rand snn_layer_block_c layer1_block;
    
    function new(string name = "snn_reg_block_c");
      super.new(name, UVM_NO_COVERAGE);
    endfunction
    
    virtual function void build();
      // Create default map
      default_map = create_map("default_map", 0, 4, UVM_LITTLE_ENDIAN);
      
      // Create and configure the first layer block
      layer0_block = snn_layer_block_c::type_id::create("layer0_block");
      layer0_block.configure(this);
      layer0_block.build(64, 32,            // INPUT_SIZE, OUTPUT_SIZE
                        16'h0000,           // LAYER_WEIGHT_BASE_ADDR_U0
                        16'h1000,           // LAYER_SPIKE_THRESH_BASE_ADDR_U0
                        16'h2000,           // LAYER_NEURON_THRESH_BASE_ADDR_U0
                        16'h3000);          // CONTROL_STATUS_BASE_ADDR_U0
      default_map.add_submap(layer0_block.default_map, 0);
      
      // Create and configure the second layer block
      layer1_block = snn_layer_block_c::type_id::create("layer1_block");
      layer1_block.configure(this);
      layer1_block.build(32, 10,            // INPUT_SIZE, OUTPUT_SIZE
                        16'h6000,           // LAYER_WEIGHT_BASE_ADDR_U1
                        16'h7000,           // LAYER_SPIKE_THRESH_BASE_ADDR_U1
                        16'h8000,           // LAYER_NEURON_THRESH_BASE_ADDR_U1
                        16'h9000);          // CONTROL_STATUS_BASE_ADDR_U1
      default_map.add_submap(layer1_block.default_map, 0);
      
      // Lock the model
      lock_model();
    endfunction
  endclass

endpackage
