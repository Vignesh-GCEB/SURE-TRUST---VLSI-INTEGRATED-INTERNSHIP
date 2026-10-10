
class pin_failure_test extends alarm_base_test #(
    8,     // NUM_ZONES
    16,    // PIN_WIDTH
    24,    // TIMER_WIDTH
    3      // MAX_PIN_ATTEMPTS
);

    `uvm_component_utils(pin_failure_test)

    function new(string name = "pin_failure_test",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        pin_failure_vseq #(8, 16) vseq;

        phase.raise_objection(this);

        #150ns;

        vseq = pin_failure_vseq #(8, 16)::type_id::create("vseq");
        vseq.vseqr = env.vseqr;
        vseq.start(null);

        phase.drop_objection(this);
    endtask

endclass
