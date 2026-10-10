class pin_status_ahb_seq extends ahb_base_seq;

    `uvm_object_utils(pin_status_ahb_seq)

    bit [31:0] status_rdata;

    function new(string name = "pin_status_ahb_seq");
        super.new(name);
    endfunction

    task body();
        ahb_seq_item req;

        `uvm_info("PIN_STATUS_AHB_SEQ",
                  "Reading STATUS register",
                  UVM_LOW)

        req = ahb_seq_item::type_id::create("req");

        start_item(req);
        req.cmd  = ahb_seq_item::AHB_READ;
        req.addr = 32'h0000_0004;
        req.size = 3'b010;
        finish_item(req);

        status_rdata = req.rdata;

        if (req.resp != 1'b0) begin
            `uvm_error("PIN_STATUS_AHB_SEQ",
                       "AHB STATUS register read failed")
        end
        else begin
            `uvm_info("PIN_STATUS_AHB_SEQ",
                      $sformatf("STATUS = 0x%08h, KEYPAD_LOCKED = %0b",
                                status_rdata, status_rdata[6]),
                      UVM_LOW)
        end
    endtask

endclass