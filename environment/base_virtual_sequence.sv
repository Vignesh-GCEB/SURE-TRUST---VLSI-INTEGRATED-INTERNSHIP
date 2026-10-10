class base_virtual_sequence #(
    parameter int NUM_ZONES = 8,
    parameter int PIN_WIDTH = 16
) extends uvm_sequence;

    `uvm_object_param_utils(
        base_virtual_sequence #(NUM_ZONES, PIN_WIDTH)
    )

    virtual_sequencer #(NUM_ZONES, PIN_WIDTH) vseqr;


    function new(string name = "base_virtual_sequence");

        super.new(name);

    endfunction


    task body();

        if (vseqr == null) begin

            `uvm_fatal(
                "VSEQ",
                "Virtual sequencer handle is null"
            )

        end

    endtask

endclass