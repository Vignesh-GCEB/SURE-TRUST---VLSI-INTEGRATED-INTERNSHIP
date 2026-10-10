//==============================================================
// File: alarm_reference_model.sv
// Purpose:
//   Reference model for Smart Home Alarm Controller
//
// Note:
//   This is a plain SystemVerilog class.
//   It is NOT a UVM component.
//   The scoreboard will create and use this model.
//
// IMPORTANT:
//   This model represents the intended behavior from the
//   project specification. It must not copy injected bugs
//   from the DUT RTL.
//==============================================================

class alarm_reference_model #(
    parameter int NUM_ZONES        = 8,
    parameter int PIN_WIDTH        = 16,
    parameter int TIMER_WIDTH      = 24,
    parameter int MAX_PIN_ATTEMPTS = 3
);

    //==========================================================
    // 1. ALARM FSM STATES
    //==========================================================

    typedef enum {
        RM_DISARMED,
        RM_EXIT_DELAY,
        RM_ARMED_STAY,
        RM_ARMED_AWAY,
        RM_ENTRY_DELAY,
        RM_ALARM,
        RM_FAULT
    } rm_state_e;

    rm_state_e current_state;


    //==========================================================
    // 2. PIN AUTHENTICATION
    //==========================================================

    bit [PIN_WIDTH-1:0] expected_pin;

    int unsigned pin_attempts;

    bit pin_configured;

    bit valid_pin_received;


    //==========================================================
    // 3. TIMER / CONFIGURATION VALUES
    //==========================================================

    bit [TIMER_WIDTH-1:0] exit_delay_value;
    bit [TIMER_WIDTH-1:0] exit_timer;

    bit [TIMER_WIDTH-1:0] entry_delay_value;
    bit [TIMER_WIDTH-1:0] entry_timer;

    bit [TIMER_WIDTH-1:0] alarm_duration_value;
    bit [TIMER_WIDTH-1:0] alarm_timer;


    //==========================================================
    // 4. ARMING MODE
    //==========================================================

    typedef enum {
        RM_MODE_NONE,
        RM_MODE_STAY,
        RM_MODE_AWAY
    } rm_arm_mode_e;

    rm_arm_mode_e requested_mode;


    //==========================================================
    // 5. ZONE TYPES
    //==========================================================

    typedef enum {
        RM_ZONE_UNUSED,
        RM_ZONE_ENTRY,
        RM_ZONE_PERIMETER,
        RM_ZONE_MOTION,
        RM_ZONE_FIRE,
        RM_ZONE_PANIC
    } rm_zone_type_e;

    rm_zone_type_e zone_type [NUM_ZONES];


    //==========================================================
    // 6. ZONE ENABLE / BYPASS
    //==========================================================

    bit [NUM_ZONES-1:0] zone_enable;

    bit [NUM_ZONES-1:0] zone_bypass;


    //==========================================================
    // 7. ALARM REASON
    //==========================================================

    typedef enum {
        RM_ALARM_NONE,
        RM_ALARM_FIRE,
        RM_ALARM_PANIC,
        RM_ALARM_PERIMETER,
        RM_ALARM_MOTION,
        RM_ALARM_ENTRY_TIMEOUT
    } rm_alarm_reason_e;

    rm_alarm_reason_e alarm_reason;

    bit expected_alarm_active;


    //==========================================================
    // 8. INTERRUPT SOURCES
    //==========================================================

    typedef enum int {
        RM_IRQ_ALARM   = 0,
        RM_IRQ_FIRE    = 1,
        RM_IRQ_PANIC   = 2,
        RM_IRQ_EVENT   = 3,
        RM_IRQ_FAULT   = 4,
        RM_IRQ_LOCKOUT = 5
    } rm_irq_source_e;

    bit [5:0] irq_status;

    bit [5:0] irq_enable;

    bit expected_irq;


    //==========================================================
    // 9. MODEL EVENTS
    //
    // KEEP THESE NAMES.
    // The scoreboard already depends on them.
    //==========================================================

    typedef enum {
        RM_EVT_NONE,

        RM_EVT_ARM_STAY,
        RM_EVT_ARM_AWAY,
        RM_EVT_DISARM,

        RM_EVT_VALID_PIN,
        RM_EVT_INVALID_PIN,

        RM_EVT_SENSOR_EVENT,
        RM_EVT_ENTRY_EVENT,
        RM_EVT_PERIMETER,
        RM_EVT_MOTION,
        RM_EVT_FIRE,
        RM_EVT_PANIC,

        RM_EVT_EXIT_TIMEOUT,
        RM_EVT_ENTRY_TIMEOUT,
        RM_EVT_ALARM_TIMEOUT,

        RM_EVT_CLEAR_ALARM,
        RM_EVT_CLEAR_FAULT

    } rm_event_e;


    //==========================================================
    // 10. EVENT FIFO STATUS
    //
    // EVENT_STATUS:
    //   bit 0 = FIFO_EMPTY
    //   bit 1 = FIFO_FULL
    //   bit 2 = FIFO_OVERFLOW
    //   bit 3 = EVENT_AVAILABLE
    //   bits [15:8] = EVENT_COUNT (optional)
    //
    // These are model-side values. They are NOT copied from
    // the DUT.
    //==========================================================

    bit event_fifo_empty;
    bit event_fifo_full;
    bit event_fifo_overflow;
    bit event_available;

    int unsigned event_count;


    //==========================================================
    // 11. CONSTRUCTOR
    //==========================================================

    function new();

        current_state = RM_DISARMED;

        // PIN
        expected_pin       = '0;
        pin_attempts       = 0;
        pin_configured     = 1'b0;
        valid_pin_received = 1'b0;

        // Timers
        exit_delay_value     = '0;
        exit_timer           = '0;

        entry_delay_value    = '0;
        entry_timer          = '0;

        alarm_duration_value = '0;
        alarm_timer          = '0;

        // Arming
        requested_mode = RM_MODE_NONE;

        // Zones
        zone_enable = '0;
        zone_bypass = '0;

        for (int i = 0; i < NUM_ZONES; i++) begin
            zone_type[i] = RM_ZONE_UNUSED;
        end

        // Alarm
        alarm_reason          = RM_ALARM_NONE;
        expected_alarm_active = 1'b0;

        // IRQ
        irq_status   = '0;
        irq_enable   = '0;
        expected_irq = 1'b0;

        // Event FIFO
        event_fifo_empty    = 1'b1;
        event_fifo_full     = 1'b0;
        event_fifo_overflow = 1'b0;
        event_available     = 1'b0;
        event_count         = 0;

    endfunction


    //==========================================================
    // 12. PIN CONFIGURATION
    //==========================================================

    function void set_pin(
        bit [PIN_WIDTH-1:0] new_pin
    );

        expected_pin   = new_pin;
        pin_configured = 1'b1;

        // Modeling assumption:
        // Programming PIN clears previous failed attempts.
        pin_attempts = 0;

    endfunction


    //==========================================================
    // 13. PIN PROCESSING
    //==========================================================

    function void process_pin(
        bit [PIN_WIDTH-1:0] entered_pin
    );

        if (!pin_configured) begin

            `uvm_warning(
                "REF_MODEL",
                "PIN entered before PIN_CONFIG was programmed"
            );

            return;

        end


        if (entered_pin == expected_pin) begin

            pin_attempts       = 0;
            valid_pin_received = 1'b1;

            process_event(RM_EVT_VALID_PIN);

        end
        else begin

            pin_attempts++;

            process_event(RM_EVT_INVALID_PIN);

            if (pin_attempts >= MAX_PIN_ATTEMPTS) begin

                irq_status[RM_IRQ_LOCKOUT] = 1'b1;

                update_irq();

            end

        end

    endfunction


    //==========================================================
    // 14. TIMER CONFIGURATION
    //==========================================================

    function void set_exit_delay(
        bit [TIMER_WIDTH-1:0] value
    );

        exit_delay_value = value;

    endfunction


    function void set_entry_delay(
        bit [TIMER_WIDTH-1:0] value
    );

        entry_delay_value = value;

    endfunction


    function void set_alarm_duration(
        bit [TIMER_WIDTH-1:0] value
    );

        alarm_duration_value = value;

    endfunction


    //==========================================================
    // 15. ZONE TYPE CONFIGURATION
    //==========================================================

    function void set_zone_type(
        int zone_id,
        rm_zone_type_e zone_kind
    );

        if (zone_id >= NUM_ZONES) begin

            `uvm_error(
                "REF_MODEL",
                $sformatf(
                    "Invalid zone ID: %0d",
                    zone_id
                )
            );

            return;

        end

        zone_type[zone_id] = zone_kind;

    endfunction


    //==========================================================
    // 16. ZONE ENABLE
    //==========================================================

    function void set_zone_enable(
        bit [NUM_ZONES-1:0] value
    );

        zone_enable = value;

    endfunction


    //==========================================================
    // 17. ZONE BYPASS
    //==========================================================

    function void set_zone_bypass(
        bit [NUM_ZONES-1:0] value
    );

        zone_bypass = value;

    endfunction


    //==========================================================
    // 18. EVENT PROCESSING
    //==========================================================

    function void process_event(
        rm_event_e event_kind
    );

        case (event_kind)

            //--------------------------------------------------
            // ARM STAY
            //--------------------------------------------------

            RM_EVT_ARM_STAY: begin

                if (current_state == RM_DISARMED) begin

                    requested_mode = RM_MODE_STAY;

                    current_state = RM_EXIT_DELAY;

                    exit_timer = exit_delay_value;

                end

            end


            //--------------------------------------------------
            // ARM AWAY
            //--------------------------------------------------

            RM_EVT_ARM_AWAY: begin

                if (current_state == RM_DISARMED) begin

                    requested_mode = RM_MODE_AWAY;

                    current_state = RM_EXIT_DELAY;

                    exit_timer = exit_delay_value;

                end

            end


            //--------------------------------------------------
            // DISARM
            //--------------------------------------------------

            RM_EVT_DISARM: begin

                if (valid_pin_received) begin

                    current_state = RM_DISARMED;

                    valid_pin_received = 1'b0;

                    exit_timer  = '0;
                    entry_timer = '0;

                    expected_alarm_active = 1'b0;

                    alarm_reason = RM_ALARM_NONE;

                    irq_status[RM_IRQ_ALARM] = 1'b0;
                    irq_status[RM_IRQ_FIRE]  = 1'b0;
                    irq_status[RM_IRQ_PANIC] = 1'b0;

                    update_irq();

                end
                else begin

                    `uvm_warning(
                        "REF_MODEL",
                        "DISARM requested without valid PIN"
                    );

                end

            end


            //--------------------------------------------------
            // VALID PIN
            //--------------------------------------------------

            RM_EVT_VALID_PIN: begin

                valid_pin_received = 1'b1;

            end


            //--------------------------------------------------
            // INVALID PIN
            //--------------------------------------------------

            RM_EVT_INVALID_PIN: begin

                // Attempt count is already updated by process_pin().

            end


            //--------------------------------------------------
            // ENTRY EVENT
            //--------------------------------------------------

            RM_EVT_ENTRY_EVENT: begin

                if ((current_state == RM_ARMED_STAY) ||
                    (current_state == RM_ARMED_AWAY)) begin

                    current_state = RM_ENTRY_DELAY;

                    entry_timer = entry_delay_value;

                end

            end


            //--------------------------------------------------
            // PERIMETER
            //--------------------------------------------------

            RM_EVT_PERIMETER: begin

                if ((current_state == RM_ARMED_STAY) ||
                    (current_state == RM_ARMED_AWAY)) begin

                    current_state = RM_ALARM;

                    alarm_reason = RM_ALARM_PERIMETER;

                    expected_alarm_active = 1'b1;

                    irq_status[RM_IRQ_ALARM] = 1'b1;

                    update_irq();

                end

            end


            //--------------------------------------------------
            // MOTION
            //--------------------------------------------------

            RM_EVT_MOTION: begin

                if (current_state == RM_ARMED_AWAY) begin

                    current_state = RM_ALARM;

                    alarm_reason = RM_ALARM_MOTION;

                    expected_alarm_active = 1'b1;

                    irq_status[RM_IRQ_ALARM] = 1'b1;

                    update_irq();

                end

            end


            //--------------------------------------------------
            // FIRE
            //--------------------------------------------------

            RM_EVT_FIRE: begin

                current_state = RM_ALARM;

                alarm_reason = RM_ALARM_FIRE;

                expected_alarm_active = 1'b1;

                irq_status[RM_IRQ_ALARM] = 1'b1;
                irq_status[RM_IRQ_FIRE]  = 1'b1;

                update_irq();

            end


            //--------------------------------------------------
            // PANIC
            //--------------------------------------------------

            RM_EVT_PANIC: begin

                current_state = RM_ALARM;

                alarm_reason = RM_ALARM_PANIC;

                expected_alarm_active = 1'b1;

                irq_status[RM_IRQ_ALARM] = 1'b1;
                irq_status[RM_IRQ_PANIC] = 1'b1;

                update_irq();

            end


            //--------------------------------------------------
            // CLEAR ALARM
            //--------------------------------------------------

            RM_EVT_CLEAR_ALARM: begin

                if ((current_state == RM_ALARM) &&
                    valid_pin_received) begin

                    current_state = RM_DISARMED;

                    alarm_reason = RM_ALARM_NONE;

                    expected_alarm_active = 1'b0;

                    valid_pin_received = 1'b0;

                    irq_status[RM_IRQ_ALARM] = 1'b0;
                    irq_status[RM_IRQ_FIRE]  = 1'b0;
                    irq_status[RM_IRQ_PANIC] = 1'b0;

                    update_irq();

                end
                else begin

                    `uvm_warning(
                        "REF_MODEL",
                        "CLEAR_ALARM requested without valid authenticated clear"
                    );

                end

            end


            //--------------------------------------------------
            // CLEAR FAULT
            //--------------------------------------------------

            RM_EVT_CLEAR_FAULT: begin

                // Exact FAULT clearing behavior has not yet
                // been defined in our model.

            end


            //--------------------------------------------------
            // OTHER EVENTS
            //--------------------------------------------------

            default: begin

                // No action

            end

        endcase

    endfunction


    //==========================================================
    // 19. ZONE EVENT PROCESSING
    //==========================================================

    function void process_zone_event(
        int unsigned zone_id
    );

        rm_zone_type_e zone_kind;


        if (zone_id >= NUM_ZONES)
            return;


        //------------------------------------------------------
        // Zone enable qualification
        //------------------------------------------------------

        if (!zone_enable[zone_id])
            return;


        zone_kind = zone_type[zone_id];


        //------------------------------------------------------
        // Zone bypass qualification
        //
        // FIRE and PANIC are not bypassable.
        //------------------------------------------------------

        if (zone_bypass[zone_id] &&
            (zone_kind != RM_ZONE_FIRE) &&
            (zone_kind != RM_ZONE_PANIC)) begin

            return;

        end


        //------------------------------------------------------
        // Zone type qualification
        //------------------------------------------------------

        case (zone_kind)

            RM_ZONE_ENTRY: begin

                if ((current_state == RM_ARMED_STAY) ||
                    (current_state == RM_ARMED_AWAY)) begin

                    process_event(RM_EVT_ENTRY_EVENT);

                end

            end


            RM_ZONE_PERIMETER: begin

                if ((current_state == RM_ARMED_STAY) ||
                    (current_state == RM_ARMED_AWAY)) begin

                    process_event(RM_EVT_PERIMETER);

                end

            end


            RM_ZONE_MOTION: begin

                if (current_state == RM_ARMED_AWAY) begin

                    process_event(RM_EVT_MOTION);

                end

            end


            RM_ZONE_FIRE: begin

                process_event(RM_EVT_FIRE);

            end


            RM_ZONE_PANIC: begin

                process_event(RM_EVT_PANIC);

            end


            RM_ZONE_UNUSED: begin

                // Ignore

            end

        endcase

    endfunction


    //==========================================================
    // 20. ALARM PRIORITY
    //==========================================================

    function rm_alarm_reason_e resolve_alarm_priority(
        bit fire,
        bit panic,
        bit perimeter,
        bit motion,
        bit entry_timeout
    );

        if (fire)
            return RM_ALARM_FIRE;

        else if (panic)
            return RM_ALARM_PANIC;

        else if (perimeter)
            return RM_ALARM_PERIMETER;

        else if (motion)
            return RM_ALARM_MOTION;

        else if (entry_timeout)
            return RM_ALARM_ENTRY_TIMEOUT;

        else
            return RM_ALARM_NONE;

    endfunction


    //==========================================================
    // 21. TIMER TICK
    //==========================================================

    function void tick();

        //------------------------------------------------------
        // EXIT DELAY
        //------------------------------------------------------

        if (current_state == RM_EXIT_DELAY) begin

            if (exit_timer > 0)
                exit_timer--;

            if (exit_timer == 0) begin

                case (requested_mode)

                    RM_MODE_STAY: begin
                        current_state = RM_ARMED_STAY;
                    end


                    RM_MODE_AWAY: begin
                        current_state = RM_ARMED_AWAY;
                    end


                    default: begin

                        `uvm_warning(
                            "REF_MODEL",
                            "EXIT_DELAY expired with no valid requested mode"
                        );

                    end

                endcase

            end

        end


        //------------------------------------------------------
        // ENTRY DELAY
        //------------------------------------------------------

        else if (current_state == RM_ENTRY_DELAY) begin

            if (entry_timer > 0)
                entry_timer--;

            if (entry_timer == 0) begin

                current_state = RM_ALARM;

                alarm_reason = RM_ALARM_ENTRY_TIMEOUT;

                expected_alarm_active = 1'b1;

                irq_status[RM_IRQ_ALARM] = 1'b1;

                update_irq();

            end

        end

    endfunction


    //==========================================================
    // 22. IRQ STATUS CLEAR - RW1C
    //==========================================================

    function void clear_irq_status(
        bit [5:0] clear_bits
    );

        irq_status = irq_status & ~clear_bits;

        update_irq();

    endfunction


    //==========================================================
    // 23. IRQ ENABLE
    //==========================================================

    function void set_irq_enable(
        bit [5:0] enable_bits
    );

        irq_enable = enable_bits;

        update_irq();

    endfunction


    //==========================================================
    // 24. IRQ CALCULATION
    //==========================================================

    function void update_irq();

        expected_irq = |(irq_status & irq_enable);

    endfunction


    //==========================================================
    // 25. EXPECTED STATUS REGISTER
    //
    // STATUS:
    // [2:0] SYSTEM_STATE
    // [3]   ALARM_ACTIVE
    // [4]   ENTRY_TIMER_ACTIVE
    // [5]   EXIT_TIMER_ACTIVE
    // [6]   KEYPAD_LOCKED
    // [7]   SYSTEM_FAULT
    // [8]   CONFIG_BUSY
    //==========================================================

    function bit [31:0] get_expected_status();

        bit [31:0] status;

        status = '0;

        status[2:0] = current_state;

        status[3] = expected_alarm_active;

        status[4] = (entry_timer != 0);

        status[5] = (exit_timer != 0);

        status[6] = (pin_attempts >= MAX_PIN_ATTEMPTS);

        status[7] = 1'b0;

        status[8] = 1'b0;

        return status;

    endfunction


    //==========================================================
    // 26. EXPECTED EVENT_STATUS REGISTER
    //
    // EVENT_STATUS:
    // [0]     FIFO_EMPTY
    // [1]     FIFO_FULL
    // [2]     FIFO_OVERFLOW
    // [3]     EVENT_AVAILABLE
    // [15:8]  EVENT_COUNT
    //==========================================================

    function bit [31:0] get_expected_event_status();

        bit [31:0] event_status;

        event_status = '0;

        event_status[0] = event_fifo_empty;
        event_status[1] = event_fifo_full;
        event_status[2] = event_fifo_overflow;
        event_status[3] = event_available;

        event_status[15:8] = event_count[7:0];

        return event_status;

    endfunction
  
  function bit get_expected_alarm_active();
    return (current_state == RM_ALARM);
endfunction

function bit [TIMER_WIDTH-1:0] get_exit_delay();
    return exit_delay_value;
endfunction
endclass