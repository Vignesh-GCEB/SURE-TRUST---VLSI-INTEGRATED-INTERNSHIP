class alarm_seq_item extends uvm_sequence_item;

    bit siren;
    bit strobe;
    bit alarm_active;

    `uvm_object_utils(alarm_seq_item)

    function new(string name = "alarm_seq_item");
        super.new(name);
    endfunction

endclass