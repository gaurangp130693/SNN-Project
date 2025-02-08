class snn_test extends uvm_test;
    snn_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = snn_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        snn_test_sequence seq = snn_test_sequence::type_id::create("seq");
        seq.start(env.sequencer);
        phase.drop_objection(this);
    endtask
endclass