//============================================================================== 
//  File name: apb_types.sv 
//  Author : Gaurang Pandey 
//  Description: Type definitions for APB transactions
//==============================================================================

package apb_pkg;

  // Import UVM package
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  
  // APB transaction types
  typedef enum {
    APB_READ,
    APB_WRITE
  } apb_operation_t;
  
  // Include component files 
  `include "apb_transaction.sv"
  `include "apb_sequencer.sv"
  `include "apb_driver.sv"
  `include "apb_monitor.sv"
  `include "apb_agent.sv"
  `include "apb_reg_adapter.sv"
  `include "apb_reg_predictor.sv"

  `include "apb_sequences.sv"
  
endpackage