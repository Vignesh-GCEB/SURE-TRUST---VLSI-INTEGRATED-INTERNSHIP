class irq_seq_item extends uvm_sequence_item;

    bit irq;

    `uvm_object_utils(irq_seq_item)

    function new(string name = "irq_seq_item");
        super.new(name);
    endfunction

endclass