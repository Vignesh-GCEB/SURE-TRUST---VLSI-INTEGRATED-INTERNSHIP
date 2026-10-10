class keypad_sequencer #(parameter PIN_WIDTH = 16)
    extends uvm_sequencer #(keypad_seq_item #(PIN_WIDTH));

    `uvm_component_param_utils(
        keypad_sequencer #(PIN_WIDTH)
    )

    function new(string name = "keypad_sequencer",
                 uvm_component parent = null);

        super.new(name, parent);

    endfunction

endclass