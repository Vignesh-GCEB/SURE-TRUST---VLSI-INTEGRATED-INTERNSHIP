class sensor_agent #(parameter NUM_ZONES = 8)
    extends uvm_agent;

    `uvm_component_param_utils(sensor_agent #(NUM_ZONES))

    sensor_sequencer #(NUM_ZONES) sequencer;

    sensor_driver #(NUM_ZONES)  driver;
    sensor_monitor #(NUM_ZONES) monitor;


    function new(string name = "sensor_agent",
                 uvm_component parent = null);

        super.new(name, parent);

    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        // Monitor exists in both ACTIVE and PASSIVE modes
        monitor = sensor_monitor #(NUM_ZONES)::
                  type_id::create("monitor", this);

        // Driver and sequencer only for ACTIVE agent
        if (get_is_active() == UVM_ACTIVE) begin

            sequencer =
   					 sensor_sequencer #(NUM_ZONES)::type_id::create(
       				 "sequencer", this
   						 );

            driver =
                sensor_driver #(NUM_ZONES)::
                type_id::create("driver", this);

        end

    endfunction


    function void connect_phase(uvm_phase phase);

        super.connect_phase(phase);

        if (get_is_active() == UVM_ACTIVE) begin

            driver.seq_item_port.connect(
                sequencer.seq_item_export
            );

        end

    endfunction

endclass