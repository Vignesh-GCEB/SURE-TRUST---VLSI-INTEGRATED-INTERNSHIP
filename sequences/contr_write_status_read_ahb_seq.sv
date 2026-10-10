
class contr_write_status_read_ahb_seq extends ahb_base_seq;

    `uvm_object_utils(contr_write_status_read_ahb_seq)

    function new(string name = "contr_write_status_read_ahb_seq");
        super.new(name);
    endfunction

    task body();

        ahb_seq_item req;
        bit [31:0] initial_status;
        bit [31:0] final_status;

        `uvm_info("CONTR_AHB_SEQ",
                  "CONTROL write and STATUS read sequence STARTED",
                  UVM_LOW)

        // ==========================================
        // 1. INITIAL STATUS READ
        // ==========================================
        req = ahb_seq_item::type_id::create("initial_status_read");

        start_item(req);
        req.cmd  = ahb_seq_item::AHB_READ;
        req.addr = 32'h0000_0008;
        req.size = 3'b010;
        finish_item(req);

        initial_status = req.rdata;

        `uvm_info("CONTR_AHB_SEQ",
                  $sformatf(
                      "Initial STATUS: RDATA=0x%08h HRESP=%0d",
                      req.rdata, req.resp),
                  UVM_LOW)

       // ==========================================
        // 2. EXIT_DELAY CONFIGURATION
        // ==========================================
        req = ahb_seq_item::type_id::create("exit_delay_write");

        start_item(req);
        req.cmd   = ahb_seq_item::AHB_WRITE;
        req.addr  = 32'h0000_000C;  // EXIT_DELAY
        req.wdata = 32'h0000_000A;  // Value = 10
        req.size  = 3'b010;
        finish_item(req);

        `uvm_info("CONTR_AHB_SEQ",
                  $sformatf(
                      "EXIT_DELAY WRITE: WDATA=0x%08h HRESP=%0d",
                      req.wdata, req.resp),
                  UVM_LOW)

        /*// ==========================================
        // 3. CONTROL WRITE - ARM_STAY
        // ==========================================
        req = ahb_seq_item::type_id::create("control_write");

        start_item(req);
        req.cmd   = ahb_seq_item::AHB_WRITE;
        req.addr  = 32'h0000_0000;  // CONTROL
        req.wdata = 32'h0000_0001;  // ARM_STAY
        req.size  = 3'b010;
        finish_item(req);

        `uvm_info("CONTR_AHB_SEQ",
                  $sformatf(
                      "CONTROL WRITE: WDATA=0x%08h HRESP=%0d",
                      req.wdata, req.resp),
                  UVM_LOW)*/

        // ==========================================
        // 4. WAIT FOR SYSTEM DOMAIN
        // ==========================================
        `uvm_info("CONTR_AHB_SEQ",
                  "Waiting 300ns for system-domain processing",
                  UVM_LOW)

        #300ns;

        // ==========================================
        // 5. FINAL STATUS READ
        // ==========================================
        req = ahb_seq_item::type_id::create("final_status_read");

        start_item(req);
        req.cmd  = ahb_seq_item::AHB_READ;
        req.addr = 32'h0000_000c;  // STATUS
        req.size = 3'b010;
        finish_item(req);

        final_status = req.rdata;

        `uvm_info("CONTR_AHB_SEQ",
                  $sformatf(
                      "Final STATUS: RDATA=0x%08h STATE=%0d HRESP=%0d",
                      final_status,
                      final_status[2:0],
                      req.resp),
                  UVM_LOW)

        `uvm_info("CONTR_AHB_SEQ",
                  $sformatf(
                      "Sequence completed: Initial STATUS=0x%08h Final STATUS=0x%08h",
                      initial_status, final_status),
                  UVM_LOW)

    endtask

endclass
