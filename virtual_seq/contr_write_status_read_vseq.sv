
class contr_write_status_read_vseq #(
    parameter int NUM_ZONES = 8,
    parameter int PIN_WIDTH = 16
) extends base_virtual_sequence #(NUM_ZONES, PIN_WIDTH);

    `uvm_object_param_utils(
        contr_write_status_read_vseq #(NUM_ZONES, PIN_WIDTH)
    )

    function new(string name = "contr_write_status_read_vseq");
        super.new(name);
    endfunction

    task body();

        contr_write_status_read_ahb_seq ahb_seq;

        super.body();

        `uvm_info("CONTR_STATUS_VSEQ",
                  "Virtual sequence STARTED",
                  UVM_LOW)

        ahb_seq =
            contr_write_status_read_ahb_seq::type_id::create("ahb_seq");

        ahb_seq.start(vseqr.ahb_seqr);

        `uvm_info("CONTR_STATUS_VSEQ",
                  "Virtual sequence COMPLETED",
                  UVM_LOW)

    endtask

endclass
