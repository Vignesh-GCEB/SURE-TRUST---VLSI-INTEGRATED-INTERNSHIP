class sensor_seq_item #(parameter NUM_ZONES = 8)
    extends uvm_sequence_item;

    rand bit [NUM_ZONES-1:0] sensor_value;
    rand int unsigned       duration;

    `uvm_object_param_utils(sensor_seq_item #(NUM_ZONES))

    function new(string name = "sensor_seq_item");
        super.new(name);
    endfunction

endclass