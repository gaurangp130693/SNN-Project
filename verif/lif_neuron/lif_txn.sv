//==============================================================================
//  File name: lif_txn.sv
//  Author    : Gaurang Pandey
//  Description: Transaction class for LIF neuron. Carries input config and spike.
//==============================================================================

`ifndef LIF_TXN_SV
`define LIF_TXN_SV

class lif_txn extends uvm_sequence_item;

    rand bit        enable;
    rand bit        input_spike;
    rand bit [15:0] neuron_config;

    bit             output_spike;
    bit [15:0]      membrane_potential;

    `uvm_object_utils(lif_txn)

    function new(string name = "lif_txn");
        super.new(name);
    endfunction

    function void do_print(uvm_printer printer);
        super.do_print(printer);
        printer.print_field_int("enable", enable, $bits(enable), UVM_DEC);
        printer.print_field_int("input_spike", input_spike, $bits(input_spike), UVM_DEC);
        printer.print_field_int("neuron_config", neuron_config, $bits(neuron_config), UVM_DEC);
        printer.print_field_int("output_spike", output_spike, $bits(output_spike), UVM_DEC);
        printer.print_field_int("membrane_potential", membrane_potential, $bits(membrane_potential), UVM_DEC);
    endfunction

endclass : lif_txn

`endif
