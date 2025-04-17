//==============================================================================
// Example usage with UVM test/sequence
//==============================================================================

module snn_ral_test_example;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import snn_reg_pkg::*;

  // Example test class
  class snn_reg_test extends uvm_test;
    `uvm_component_utils(snn_reg_test)
    
    snn_reg_block_c snn_regmodel;
    
    function new(string name = "snn_reg_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      
      // Create and build the register model
      snn_regmodel = snn_reg_block_c::type_id::create("snn_regmodel");
      snn_regmodel.build();
      
      // Set the register model to use an APB adapter (not shown)
      // snn_regmodel.default_map.set_sequencer(apb_sequencer, apb_adapter);
    endfunction
    
    // Example task showing how to access the registers
    task test_registers();
      uvm_status_e status;
      uvm_reg_data_t data;
      
      // Write to layer0 weight register
      snn_regmodel.layer0_block.weight_regs[0].write(status, 32'hDEADBEEF);
      
      // Read from layer1 neuron threshold register
      snn_regmodel.layer1_block.neuron_threshold_regs[5].read(status, data);
      
      // Write to layer1 control status register
      snn_regmodel.layer1_block.control_status_reg.write(status, 32'h01234567);
    endtask

  endclass
    
endmodule