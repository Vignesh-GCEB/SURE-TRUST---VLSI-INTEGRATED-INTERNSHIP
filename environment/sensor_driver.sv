class sensor_driver #(parameter NUM_ZONES = 8)
    extends uvm_driver #(sensor_seq_item #(NUM_ZONES));

    `uvm_component_param_utils(sensor_driver #(NUM_ZONES))

    virtual sensor_if #(NUM_ZONES) vif;

    function new(string name = "sensor_driver",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(
                virtual sensor_if #(NUM_ZONES)
            )::get(this, "", "vif", vif)) begin

            `uvm_fatal("SENSOR_DRV",
                       "Sensor virtual interface not found")
        end
    endfunction

    task run_phase(uvm_phase phase);

        sensor_seq_item #(NUM_ZONES) req;

        forever begin

            seq_item_port.get_next_item(req);

            drive_sensor(req);

            seq_item_port.item_done();

        end

    endtask


    task drive_sensor(sensor_seq_item #(NUM_ZONES) req);

        // Drive the requested sensor state
        vif.sensor_in <= req.sensor_value;

        // Hold the sensor state for requested cycles
        repeat (req.duration) begin
            @(posedge vif.sensor_clk);
        end

    endtask

endclass