
class smoke_ahb_seq extends ahb_base_seq;

    `uvm_object_utils(smoke_ahb_seq)

    function new(string name = "smoke_ahb_seq");
        super.new(name);
    endfunction


    task body();

        ahb_seq_item req;

        `uvm_info("SMOKE_AHB_SEQ",
                  "Smoke AHB sequence STARTED",
                  UVM_LOW)


        // ====================================================
        // 1. EXIT_DELAY CONFIGURATION
        // ====================================================

        req = ahb_seq_item::type_id::create("exit_delay_write");

        `uvm_info("SMOKE_AHB_SEQ",
                  "Creating EXIT_DELAY WRITE item",
                  UVM_LOW)

        start_item(req);

        req.cmd   = ahb_seq_item::AHB_WRITE;
        req.addr  = 32'h0000_000C;   // EXIT_DELAY
        req.wdata = 32'h0000_000A;   // Exit delay = 10
        req.size  = 3'b010;          // 32-bit word

        finish_item(req);

        `uvm_info("SMOKE_AHB_SEQ",
                  $sformatf(
                    "EXIT_DELAY WRITE completed: HRESP=%0d",
                    req.resp),
                  UVM_LOW)


        // ====================================================
        // 2. CONTROL WRITE - ARM_AWAY
        // ====================================================

        req = ahb_seq_item::type_id::create("ctrl_write");

        `uvm_info("SMOKE_AHB_SEQ",
                  "Creating CONTROL WRITE item",
                  UVM_LOW)

        start_item(req);

        req.cmd   = ahb_seq_item::AHB_WRITE;
        req.addr  = 32'h0000_0000;   // CONTROL
        req.wdata = 32'h0000_0001;   // ARM_AWAY = bit[1]
        req.size  = 3'b010;          // 32-bit word

        finish_item(req);

        `uvm_info("SMOKE_AHB_SEQ",
                  $sformatf(
                    "CONTROL WRITE completed: HRESP=%0d",
                    req.resp),
                  UVM_LOW)


        // ====================================================
        // 3. WAIT FOR SYSTEM DOMAIN
        // ====================================================

        `uvm_info("SMOKE_AHB_SEQ",
                  "Waiting for system domain to process ARM_AWAY",
                  UVM_LOW)

        #300ns;


        // ====================================================
        // 4. STATUS READ
        // ====================================================

        req = ahb_seq_item::type_id::create("status_read");

        `uvm_info("SMOKE_AHB_SEQ",
                  "Creating STATUS READ item",
                  UVM_LOW)

        start_item(req);

        req.cmd  = ahb_seq_item::AHB_READ;
        req.addr = 32'h0000_0004;     // STATUS
        req.size = 3'b010;

        finish_item(req);

        `uvm_info("SMOKE_AHB_SEQ",
                  $sformatf(
                    "STATUS READ completed: RDATA=0x%08h HRESP=%0d",
                    req.rdata,
                    req.resp),
                  UVM_LOW)


        // ====================================================
        // 5. EVENT_STATUS READ
        // ====================================================

        req = ahb_seq_item::type_id::create("event_status_read");

        `uvm_info("SMOKE_AHB_SEQ",
                  "Creating EVENT_STATUS READ item",
                  UVM_LOW)

        start_item(req);

        req.cmd  = ahb_seq_item::AHB_READ;
        req.addr = 32'h0000_002C;     // EVENT_STATUS
        req.size = 3'b010;

        finish_item(req);

        `uvm_info("SMOKE_AHB_SEQ",
                  $sformatf(
                    "EVENT_STATUS READ completed: RDATA=0x%08h HRESP=%0d",
                    req.rdata,
                    req.resp),
                  UVM_LOW)


        // ====================================================
        // SEQUENCE COMPLETE
        // ====================================================

        `uvm_info("SMOKE_AHB_SEQ",
                  "Smoke AHB sequence COMPLETED",
                  UVM_LOW)

    endtask

endclass