//======================================================
// File: smart_home_alarm_env.sv
// Purpose:
//   UVM environment for Smart Home Alarm Controller
//======================================================

class alarm_env #(
    parameter int NUM_ZONES        = 8,
    parameter int PIN_WIDTH        = 16,
    parameter int TIMER_WIDTH      = 24,
    parameter int MAX_PIN_ATTEMPTS = 3
) extends uvm_env;


    `uvm_component_param_utils(
        alarm_env #(
            NUM_ZONES,
            PIN_WIDTH,
            TIMER_WIDTH,
            MAX_PIN_ATTEMPTS
        )
    )


    //==================================================
    // Agents
    //==================================================

    // Active agents
    ahb_agent ahb_ag;

    sensor_agent #(NUM_ZONES) sensor_ag;

    keypad_agent #(PIN_WIDTH) keypad_ag;


    // Passive agents
    alarm_agent alarm_ag;

    irq_agent irq_ag;


    //==================================================
    // Virtual Sequencer
    //==================================================

    virtual_sequencer #(
        NUM_ZONES,
        PIN_WIDTH
    ) vseqr;


    //==================================================
    // Scoreboard
    //==================================================

    alarm_scoreboard #(
        NUM_ZONES,
        PIN_WIDTH,
        TIMER_WIDTH,
        MAX_PIN_ATTEMPTS
    ) scoreboard;


    //==================================================
    // Constructor
    //==================================================

    function new(
        string name = "alarm_env",
        uvm_component parent = null
    );

        super.new(name, parent);

    endfunction


    //==================================================
    // Build Phase
    //==================================================

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);


        //==============================================
        // Create Virtual Sequencer
        //==============================================

        vseqr =
            virtual_sequencer #(
                NUM_ZONES,
                PIN_WIDTH
            )::type_id::create(
                "vseqr",
                this
            );


        //==============================================
        // Create AHB Agent
        //==============================================

        ahb_ag =
            ahb_agent::type_id::create(
                "ahb_ag",
                this
            );


        //==============================================
        // Create Sensor Agent
        //==============================================

        sensor_ag =
            sensor_agent #(
                NUM_ZONES
            )::type_id::create(
                "sensor_ag",
                this
            );


        //==============================================
        // Create Keypad Agent
        //==============================================

        keypad_ag =
            keypad_agent #(
                PIN_WIDTH
            )::type_id::create(
                "keypad_ag",
                this
            );


        //==============================================
        // Create Alarm Agent
        //==============================================

        alarm_ag =
            alarm_agent::type_id::create(
                "alarm_ag",
                this
            );


        //==============================================
        // Create IRQ Agent
        //==============================================

        irq_ag =
            irq_agent::type_id::create(
                "irq_ag",
                this
            );


        //==============================================
        // Create Scoreboard
        //==============================================

        scoreboard =
            alarm_scoreboard #(
                NUM_ZONES,
                PIN_WIDTH,
                TIMER_WIDTH,
                MAX_PIN_ATTEMPTS
            )::type_id::create(
                "scoreboard",
                this
            );

    endfunction


    //==================================================
    // Connect Phase
    //==================================================

    function void connect_phase(uvm_phase phase);

        super.connect_phase(phase);


        //==============================================
        // Connect physical sequencers to virtual
        // sequencer
        //==============================================

        vseqr.ahb_seqr =
            ahb_ag.sequencer;

        vseqr.sensor_seqr =
            sensor_ag.sequencer;

        vseqr.keypad_seqr =
            keypad_ag.sequencer;


        //==============================================
        // Monitor → Scoreboard
        //==============================================

        ahb_ag.monitor.ap.connect(
            scoreboard.ahb_imp
        );

        sensor_ag.monitor.ap.connect(
            scoreboard.sensor_imp
        );

        keypad_ag.monitor.ap.connect(
            scoreboard.keypad_imp
        );

        alarm_ag.monitor.ap.connect(
            scoreboard.alarm_imp
        );

        irq_ag.monitor.ap.connect(
            scoreboard.irq_imp
        );
      
        scoreboard.alarm_vif = alarm_ag.monitor.vif;

    endfunction


endclass