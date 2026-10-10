class motion_ahb_seq extends ahb_base_seq;

    `uvm_object_utils(motion_ahb_seq)

    function new(string name = "motion_ahb_seq");
        super.new(name);
    endfunction


    task body();

        ahb_seq_item req;


        `uvm_info(
            "MOTION_AHB_SEQ",
            "Motion AHB sequence STARTED",
            UVM_LOW
        )


        //======================================================
        // 1. Configure Zone 0 as MOTION
        //======================================================

        req = ahb_seq_item::type_id::create("zone_type_write");

        `uvm_info(
            "MOTION_AHB_SEQ",
            "Configuring Zone 0 as MOTION",
            UVM_LOW
        )

        start_item(req);

        req.cmd   = ahb_seq_item::AHB_WRITE;
        req.addr  = 32'h0000_0200;
        req.wdata = 32'h0000_0003;
        req.size  = 3'b010;

        finish_item(req);


        //======================================================
        // 2. Enable Zone 0
        //======================================================

        req = ahb_seq_item::type_id::create("zone_enable_write");

        `uvm_info(
            "MOTION_AHB_SEQ",
            "Enabling Zone 0",
            UVM_LOW
        )

        start_item(req);

        req.cmd   = ahb_seq_item::AHB_WRITE;
        req.addr  = 32'h0000_0018;
        req.wdata = 32'h0000_0001;
        req.size  = 3'b010;

        finish_item(req);


        //======================================================
        // 3. EXIT_DELAY = 0
        //======================================================

        req = ahb_seq_item::type_id::create("exit_delay_write");

        `uvm_info(
            "MOTION_AHB_SEQ",
            "Configuring EXIT_DELAY = 0",
            UVM_LOW
        )

        start_item(req);

        req.cmd   = ahb_seq_item::AHB_WRITE;
        req.addr  = 32'h0000_000C;
        req.wdata = 32'h0000_0000;
        req.size  = 3'b010;

        finish_item(req);


        //======================================================
        // 4. ARM AWAY
        //======================================================

        req = ahb_seq_item::type_id::create("arm_away_write");

        `uvm_info(
            "MOTION_AHB_SEQ",
            "Sending ARM_AWAY command",
            UVM_LOW
        )

        start_item(req);

        req.cmd   = ahb_seq_item::AHB_WRITE;
        req.addr  = 32'h0000_0000;
        req.wdata = 32'h0000_0001;
        req.size  = 3'b010;

        finish_item(req);


        `uvm_info(
            "MOTION_AHB_SEQ",
            "Motion AHB sequence COMPLETED",
            UVM_LOW
        )

    endtask

endclass