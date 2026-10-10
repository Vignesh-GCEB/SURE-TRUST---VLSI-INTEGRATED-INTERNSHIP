class ahb_status_read_seq extends ahb_base_seq;

    `uvm_object_utils(ahb_status_read_seq)

    function new(string name = "ahb_status_read_seq");
        super.new(name);
    endfunction


    task body();

        ahb_seq_item req;

        `uvm_info("STATUS_AHB_SEQ",
                  "STATUS read sequence STARTED",
                  UVM_LOW)

        req = ahb_seq_item::type_id::create("status_read");

        start_item(req);

        req.cmd  = ahb_seq_item::AHB_READ;
        req.addr = 32'h0000_0004;
        req.size = 3'b010;

        finish_item(req);

        `uvm_info("STATUS_AHB_SEQ",
                  $sformatf(
                      "STATUS READ completed: RDATA=0x%08h HRESP=%0d",
                      req.rdata,
                      req.resp),
                  UVM_LOW)

        `uvm_info("STATUS_AHB_SEQ",
                  "STATUS read sequence COMPLETED",
                  UVM_LOW)

    endtask

endclass