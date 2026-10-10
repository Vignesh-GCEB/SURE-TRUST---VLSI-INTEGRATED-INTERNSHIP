class sensor_base_seq #(parameter NUM_ZONES = 8)
    extends uvm_sequence #(sensor_seq_item #(NUM_ZONES));

    `uvm_object_param_utils(
        sensor_base_seq #(NUM_ZONES)
    )

    function new(string name = "sensor_base_seq");
        super.new(name);
    endfunction

    task body();

        sensor_seq_item #(NUM_ZONES) req;

        `uvm_info("SENSOR_SEQ",
                  "Sensor sequence STARTED",
                  UVM_LOW)

        req = sensor_seq_item #(NUM_ZONES)::type_id::create("sensor_req");

        start_item(req);

        req.sensor_value = '0;
        req.duration     = 1;

        finish_item(req);

        `uvm_info("SENSOR_SEQ",
                  "Sensor sequence COMPLETED",
                  UVM_LOW)

    endtask

endclass