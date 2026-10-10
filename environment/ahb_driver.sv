class ahb_driver extends uvm_driver #(ahb_seq_item);

    `uvm_component_utils(ahb_driver)

    // Virtual interface
    virtual ahb_if vif;


    // ----------------------------------------
    // Constructor
    // ----------------------------------------
    function new(string name = "ahb_driver",
                 uvm_component parent = null);

        super.new(name, parent);

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

            `uvm_fatal("AHB_DRV",
                       "AHB virtual interface not found")

        end

    endfunction


    // ----------------------------------------
    // Run Phase
    // ----------------------------------------
    task run_phase(uvm_phase phase);

        ahb_seq_item req;

        forever begin

            `uvm_info("AHB_DRV",
                      "Waiting for AHB sequence item",
                      UVM_LOW)

            seq_item_port.get_next_item(req);

            `uvm_info("AHB_DRV",
                      "AHB sequence item RECEIVED",
                      UVM_LOW)

            case(req.cmd)

                ahb_seq_item::AHB_WRITE:
                    drive_write(req);

                ahb_seq_item::AHB_READ:
                    drive_read(req);

                default:
                    `uvm_error("AHB_DRV",
                               "Unknown AHB command")

            endcase

            seq_item_port.item_done();

        end

    endtask


    // ====================================================
    // WRITE TRANSACTION
    // ====================================================

  
task drive_write(ahb_seq_item req);

    // Phase 1: Drive address and control
    @(negedge vif.HCLK);

    vif.HSEL   = 1'b1;
    vif.HADDR  = req.addr;
    vif.HTRANS = 2'b10;  // NONSEQ
    vif.HWRITE = 1'b1;
    vif.HSIZE  = req.size;

    // Wait until the address phase is accepted.
    // Keep address/control stable during wait states.
    do begin
        @(posedge vif.HCLK);
    end while (vif.HREADY !== 1'b1);

    // Phase 2: Drive write data.
    // Change address-phase signals on the falling edge.
    @(negedge vif.HCLK);

    vif.HWDATA = req.wdata;
    vif.HSEL   = 1'b0;
    vif.HTRANS = 2'b00;
    vif.HADDR  = '0;
    vif.HWRITE = 1'b0;

    // Hold write data until the transfer completes.
    do begin
        @(posedge vif.HCLK);
    end while (vif.HREADY !== 1'b1);

    // Capture the response for the completed transfer.
    req.resp = vif.HRESP;

    // Return write data to idle after completion.
    @(negedge vif.HCLK);
    vif.HWDATA = '0;

endtask



    // ====================================================
    // READ TRANSACTION
    // ====================================================

    
task drive_read(ahb_seq_item req);

    // Phase 1: Drive address and control
    @(negedge vif.HCLK);

    vif.HSEL   = 1'b1;
    vif.HADDR  = req.addr;
    vif.HTRANS = 2'b10;  // NONSEQ
    vif.HWRITE = 1'b0;   // READ
    vif.HSIZE  = req.size;

    // Wait for address-phase acceptance
    do begin
        @(posedge vif.HCLK);
    end while (vif.HREADY !== 1'b1);

    // Phase 2: Deassert selection for this
    // single, non-pipelined transfer
    @(negedge vif.HCLK);

    vif.HSEL   = 1'b0;
    vif.HTRANS = 2'b00;  // IDLE
    vif.HADDR  = '0;
    vif.HWRITE = 1'b0;

    // Wait for data-phase completion
    do begin
        @(posedge vif.HCLK);
    end while (vif.HREADY !== 1'b1);

    // Capture data and response at completion
    req.rdata = vif.HRDATA;
    req.resp  = vif.HRESP;

endtask


endclass