class irq_monitor extends uvm_monitor;

    `uvm_component_utils(irq_monitor)

    virtual irq_if vif;

    uvm_analysis_port #(irq_seq_item) ap;

    bit irq_prev;


    function new(string name = "irq_monitor",
                 uvm_component parent = null);

        super.new(name, parent);

        ap = new("ap", this);

    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        if (!uvm_config_db#(virtual irq_if)::get(
                this, "", "vif", vif)) begin

            `uvm_fatal("IRQ_MON",
                       "IRQ virtual interface not found")
        end

    endfunction


    task run_phase(uvm_phase phase);

        irq_prev = 1'b0;

        forever begin

            @(posedge vif.sys_clk);

            // Detect IRQ rising edge
            if (vif.irq && !irq_prev) begin

                irq_seq_item item;

                item = irq_seq_item::type_id::create("item");

                item.irq = 1'b1;

                ap.write(item);

            end

            irq_prev = vif.irq;

        end

    endtask

endclass