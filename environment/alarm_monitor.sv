class alarm_monitor extends uvm_monitor;

    `uvm_component_utils(alarm_monitor)

    virtual alarm_if vif;

    uvm_analysis_port #(alarm_seq_item) ap;


    function new(string name = "alarm_monitor",
                 uvm_component parent = null);

        super.new(name, parent);

        ap = new("ap", this);

    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        if (!uvm_config_db#(virtual alarm_if)::get(
                this, "", "vif", vif)) begin

            `uvm_fatal("ALARM_MON",
                       "Alarm virtual interface not found")
        end

    endfunction

task run_phase(uvm_phase phase);
    forever begin
        @(posedge vif.sys_clk);

        begin
            alarm_seq_item item;

            item = alarm_seq_item::type_id::create("item");

            item.siren        = vif.siren;
            item.strobe       = vif.strobe;
            item.alarm_active = vif.alarm_active;

            ap.write(item);
        end
    end
endtask

endclass