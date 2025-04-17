//==============================================================================
//  File name: snn_env.sv
//  Author : Gaurang Pandey
//  Description: Environment for SNN UVM testbench
//==============================================================================

class snn_env extends uvm_env;

  `uvm_component_utils(snn_env)

  snn_agent snn_agent_h;
  apb_agent apb_agent_h;
  snn_vseqr snn_vseqr_h;

  snn_reg_block_c reg_model;
  apb_reg_adapter reg_adapter;
  apb_reg_predictor reg_predictor;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    snn_agent_h = snn_agent::type_id::create("snn_agent_h", this);
    apb_agent_h = apb_agent::type_id::create("apb_agent_h", this);
    snn_vseqr_h = snn_vseqr::type_id::create("snn_vseqr_h", this);

    // Create register adapter and predictor
    reg_adapter = apb_reg_adapter::type_id::create("reg_adapter");
    reg_predictor = apb_reg_predictor::type_id::create("reg_predictor", this);

    // Create and build the register model
    reg_model = snn_reg_block_c::type_id::create("reg_model");
    reg_model.build();
    reg_model.reset();
    reg_model.lock_model();
    reg_model.default_map.set_check_on_read(1);
    uvm_config_db#(snn_reg_block_c#())::set(uvm_root::get(), "*", "reg_model", reg_model);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    snn_vseqr_h.snn_seqr = snn_agent_h.sequencer;
    snn_vseqr_h.apb_seqr = apb_agent_h.sequencer;

    if (reg_model != null) begin
      // Connect register model to APB sequencer via adapter
      reg_model.default_map.set_sequencer(apb_agent_h.sequencer, reg_adapter);

      // Connect monitor to predictor for scoreboarding
      apb_agent_h.monitor.item_collected_port.connect(reg_predictor.bus_in);

      // Configure predictor
      reg_predictor.map = reg_model.default_map;
      reg_predictor.adapter = reg_adapter;
    end
  endfunction

endclass
