class sensor_sequencer #(parameter NUM_ZONES = 8)
    extends uvm_sequencer #(sensor_seq_item #(NUM_ZONES));

    `uvm_component_param_utils(
        sensor_sequencer #(NUM_ZONES)
    )

    function new(string name = "sensor_sequencer",
                 uvm_component parent = null);

        super.new(name, parent);

    endfunction

endclass