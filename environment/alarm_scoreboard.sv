//======================================================
// File: alarm_scoreboard.sv
// Purpose:
//   Scoreboard for Smart Home Alarm Controller
//======================================================


//======================================================
// Analysis implementation declarations
//======================================================

`uvm_analysis_imp_decl(_ahb)
`uvm_analysis_imp_decl(_sensor)
`uvm_analysis_imp_decl(_keypad)
`uvm_analysis_imp_decl(_alarm)
`uvm_analysis_imp_decl(_irq)


//======================================================
// Alarm Scoreboard
//======================================================

class alarm_scoreboard #(
    parameter int NUM_ZONES        = 8,
    parameter int PIN_WIDTH        = 16,
    parameter int TIMER_WIDTH      = 24,
    parameter int MAX_PIN_ATTEMPTS = 3
) extends uvm_scoreboard;


    `uvm_component_param_utils(
        alarm_scoreboard #(
            NUM_ZONES,
            PIN_WIDTH,
            TIMER_WIDTH,
            MAX_PIN_ATTEMPTS
        )
    )


    //==================================================
    // Reference Model
    //==================================================

    alarm_reference_model #(
        NUM_ZONES,
        PIN_WIDTH,
        TIMER_WIDTH,
        MAX_PIN_ATTEMPTS
    ) ref_model;


    //==================================================
    // Alarm interface
    // Used for reference-model timing
    //==================================================

   virtual alarm_if alarm_vif;


    //==================================================
    // Analysis implementations
    //==================================================

    // AHB transactions
    uvm_analysis_imp_ahb #(
        ahb_seq_item,
        alarm_scoreboard #(
            NUM_ZONES,
            PIN_WIDTH,
            TIMER_WIDTH,
            MAX_PIN_ATTEMPTS
        )
    ) ahb_imp;


    // Sensor transactions
    uvm_analysis_imp_sensor #(
        sensor_seq_item #(NUM_ZONES),
        alarm_scoreboard #(
            NUM_ZONES,
            PIN_WIDTH,
            TIMER_WIDTH,
            MAX_PIN_ATTEMPTS
        )
    ) sensor_imp;


    // Keypad transactions
    uvm_analysis_imp_keypad #(
        keypad_seq_item #(PIN_WIDTH),
        alarm_scoreboard #(
            NUM_ZONES,
            PIN_WIDTH,
            TIMER_WIDTH,
            MAX_PIN_ATTEMPTS
        )
    ) keypad_imp;


    // Alarm output transactions
    uvm_analysis_imp_alarm #(
        alarm_seq_item,
        alarm_scoreboard #(
            NUM_ZONES,
            PIN_WIDTH,
            TIMER_WIDTH,
            MAX_PIN_ATTEMPTS
        )
    ) alarm_imp;


    // IRQ transactions
    uvm_analysis_imp_irq #(
        irq_seq_item,
        alarm_scoreboard #(
            NUM_ZONES,
            PIN_WIDTH,
            TIMER_WIDTH,
            MAX_PIN_ATTEMPTS
        )
    ) irq_imp;


    //==================================================
    // Sensor edge tracking
    //==================================================

    bit [NUM_ZONES-1:0] prev_sensor_value;


    //==================================================
    // Constructor
    //==================================================

    function new(
        string name = "alarm_scoreboard",
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
        // Create analysis implementations
        //==============================================

        ahb_imp    = new("ahb_imp", this);
        sensor_imp = new("sensor_imp", this);
        keypad_imp = new("keypad_imp", this);
        alarm_imp  = new("alarm_imp", this);
        irq_imp    = new("irq_imp", this);


        //==============================================
        // Create reference model
        //==============================================

        ref_model = new();

        prev_sensor_value = '0;

    endfunction


    //==================================================
    // Run Phase
    //
    // Reference model timing is driven by sys_clk
    // because the alarm controller and timers belong
    // to the system clock domain.
    //==================================================

    task run_phase(uvm_phase phase);

        if (alarm_vif == null) begin

            `uvm_fatal(
                "SB_ALARM_VIF",
                "alarm_if handle is null in scoreboard"
            )

        end


        forever begin

            @(posedge alarm_vif.sys_clk);

            ref_model.tick();

        end

    endtask


    //==================================================
    // AHB Monitor Callback
    //==================================================

    function void write_ahb(ahb_seq_item item);


        //================================================
        // AHB WRITE
        //================================================

        if (item.cmd == ahb_seq_item::AHB_WRITE) begin


            case (item.addr)


                //================================================
                // CONTROL - 0x000
                //================================================

                32'h0000_0000: begin

                    if (item.wdata[0])
                        ref_model.process_event(
                            alarm_reference_model #(
                                NUM_ZONES,
                                PIN_WIDTH,
                                TIMER_WIDTH,
                                MAX_PIN_ATTEMPTS
                            )::RM_EVT_ARM_STAY
                        );


                    if (item.wdata[1])
                        ref_model.process_event(
                            alarm_reference_model #(
                                NUM_ZONES,
                                PIN_WIDTH,
                                TIMER_WIDTH,
                                MAX_PIN_ATTEMPTS
                            )::RM_EVT_ARM_AWAY
                        );


                    if (item.wdata[2])
                        ref_model.process_event(
                            alarm_reference_model #(
                                NUM_ZONES,
                                PIN_WIDTH,
                                TIMER_WIDTH,
                                MAX_PIN_ATTEMPTS
                            )::RM_EVT_DISARM
                        );


                    if (item.wdata[3])
                        ref_model.process_event(
                            alarm_reference_model #(
                                NUM_ZONES,
                                PIN_WIDTH,
                                TIMER_WIDTH,
                                MAX_PIN_ATTEMPTS
                            )::RM_EVT_CLEAR_ALARM
                        );


                    if (item.wdata[4])
                        ref_model.process_event(
                            alarm_reference_model #(
                                NUM_ZONES,
                                PIN_WIDTH,
                                TIMER_WIDTH,
                                MAX_PIN_ATTEMPTS
                            )::RM_EVT_CLEAR_FAULT
                        );

                end


                //================================================
                // ENTRY_DELAY - 0x008
                //================================================

                32'h0000_0008: begin

                    ref_model.set_entry_delay(
                        item.wdata[TIMER_WIDTH-1:0]
                    );

                end


                //================================================
                // EXIT_DELAY - 0x00C
                //================================================

                32'h0000_000C: begin

                    ref_model.set_exit_delay(
                        item.wdata[TIMER_WIDTH-1:0]
                    );

                end


                //================================================
                // ALARM_DURATION - 0x010
                //================================================

                32'h0000_0010: begin

                    ref_model.set_alarm_duration(
                        item.wdata[TIMER_WIDTH-1:0]
                    );

                end


                //================================================
                // PIN_CONFIG - 0x014
                //================================================

                32'h0000_0014: begin

                    ref_model.set_pin(
                        item.wdata[PIN_WIDTH-1:0]
                    );

                end


                //================================================
                // ZONE_TYPE
                //
                // Address used by current testbench:
                // 0x200 + zone_id*4
                //
                // Zone type encoding:
                // 0 = UNUSED
                // 1 = ENTRY
                // 2 = PERIMETER
                // 3 = MOTION
                // 4 = FIRE
                // 5 = PANIC
                //================================================

                32'h0000_0200: begin

                    ref_model.set_zone_type(
                        0,
                        alarm_reference_model #(
                            NUM_ZONES,
                            PIN_WIDTH,
                            TIMER_WIDTH,
                            MAX_PIN_ATTEMPTS
                        )::rm_zone_type_e'(item.wdata[2:0])
                    );

                end


                //================================================
                // ZONE_ENABLE - 0x018
                //================================================

                32'h0000_0018: begin

                    ref_model.set_zone_enable(
                        item.wdata[NUM_ZONES-1:0]
                    );

                end


                //================================================
                // ZONE_BYPASS - 0x01C
                //================================================

                32'h0000_001C: begin

                    ref_model.set_zone_bypass(
                        item.wdata[NUM_ZONES-1:0]
                    );

                end


                //================================================
                // IRQ_STATUS - 0x034
                // RW1C
                //================================================

                32'h0000_0034: begin

                    ref_model.clear_irq_status(
                        item.wdata[5:0]
                    );

                end


                //================================================
                // IRQ_ENABLE - 0x038
                //================================================

                32'h0000_0038: begin

                    ref_model.set_irq_enable(
                        item.wdata[5:0]
                    );

                end


                //================================================
                // Other addresses
                //================================================

                default: begin

                    // No reference-model action yet

                end

            endcase

        end


        //================================================
        // AHB READ
        //================================================

        if (item.cmd == ahb_seq_item::AHB_READ) begin


            case (item.addr)


                //================================================
                // STATUS - 0x004
                //================================================

                32'h0000_0004: begin

                    bit [31:0] expected_status;

                    expected_status =
                        ref_model.get_expected_status();


                    if (item.rdata !== expected_status) begin

                        `uvm_error(
                            "STATUS_MISMATCH",
                            $sformatf(
                                "STATUS mismatch: Expected=0x%08h Actual=0x%08h",
                                expected_status,
                                item.rdata
                            )
                        )

                    end
                    else begin

                        `uvm_info(
                            "STATUS_MATCH",
                            $sformatf(
                                "STATUS matched: 0x%08h",
                                item.rdata
                            ),
                            UVM_LOW
                        )

                    end

                end


                //================================================
                // EXIT_DELAY - 0x00C
                //================================================

                32'h0000_000C: begin

                    bit [TIMER_WIDTH-1:0] expected_exit_delay;

                    expected_exit_delay =
                        ref_model.get_exit_delay();


                    if (item.rdata !== expected_exit_delay) begin

                        `uvm_error(
                            "EXIT_DELAY_MISMATCH",
                            $sformatf(
                                "EXIT_DELAY mismatch: Expected=0x%08h Actual=0x%08h",
                                expected_exit_delay,
                                item.rdata
                            )
                        )

                    end
                    else begin

                        `uvm_info(
                            "EXIT_DELAY_MATCH",
                            $sformatf(
                                "EXIT_DELAY match: 0x%08h",
                                item.rdata
                            ),
                            UVM_LOW
                        )

                    end

                end


                default: begin

                    // No read comparison yet

                end

            endcase

        end

    endfunction


    //==================================================
    // Sensor Monitor Callback
    //==================================================

    function void write_sensor(
        sensor_seq_item #(NUM_ZONES) item
    );

        bit [NUM_ZONES-1:0] sensor_rise;


        //==============================================
        // Detect rising edge
        //==============================================

        sensor_rise =
            item.sensor_value & ~prev_sensor_value;


        if (item.sensor_value != '0) begin

            `uvm_info(
                "SCOREBOARD",
                $sformatf(
                    "Sensor transaction received: SENSOR=0x%0h",
                    item.sensor_value
                ),
                UVM_LOW
            )

        end


        //==============================================
        // Process newly activated zones
        //==============================================

        for (int i = 0; i < NUM_ZONES; i++) begin

            if (sensor_rise[i]) begin

                `uvm_info(
                    "SCOREBOARD",
                    $sformatf(
                        "Sensor rising event detected: ZONE=%0d",
                        i
                    ),
                    UVM_LOW
                )


                //==========================================
                // Reference-model debug BEFORE event
                //==========================================

                `uvm_info(
                    "REF_DEBUG",
                    $sformatf(
                        "Before zone event: zone=%0d type=%0d enable=%0b state=%0d expected_alarm=%0b",
                        i,
                        ref_model.zone_type[i],
                        ref_model.zone_enable[i],
                        ref_model.current_state,
                        ref_model.get_expected_alarm_active()
                    ),
                    UVM_LOW
                )


                //==========================================
                // Send zone event to reference model
                //==========================================

                ref_model.process_zone_event(i);


                //==========================================
                // Reference-model debug AFTER event
                //==========================================

                `uvm_info(
                    "REF_DEBUG",
                    $sformatf(
                        "After zone event: zone=%0d state=%0d expected_alarm=%0b",
                        i,
                        ref_model.current_state,
                        ref_model.get_expected_alarm_active()
                    ),
                    UVM_LOW
                )

            end

        end


        prev_sensor_value =
            item.sensor_value;

    endfunction


    //==================================================
    // Keypad Monitor Callback
    //==================================================

    function void write_keypad(
        keypad_seq_item #(PIN_WIDTH) item
    );


        `uvm_info(
            "SCOREBOARD",
            $sformatf(
                "Keypad transaction received: PIN=0x%0h VALID=%0b",
                item.pin_code,
                item.pin_valid
            ),
            UVM_MEDIUM
        );


        //==============================================
        // Pass valid keypad transactions to
        // reference model
        //==============================================

        if (item.pin_valid) begin

            ref_model.process_pin(
                item.pin_code
            );

        end

    endfunction


    //==================================================
    // Alarm Monitor Callback
    //==================================================

    function void write_alarm(
        alarm_seq_item item
    );

        bit expected_alarm_active;


        expected_alarm_active =
            ref_model.get_expected_alarm_active();


        `uvm_info(
            "SCOREBOARD",
            $sformatf(
                "Alarm output received: siren=%0b strobe=%0b alarm_active=%0b",
                item.siren,
                item.strobe,
                item.alarm_active
            ),
            UVM_MEDIUM
        )


        //==============================================
        // Compare DUT alarm output against
        // reference-model expected value
        //==============================================

        if (item.alarm_active !== expected_alarm_active) begin

            `uvm_error(
                "ALARM_MISMATCH",
                $sformatf(
                    "Alarm mismatch: Expected alarm_active=%0b Actual alarm_active=%0b",
                    expected_alarm_active,
                    item.alarm_active
                )
            )

        end
        else begin

            `uvm_info(
                "ALARM_MATCH",
                $sformatf(
                    "Alarm matched: alarm_active=%0b",
                    item.alarm_active
                ),
                UVM_LOW
            )

        end

    endfunction


    //==================================================
    // IRQ Monitor Callback
    //==================================================

    function void write_irq(
        irq_seq_item item
    );


        `uvm_info(
            "SCOREBOARD",
            $sformatf(
                "IRQ received: irq=%0b",
                item.irq
            ),
            UVM_MEDIUM
        )


   

    endfunction


endclass