class keypad_driver #(parameter PIN_WIDTH = 16)
    extends uvm_driver #(keypad_seq_item #(PIN_WIDTH));

    `uvm_component_param_utils(keypad_driver #(PIN_WIDTH))

    virtual keypad_if #(PIN_WIDTH) vif;

    function new(string name = "keypad_driver",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        if (!uvm_config_db#(
                virtual keypad_if #(PIN_WIDTH)
            )::get(this, "", "vif", vif)) begin

            `uvm_fatal("KEYPAD_DRV",
                       "Keypad virtual interface not found")
        end

    endfunction


    task run_phase(uvm_phase phase);

        keypad_seq_item #(PIN_WIDTH) req;

        forever begin

            seq_item_port.get_next_item(req);

            drive_pin(req);

            seq_item_port.item_done();

        end

    endtask

     task drive_pin(keypad_seq_item #(PIN_WIDTH) req);

   			 @(posedge vif.sys_clk);

    			vif.pin_code  <= req.pin_code;
   				 vif.pin_valid <= req.pin_valid;

   			 @(posedge vif.sys_clk);

   				 vif.pin_valid <= 1'b0;

    endtask

endclass