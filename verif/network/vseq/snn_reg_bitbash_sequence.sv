//==============================================================================
//  File name: snn_reg_bitbash_sequence.sv
//  Author : Gaurang Pandey
//  Description: Register bitbash sequence
//==============================================================================
class snn_reg_bitbash_sequence extends snn_base_sequence;

  `uvm_object_utils(snn_reg_bitbash_sequence)

  // Configuration variables
  bit test_reset = 0;    // Test if register bits are reset to their reset value
  bit rand_order = 1;    // Randomize the order of bit testing
  // Since all registers are RW, we'll set both write tests to 1
  bit test_w1 = 1;  // Test if register bits can be set to 1
  bit test_w0 = 1;  // Test if register bits can be cleared to 0

  // Constructor
  function new(string name = "snn_reg_bitbash_sequence");
    super.new(name);
  endfunction

  // Pre-body
  virtual task pre_body();
    super.pre_body();
  endtask

  // Main body task
  virtual task body();
    uvm_reg       target_regs[$];
    uvm_reg       rg;
    uvm_status_e  status;
    uvm_reg_map   local_map;

    super.body();

    local_map = reg_model.get_default_map();

    // Get all registers to test
    reg_model.get_registers(target_regs);

    // Report the start of bitbash testing
    `uvm_info(get_type_name(), $sformatf("Running bitbash sequence on %0d registers", target_regs.size()), UVM_LOW);

    // Process each register in the list
    foreach (target_regs[i]) begin
      rg = target_regs[i];

      // Skip registers that don't have any bits
      if (rg.get_n_bits() == 0) continue;

      // Since we're only dealing with RW registers, we don't need to check access policy
      `uvm_info(get_type_name(), $sformatf("Bit-bashing register '%s'...", rg.get_full_name()), UVM_LOW);

      // Perform the register bitbash test
      do_reg_bitbash(rg, local_map);
    end
  endtask
  
  // Main bitbash procedure for a single register
  protected task do_reg_bitbash(uvm_reg rg, uvm_reg_map map);
    uvm_reg_data_t  val, exp, got;
    uvm_status_e    status;
    int             n_bits;

    n_bits = rg.get_n_bits();

    // Test if reset value can be read
    if (test_reset) begin
      // Read and check reset value
      exp = rg.get_reset();
      rg.read(status, val, UVM_FRONTDOOR, map, this);

      // Compare read value with expected reset value
      if (status != UVM_IS_OK) begin
        `uvm_error(get_type_name(), $sformatf("Status was %s when reading reset value from register '%s'",
                                           status.name(), rg.get_full_name()));
      end else if (val !== exp) begin
        `uvm_error(get_type_name(), $sformatf("Reset value mismatch for register '%s'. Expected 'h%h, got 'h%h",
                                           rg.get_full_name(), exp, val));
      end else begin
        `uvm_info(get_type_name(), $sformatf("Reset value 'h%h for register '%s' is correct",
                                          exp, rg.get_full_name()), UVM_HIGH);
      end
    end

    // Walking 1's test - Set each bit to 1 while others are 0
    if (test_w1) begin
      int order[int];
      int n;

      // Initialize the order array
      for (n = 0; n < n_bits; n++) begin
        order[n] = n;
      end

      // Randomize the order of bit testing if enabled
      // if (rand_order) begin
      //   order.shuffle();
      // end

      // For RW registers, first clear all bits
      rg.write(status, 0, UVM_FRONTDOOR, map, this);
      if (status != UVM_IS_OK) begin
        `uvm_error(get_type_name(), $sformatf("Status was %s when writing all zeros to register '%s'",
                                           status.name(), rg.get_full_name()));
      end

      // Test each bit position
      for (int i = 0; i < n_bits; i++) begin
        n = order[i];

        // Set only this bit
        val = (1 << n);

        // Write value to the register
        rg.write(status, val, UVM_FRONTDOOR, map, this);
        if (status != UVM_IS_OK) begin
          `uvm_error(get_type_name(), $sformatf("Status was %s when writing 'h%h to register '%s'",
                                             status.name(), val, rg.get_full_name()));
          continue;
        end

        // Read back the value
        rg.read(status, got, UVM_FRONTDOOR, map, this);
        if (status != UVM_IS_OK) begin
          `uvm_error(get_type_name(), $sformatf("Status was %s when reading register '%s' after writing 'h%h",
                                             status.name(), rg.get_full_name(), val));
          continue;
        end

        // For RW registers, expected value should exactly match what we wrote
        exp = val;

        // Compare the values
        if (got !== exp) begin
          `uvm_error(get_type_name(), $sformatf("Writing a 1 to bit %0d of register '%s' failed: Expected 'h%h, got 'h%h",
                                             n, rg.get_full_name(), exp, got));
        end else begin
          `uvm_info(get_type_name(), $sformatf("Writing a 1 to bit %0d of register '%s' passed: Got 'h%h as expected",
                                            n, rg.get_full_name(), got), UVM_HIGH);
        end
      end
    end

    // Walking 0's test - Set each bit to 0 while others are 1
    if (test_w0) begin
      int order[int];
      int n;
      uvm_reg_data_t mode;

      // Initialize the order array
      for (n = 0; n < n_bits; n++) begin
        order[n] = n;
      end

      // Randomize the order of bit testing if enabled
      // if (rand_order) begin
      //   order.shuffle();
      // end

      // Create a mask with all bits set
      mode = (n_bits == 64) ? {64{1'b1}} : ((1 << n_bits) - 1);

      // For RW registers, first set all bits
      rg.write(status, mode, UVM_FRONTDOOR, map, this);
      if (status != UVM_IS_OK) begin
        `uvm_error(get_type_name(), $sformatf("Status was %s when writing all ones to register '%s'",
                                           status.name(), rg.get_full_name()));
      end

      // Test each bit position
      for (int i = 0; i < n_bits; i++) begin
        n = order[i];

        // Set all bits except this one
        val = mode & ~(1 << n);

        // Write value to the register
        rg.write(status, val, UVM_FRONTDOOR, map, this);
        if (status != UVM_IS_OK) begin
          `uvm_error(get_type_name(), $sformatf("Status was %s when writing 'h%h to register '%s'",
                                             status.name(), val, rg.get_full_name()));
          continue;
        end

        // Read back the value
        rg.read(status, got, UVM_FRONTDOOR, map, this);
        if (status != UVM_IS_OK) begin
          `uvm_error(get_type_name(), $sformatf("Status was %s when reading register '%s' after writing 'h%h",
                                             status.name(), rg.get_full_name(), val));
          continue;
        end

        // For RW registers, expected value should exactly match what we wrote
        exp = val;

        // Compare the values
        if (got !== exp) begin
          `uvm_error(get_type_name(), $sformatf("Writing a 0 to bit %0d of register '%s' failed: Expected 'h%h, got 'h%h",
                                             n, rg.get_full_name(), exp, got));
        end else begin
          `uvm_info(get_type_name(), $sformatf("Writing a 0 to bit %0d of register '%s' passed: Got 'h%h as expected",
                                            n, rg.get_full_name(), got), UVM_HIGH);
        end
      end
    end

    // Write the reset value back to the register to restore its state
    rg.write(status, rg.get_reset(), UVM_FRONTDOOR, map, this);
  endtask
endclass