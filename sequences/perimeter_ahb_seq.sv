class perimeter_ahb_seq extends ahb_base_seq;

    `uvm_object_utils(perimeter_ahb_seq)

    function new(string name = "perimeter_ahb_seq");
        super.new(name);
    endfunction


    task body();

        ahb_seq_item req;

        `uvm_info("PERIM_AHB_SEQ",
                  "Perimeter AHB sequence STARTED",
                  UVM_LOW)


        //==================================================
        // 1. Configure Zone 0 as PERIMETER
        //==================================================

        req = ahb_seq_item::type_id::create("zone_type_write");

        `uvm_info("PERIM_AHB_SEQ",
                  "Configuring Zone 0 as PERIMETER",
                  UVM_LOW)

        start_item(req);

        req.cmd   = ahb_seq_item::AHB_WRITE;
        req.addr  = 32'h0000_0200;
        req.wdata = 32'h0000_0002;
        req.size  = 3'b010;

        finish_item(req);

        `uvm_info("PERIM_AHB_SEQ",
                  $sformatf(
                      "ZONE_TYPE WRITE completed: HRESP=%0d",
                      req.resp),
                  UVM_LOW)


        //==================================================
        // 2. Enable Zone 0
        //==================================================

        req = ahb_seq_item::type_id::create("zone_enable_write");

        `uvm_info("PERIM_AHB_SEQ",
                  "Enabling Zone 0",
                  UVM_LOW)

        start_item(req);

        req.cmd   = ahb_seq_item::AHB_WRITE;
        req.addr  = 32'h0000_0018;
        req.wdata = 32'h0000_0001;
        req.size  = 3'b010;

        finish_item(req);

        `uvm_info("PERIM_AHB_SEQ",
                  $sformatf(
                      "ZONE_ENABLE WRITE completed: HRESP=%0d",
                      req.resp),
                  UVM_LOW)


        //==================================================
        // 3. Configure EXIT_DELAY
        //==================================================

        req = ahb_seq_item::type_id::create("exit_delay_write");

        `uvm_info("PERIM_AHB_SEQ",
                  "Configuring EXIT_DELAY = 10",
                  UVM_LOW)

        start_item(req);

        req.cmd   = ahb_seq_item::AHB_WRITE;
        req.addr  = 32'h0000_0008;
        req.wdata = 32'h0000_000A;
        req.size  = 3'b010;

        finish_item(req);

        `uvm_info("PERIM_AHB_SEQ",
                  $sformatf(
                      "EXIT_DELAY WRITE completed: HRESP=%0d",
                      req.resp),
                  UVM_LOW)


        //==================================================
        // 4. ARM_AWAY
        //==================================================

        req = ahb_seq_item::type_id::create("arm_away_write");

        `uvm_info("PERIM_AHB_SEQ",
                  "Sending ARM_AWAY command",
                  UVM_LOW)

        start_item(req);

        req.cmd   = ahb_seq_item::AHB_WRITE;
        req.addr  = 32'h0000_0000;
        req.wdata = 32'h0000_0002;
        req.size  = 3'b010;

        finish_item(req);

        `uvm_info("PERIM_AHB_SEQ",
                  $sformatf(
                      "ARM_AWAY WRITE completed: HRESP=%0d",
                      req.resp),
                  UVM_LOW)


        `uvm_info("PERIM_AHB_SEQ",
                  "Perimeter AHB sequence COMPLETED",
                  UVM_LOW)

    endtask

endclass