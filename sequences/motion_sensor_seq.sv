class motion_sensor_seq extends sensor_base_seq #(8);

    `uvm_object_utils(motion_sensor_seq)

    function new(string name = "motion_sensor_seq");
        super.new(name);
    endfunction


    task body();

        sensor_seq_item #(8) req;

        `uvm_info(
            "MOTION_SENSOR_SEQ",
            "Motion sensor sequence STARTED",
            UVM_LOW
        )

        req = sensor_seq_item #(8)::type_id::create("zone0_motion");

        start_item(req);

        // Zone 0 = 1
        req.sensor_value = 8'b0000_0001;

        // Hold sensor active
        req.duration = 10;

        finish_item(req);

        `uvm_info(
            "MOTION_SENSOR_SEQ",
            "Zone 0 motion sensor activated",
            UVM_LOW
        )

        `uvm_info(
            "MOTION_SENSOR_SEQ",
            "Motion sensor sequence COMPLETED",
            UVM_LOW
        )

    endtask

endclass