class pin_config_ahb_seq extends ahb_base_seq;

    `uvm_object_utils(pin_config_ahb_seq)

    function new(string name = "pin_config_ahb_seq");
        super.new(name);
    endfunction

    task body();
        ahb_seq_item req;

        // Configure the valid PIN
        req = ahb_seq_item::type_id::create("pin_config_req");

        start_item(req);
        req.cmd   = ahb_seq_item::AHB_WRITE;
        req.addr  = 32'h0000_0014;
        req.wdata = 32'h0000_1234;
        req.size  = 3'b010;
        finish_item(req);

        if (req.resp != 1'b0)
            `uvm_error("PIN_CONFIG_AHB_SEQ", "PIN_CONFIG write failed")
        else
            `uvm_info("PIN_CONFIG_AHB_SEQ", "PIN_CONFIG write completed", UVM_LOW)

        // Configure a nonzero lockout duration
        req = ahb_seq_item::type_id::create("lockout_delay_req");

        start_item(req);
        req.cmd   = ahb_seq_item::AHB_WRITE;
        req.addr  = 32'h0000_0040;
        req.wdata = 32'd60;
        req.size  = 3'b010;
        finish_item(req);

        if (req.resp != 1'b0)
            `uvm_error("PIN_CONFIG_AHB_SEQ", "LOCKOUT_DELAY write failed")
        else
            `uvm_info("PIN_CONFIG_AHB_SEQ", "LOCKOUT_DELAY write completed", UVM_LOW)

    endtask

endclass