class ahb_monitor extends uvm_monitor;

    `uvm_component_utils(ahb_monitor)

    // ----------------------------------------
    // Virtual interface
    // ----------------------------------------
    virtual ahb_if vif;

    // ----------------------------------------
    // Analysis port
    // ----------------------------------------
    uvm_analysis_port #(ahb_seq_item) ap;


    // ----------------------------------------
    // Constructor
    // ----------------------------------------
    function new(string name = "ahb_monitor",
                 uvm_component parent = null);

        super.new(name, parent);

        ap = new("ap", this);

    endfunction


    // ----------------------------------------
    // Build Phase
    // ----------------------------------------
    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        if (!uvm_config_db#(virtual ahb_if)::get(
                this,
                "",
                "vif",
                vif
            )) begin

            `uvm_fatal("AHB_MON",
                       "AHB virtual interface not found")
        end

    endfunction


    // ----------------------------------------
    // Run Phase
    // ----------------------------------------
  /*  task run_phase(uvm_phase phase);

        forever begin

            monitor_transfer();

        end

    endtask*/


    // ----------------------------------------
    // Monitor AHB Transfer
    // ----------------------------------------
 
task run_phase(uvm_phase phase);

    ahb_seq_item pending_item;
    bit          pending_valid;

    pending_item  = null;
    pending_valid = 1'b0;

    forever begin

        // Sample AHB signals at the rising edge of HCLK.
        @(posedge vif.HCLK);

        // Discard incomplete transfers during reset.
        if (vif.HRESETn !== 1'b1) begin
            pending_item  = null;
            pending_valid = 1'b0;
        end
        else begin

            // ------------------------------------------------
            // 1. Complete the pending data phase.
            // ------------------------------------------------
            if (pending_valid && (vif.HREADY === 1'b1)) begin

                // Capture data belonging to the pending transfer.
                if (pending_item.cmd == ahb_seq_item::AHB_WRITE)
                    pending_item.wdata = vif.HWDATA;
                else
                    pending_item.rdata = vif.HRDATA;

                // Capture the response at the completion edge.
                pending_item.resp = vif.HRESP;

                `uvm_info("AHB_MON",
                          $sformatf(
                              "Transfer completed: %s addr=0x%08h data=0x%08h resp=%0b",
                              pending_item.cmd.name(),
                              pending_item.addr,
                              (pending_item.cmd == ahb_seq_item::AHB_WRITE)
                                  ? pending_item.wdata
                                  : pending_item.rdata,
                              pending_item.resp
                          ),
                          UVM_MEDIUM)

                // Publish the completed transaction.
                ap.write(pending_item);

                // Clear the pending transaction.
                pending_item  = null;
                pending_valid = 1'b0;
            end

            // ------------------------------------------------
            // 2. Capture a newly accepted address phase.
            // ------------------------------------------------
            if ((vif.HREADY === 1'b1) &&
                (vif.HSEL   === 1'b1) &&
                (vif.HTRANS[1] === 1'b1)) begin

                pending_item =
                    ahb_seq_item::type_id::create("pending_item");

                pending_item.addr = vif.HADDR;
                pending_item.size = vif.HSIZE;

                if (vif.HWRITE === 1'b1)
                    pending_item.cmd = ahb_seq_item::AHB_WRITE;
                else
                    pending_item.cmd = ahb_seq_item::AHB_READ;

                pending_valid = 1'b1;

                `uvm_info("AHB_MON",
                          $sformatf(
                              "Address accepted: %s addr=0x%08h size=%0d",
                              pending_item.cmd.name(),
                              pending_item.addr,
                              pending_item.size
                          ),
                          UVM_MEDIUM)
            end

        end
    end

endtask
endclass