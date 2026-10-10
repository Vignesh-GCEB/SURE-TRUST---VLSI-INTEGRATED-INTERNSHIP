class ahb_exit_delay_read_seq extends ahb_base_seq;

    `uvm_object_utils(ahb_exit_delay_read_seq)

    function new(string name = "ahb_exit_delay_read_seq");
        super.new(name);
    endfunction

    task body();

        ahb_seq_item req;

        `uvm_info("EXIT_DELAY_READ",
                  "EXIT_DELAY read sequence STARTED",
                  UVM_LOW)

        req = ahb_seq_item::type_id::create("exit_delay_read");

        start_item(req);

        req.cmd  = ahb_seq_item::AHB_READ;
        req.addr = 32'h0000_000C;
        req.size = 3'b010;

        finish_item(req);

        `uvm_info("EXIT_DELAY_READ",
                  $sformatf(
                      "EXIT_DELAY READ completed: RDATA=0x%08h HRESP=%0d",
                      req.rdata,
                      req.resp),
                  UVM_LOW)

        `uvm_info("EXIT_DELAY_READ",
                  "EXIT_DELAY read sequence COMPLETED",
                  UVM_LOW)

    endtask

endclass