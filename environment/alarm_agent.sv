class alarm_agent extends uvm_agent;

    `uvm_component_utils(alarm_agent)

    alarm_monitor monitor;


    function new(string name = "alarm_agent",
                 uvm_component parent = null);

        super.new(name, parent);

    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        monitor =
            alarm_monitor::type_id::create("monitor", this);

    endfunction

endclass