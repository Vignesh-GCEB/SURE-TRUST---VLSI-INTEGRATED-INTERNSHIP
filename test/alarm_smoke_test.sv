class alarm_smoke_test extends alarm_base_test #(8,16,24,3);

    `uvm_component_utils(alarm_smoke_test)

    function new(string name="alarm_smoke_test",
                 uvm_component parent=null);
        super.new(name,parent);
    endfunction
task run_phase(uvm_phase phase);

    smoke_virtual_sequence #(8,16) vseq;

    phase.raise_objection(this);

    // Wait for DUT reset to be released
    #150ns;

    `uvm_info("TEST",
              "DUT reset released - starting smoke sequence",
              UVM_LOW)

    vseq = smoke_virtual_sequence #(8,16)::type_id::create("vseq");

    vseq.vseqr = env.vseqr;

    vseq.start(env.vseqr);

    phase.drop_objection(this);

endtask
endclass