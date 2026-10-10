class keypad_seq_item #(parameter PIN_WIDTH = 16)
    extends uvm_sequence_item;

    rand bit [PIN_WIDTH-1:0] pin_code;
    rand bit                 pin_valid;

    `uvm_object_param_utils(keypad_seq_item #(PIN_WIDTH))

    function new(string name = "keypad_seq_item");
        super.new(name);
    endfunction

endclass