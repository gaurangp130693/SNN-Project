//==============================================================================
//  File name: snn_reg_rand_sequence.sv
//  Description: Generic sequence to test all SNN registers via APB
//==============================================================================

class snn_reg_rand_sequence extends snn_base_sequence;
  `uvm_object_utils(snn_reg_rand_sequence)

  function new(string name = "snn_reg_rand_sequence");
    super.new(name);
  endfunction

  virtual task body();
    uvm_status_e status;
    uvm_reg_data_t data;
    uvm_reg regs[$];

    super.body();
    if (reg_model == null)
      `uvm_fatal(get_type_name(), "Register reg_model handle is null")

    // Reset the registers to defaults
    reg_model.reset();

    // Get all registers in the reg_model
    reg_model.get_registers(regs);

    // Example: Write and read back from all registers
    foreach (regs[i]) begin
      // Skip read-only registers for write
      if (regs[i].get_rights() != "RO") begin
        data = $urandom;
        `uvm_info(get_type_name(),
                 $sformatf("Writing 0x%h to register %s", data, regs[i].get_full_name()),
                 UVM_MEDIUM)
        regs[i].write(status, data, .parent(this));

        // Check status
        if (status != UVM_IS_OK)
          `uvm_error(get_type_name(),
                    $sformatf("Write to %s failed with status %s",
                             regs[i].get_full_name(), status.name()))
      end

      // Read back all registers
      `uvm_info(get_type_name(),
               $sformatf("Reading from register %s", regs[i].get_full_name()),
               UVM_MEDIUM)
      regs[i].read(status, data, .parent(this));

      // Check status
      if (status != UVM_IS_OK)
        `uvm_error(get_type_name(),
                  $sformatf("Read from %s failed with status %s",
                           regs[i].get_full_name(), status.name()))
      else
        `uvm_info(get_type_name(),
                 $sformatf("Read value 0x%h from %s", data, regs[i].get_full_name()),
                 UVM_MEDIUM)
    end
  endtask
endclass