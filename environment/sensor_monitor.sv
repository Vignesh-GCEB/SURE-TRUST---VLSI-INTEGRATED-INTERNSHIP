class sensor_monitor #(parameter NUM_ZONES = 8)
    extends uvm_monitor;

    `uvm_component_param_utils(sensor_monitor #(NUM_ZONES))

    virtual sensor_if #(NUM_ZONES) vif;

    uvm_analysis_port #(sensor_seq_item #(NUM_ZONES)) ap;

    function new(string name = "sensor_monitor",
                 uvm_component parent = null);
        super.new(name, parent);

        ap = new("ap", this);
    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        if (!uvm_config_db#(
                virtual sensor_if #(NUM_ZONES)
            )::get(this, "", "vif", vif)) begin

            `uvm_fatal("SENSOR_MON",
                       "Sensor virtual interface not found")
        end

    endfunction


    task run_phase(uvm_phase phase);

        forever begin

            @(posedge vif.sensor_clk);

            if (vif.sensor_reset_n) begin

                sensor_seq_item #(NUM_ZONES) item;

                item = sensor_seq_item #(NUM_ZONES)::
                       type_id::create("item");

                item.sensor_value = vif.sensor_in;

                ap.write(item);

            end

        end

    endtask

endclass