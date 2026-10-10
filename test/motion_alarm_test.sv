class motion_alarm_test extends alarm_base_test;

    `uvm_component_utils(motion_alarm_test)

    function new(
        string name = "motion_alarm_test",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction


    task run_phase(uvm_phase phase);

        motion_alarm_vseq #(8,16) vseq;

        phase.raise_objection(this);

        #150ns;

        `uvm_info(
            "TEST",
            "DUT reset released - starting motion alarm sequence",
            UVM_LOW
        )

        vseq =
            motion_alarm_vseq #(8,16)::type_id::create("vseq");

        vseq.vseqr = env.vseqr;

        vseq.start(env.vseqr);

        phase.drop_objection(this);

    endtask

endclass