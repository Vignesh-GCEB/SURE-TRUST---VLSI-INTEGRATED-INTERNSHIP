class ahb_agent extends uvm_agent;

    `uvm_component_utils(ahb_agent)

    // ----------------------------------------
    // AHB components
    // ----------------------------------------
    ahb_sequencer sequencer;

    ahb_driver  driver;
    ahb_monitor monitor;


    // ----------------------------------------
    // Constructor
    // ----------------------------------------
    function new(string name = "ahb_agent",
                 uvm_component parent = null);

        super.new(name, parent);

    endfunction


    // ----------------------------------------
    // Build Phase
    // ----------------------------------------
    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        // Create monitor always
        monitor = ahb_monitor::type_id::create(
                      "monitor",
                      this
                  );


        // Create driver and sequencer
        // only when agent is ACTIVE
        if (get_is_active() == UVM_ACTIVE) begin

           sequencer =
    				ahb_sequencer::type_id::create(
        			"sequencer", this);

            driver = ahb_driver::type_id::create(
                         "driver",
                         this
                     );

        end

    endfunction


    // ----------------------------------------
    // Connect Phase
    // ----------------------------------------
    function void connect_phase(uvm_phase phase);

        super.connect_phase(phase);

        if (get_is_active() == UVM_ACTIVE) begin

            driver.seq_item_port.connect(
                sequencer.seq_item_export
            );

        end

    endfunction

endclass