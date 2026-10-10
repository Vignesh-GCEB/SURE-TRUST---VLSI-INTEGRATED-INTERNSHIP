class keypad_agent #(parameter PIN_WIDTH = 16)
    extends uvm_agent;

    `uvm_component_param_utils(keypad_agent #(PIN_WIDTH))

    keypad_sequencer #(PIN_WIDTH) sequencer;

    keypad_driver  #(PIN_WIDTH) driver;
    keypad_monitor #(PIN_WIDTH) monitor;


    function new(string name = "keypad_agent",
                 uvm_component parent = null);

        super.new(name, parent);

    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        // Monitor is present in both ACTIVE and PASSIVE modes
        monitor =
            keypad_monitor #(PIN_WIDTH)::
            type_id::create("monitor", this);

        // Driver and sequencer only for ACTIVE mode
        if (get_is_active() == UVM_ACTIVE) begin

            sequencer =
  					keypad_sequencer #(PIN_WIDTH)::type_id::create(
       				 "sequencer", this
   						 );

            driver =
                keypad_driver #(PIN_WIDTH)::
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