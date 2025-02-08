class snn_test_sequence extends uvm_sequence #(snn_sequence_item);
    function new(string name = "snn_test_sequence");
        super.new(name);
    endfunction

    task body();
        snn_sequence_item item;
        for (int i = 0; i < NUM_TESTS; i++) begin
            item = snn_sequence_item::type_id::create("item");
            item.spikes_in = random_spikes();
            start_item(item);
            finish_item(item);
        end
    endtask
endclass