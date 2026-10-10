class perimeter_sensor_seq extends sensor_base_seq #(8);

    `uvm_object_utils(perimeter_sensor_seq)

    function new(string name = "perimeter_sensor_seq");
        super.new(name);
    endfunction

    task body();

        sensor_seq_item #(8) req;

        `uvm_info("PERIM_SENSOR_SEQ",
                  "Perimeter sensor sequence STARTED",
                  UVM_LOW)

        // ================================================
        // Activate Zone 0
        // ================================================

        req = sensor_seq_item #(8)::type_id::create("zone0_sensor");

        start_item(req);

        req.sensor_value = 8'b0000_0001;  // Zone 0 active
        req.duration     = 10;            // Hold for 10 sensor clocks

        finish_item(req);

        `uvm_info("PERIM_SENSOR_SEQ",
                  "Zone 0 sensor activated",
                  UVM_LOW)

        `uvm_info("PERIM_SENSOR_SEQ",
                  "Perimeter sensor sequence COMPLETED",
                  UVM_LOW)

    endtask

endclass