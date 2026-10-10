class alarm_base_test #(
    parameter int NUM_ZONES        = 8,
    parameter int PIN_WIDTH        = 16,
    parameter int TIMER_WIDTH      = 24,
    parameter int MAX_PIN_ATTEMPTS = 3
) extends uvm_test;

    `uvm_component_param_utils(
        alarm_base_test #(
            NUM_ZONES,
            PIN_WIDTH,
            TIMER_WIDTH,
            MAX_PIN_ATTEMPTS
        )
    )

    alarm_env #(
        NUM_ZONES,
        PIN_WIDTH,
        TIMER_WIDTH,
        MAX_PIN_ATTEMPTS
    ) env;

    function new(string name = "alarm_base_test",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = alarm_env #(
            NUM_ZONES,
            PIN_WIDTH,
            TIMER_WIDTH,
            MAX_PIN_ATTEMPTS
        )::type_id::create("env", this);
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        uvm_top.print_topology();

        `uvm_info("TEST",
                  "UVM hierarchy has been constructed",
                  UVM_LOW)
    endfunction

endclass

