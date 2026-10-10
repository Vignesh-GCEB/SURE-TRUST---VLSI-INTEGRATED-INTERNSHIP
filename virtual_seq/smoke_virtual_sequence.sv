class smoke_virtual_sequence #(
    parameter int NUM_ZONES = 8,
    parameter int PIN_WIDTH = 16
) extends base_virtual_sequence #(NUM_ZONES, PIN_WIDTH);

    `uvm_object_param_utils(
        smoke_virtual_sequence #(NUM_ZONES, PIN_WIDTH)
    )

    function new(string name = "smoke_virtual_sequence");
        super.new(name);
    endfunction

    task body();

        smoke_ahb_seq ahb_seq;

        `uvm_info("VSEQ",
                  "Smoke virtual sequence STARTED",
                  UVM_LOW)

        super.body();

        ahb_seq =
            smoke_ahb_seq::type_id::create("ahb_seq");

        `uvm_info("VSEQ",
                  "Starting smoke AHB sequence",
                  UVM_LOW)

        ahb_seq.start(vseqr.ahb_seqr);

        `uvm_info("VSEQ",
                  "Smoke AHB sequence COMPLETED",
                  UVM_LOW)

    endtask

endclass