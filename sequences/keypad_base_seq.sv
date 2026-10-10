class keypad_base_seq #(
    parameter int PIN_WIDTH = 16
) extends uvm_sequence #(keypad_seq_item #(PIN_WIDTH));

    `uvm_object_param_utils(keypad_base_seq #(PIN_WIDTH))

    function new(string name = "keypad_base_seq");
        super.new(name);
    endfunction

endclass