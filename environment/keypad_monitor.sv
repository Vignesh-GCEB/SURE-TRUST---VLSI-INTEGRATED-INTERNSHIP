
class keypad_monitor #(parameter PIN_WIDTH = 16)
    extends uvm_monitor;

    `uvm_component_param_utils(keypad_monitor #(PIN_WIDTH))

    virtual keypad_if #(PIN_WIDTH) vif;

    uvm_analysis_port #(keypad_seq_item #(PIN_WIDTH)) ap;


    function new(string name = "keypad_monitor",
                 uvm_component parent = null);

        super.new(name, parent);

        ap = new("ap", this);

    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        if (!uvm_config_db#(
                virtual keypad_if #(PIN_WIDTH)
            )::get(this, "", "vif", vif)) begin

            `uvm_fatal("KEYPAD_MON",
                       "Keypad virtual interface not found")
        end

    endfunction


    task run_phase(uvm_phase phase);

        forever begin

            @(posedge vif.sys_clk);

            if (vif.pin_valid) begin

                keypad_seq_item #(PIN_WIDTH) item;

                item = keypad_seq_item #(PIN_WIDTH)::
                       type_id::create("item");

                item.pin_code  = vif.pin_code;
                item.pin_valid = vif.pin_valid;

                ap.write(item);

            end

        end

    endtask

endclass