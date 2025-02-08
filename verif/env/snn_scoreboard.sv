class snn_scoreboard extends uvm_component;
    uvm_analysis_imp #(snn_transaction, snn_scoreboard) analysis_imp;
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void write(snn_transaction t);
        // Compare actual vs expected results
        assert(t.spikes_out == expected_result) else $error("Mismatch detected!");
    endfunction
endclass
