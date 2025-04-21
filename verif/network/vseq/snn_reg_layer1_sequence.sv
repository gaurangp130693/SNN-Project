class snn_reg_layer1_sequence extends snn_base_sequence;

  // Registration with factory
  `uvm_object_utils(snn_reg_layer1_sequence)

  int neuron_num;

  // Constructor
  function new(string name = "snn_reg_layer1_sequence");
    super.new(name);
  endfunction

  virtual task body();
    uvm_status_e status;
    uvm_reg_data_t data;
    bit [31:0] weight;
    bit [31:0] synapse_theshold;
    bit [31:0] neuron_theshold;

    super.body();

    // Write to control status register, bit-0 to enable the SNN
    weight   = 32'h0000_2000;
    synapse_theshold = 32'h0000_C000;
    neuron_theshold = 32'h0000_8000;
    for (int j = 0; j < 32; j++) begin
      reg_model.layer1_block.weight_regs[neuron_num*32 + j].write(status, weight);
      reg_model.layer1_block.spike_threshold_regs[neuron_num*32 + j].write(status, synapse_theshold);
    end
    reg_model.layer1_block.spike_threshold_regs[neuron_num].write(status, neuron_theshold);

    weight   = 32'h0000_0000;
    synapse_theshold = 32'h0000_0000;
    neuron_theshold = 32'h0000_0000;
    for (int i = 0; i < 16; i++) begin
      if(neuron_num == i) continue;

      for (int j = 0; j < 32; j++) begin
        reg_model.layer1_block.weight_regs[i*32 + j].write(status, weight);
        reg_model.layer1_block.spike_threshold_regs[i*32 + j].write(status, synapse_theshold);
      end
      reg_model.layer1_block.spike_threshold_regs[i].write(status, neuron_theshold);
    end
  endtask

endclass