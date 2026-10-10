class virtual_sequencer #(
    parameter int NUM_ZONES = 8,
    parameter int PIN_WIDTH = 16
) extends uvm_sequencer;

    `uvm_component_param_utils(
        virtual_sequencer #(NUM_ZONES, PIN_WIDTH)
    )

    ahb_sequencer ahb_seqr;

    sensor_sequencer #(NUM_ZONES) sensor_seqr;

    keypad_sequencer #(PIN_WIDTH) keypad_seqr;


    function new(string name = "virtual_sequencer",
                 uvm_component parent = null);

        super.new(name, parent);

    endfunction

endclass