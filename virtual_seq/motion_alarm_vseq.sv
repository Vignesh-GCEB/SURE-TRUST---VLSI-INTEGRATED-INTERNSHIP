class motion_alarm_vseq #(
    parameter int NUM_ZONES = 8,
    parameter int PIN_WIDTH = 16
) extends base_virtual_sequence #(NUM_ZONES, PIN_WIDTH);

    `uvm_object_param_utils(
        motion_alarm_vseq #(NUM_ZONES, PIN_WIDTH)
    )

    function new(string name = "motion_alarm_vseq");
        super.new(name);
    endfunction


task body();

    motion_ahb_seq       ahb_seq;
    motion_sensor_seq    sensor_seq;
    ahb_status_read_seq  status_seq;

    `uvm_info(
        "MOTION_VSEQ",
        "Motion alarm virtual sequence STARTED",
        UVM_LOW
    )

    super.body();

    //======================================================
    // 1. Configure and ARM AWAY
    //======================================================

    ahb_seq =
        motion_ahb_seq::type_id::create("ahb_seq");

    `uvm_info(
        "MOTION_VSEQ",
        "Starting motion AHB sequence",
        UVM_LOW
    )

    ahb_seq.start(vseqr.ahb_seqr);

    `uvm_info(
        "MOTION_VSEQ",
        "Motion AHB sequence COMPLETED",
        UVM_LOW
    )


    //======================================================
    // 2. Allow ARM_AWAY to settle
    //======================================================

    #700ns;


    //======================================================
    // 3. Trigger Zone 0 MOTION
    //======================================================

    sensor_seq =
        motion_sensor_seq::type_id::create("sensor_seq");

    `uvm_info(
        "MOTION_VSEQ",
        "Starting motion sensor sequence",
        UVM_LOW
    )

    sensor_seq.start(vseqr.sensor_seqr);

    `uvm_info(
        "MOTION_VSEQ",
        "Motion sensor sequence COMPLETED",
        UVM_LOW
    )


    //======================================================
    // 4. Allow sensor → DUT processing to settle
    //======================================================

    #100ns;


    //======================================================
    // 5. Read STATUS
    //======================================================

    status_seq =
        ahb_status_read_seq::type_id::create("status_seq");

    `uvm_info(
        "MOTION_VSEQ",
        "Starting STATUS read sequence",
        UVM_LOW
    )

    status_seq.start(vseqr.ahb_seqr);

    `uvm_info(
        "MOTION_VSEQ",
        "STATUS read sequence COMPLETED",
        UVM_LOW
    )


    `uvm_info(
        "MOTION_VSEQ",
        "Motion alarm virtual sequence COMPLETED",
        UVM_LOW
    )

endtask
endclass