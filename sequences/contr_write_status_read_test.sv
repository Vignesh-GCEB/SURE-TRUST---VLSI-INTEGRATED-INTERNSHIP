
class contr_write_status_read_test
    extends alarm_base_test #(8, 16, 24, 3);

    `uvm_component_utils(contr_write_status_read_test)

    function new(
        string name = "contr_write_status_read_test",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);

        contr_write_status_read_vseq #(8, 16) vseq;

        phase.raise_objection(this);

        // Wait for reset release and initial DUT stabilization
        #150ns;

        vseq = contr_write_status_read_vseq #(8, 16)::type_id::create("vseq");

        vseq.vseqr = env.vseqr;

        vseq.start(env.vseqr);

        phase.drop_objection(this);

    endtask

endclass
