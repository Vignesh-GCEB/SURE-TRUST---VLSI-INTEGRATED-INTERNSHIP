
class pin_failure_keypad_seq #(
    parameter int PIN_WIDTH = 16
) extends keypad_base_seq #(PIN_WIDTH);

    `uvm_object_param_utils(
        pin_failure_keypad_seq #(PIN_WIDTH)
    )

    function new(string name = "pin_failure_keypad_seq");
        super.new(name);
    endfunction

    task body();

        keypad_seq_item #(PIN_WIDTH) req;

        `uvm_info("PIN_FAILURE_SEQ",
                  "Starting three invalid PIN attempts",
                  UVM_LOW)

        repeat (3) begin

            req = keypad_seq_item #(PIN_WIDTH)::type_id::create("req");

            start_item(req);

            req.pin_code  = '0;  // Assumed incorrect PIN
            req.pin_valid = 1'b1;

            finish_item(req);

            `uvm_info("PIN_FAILURE_SEQ",
                      $sformatf("Submitted invalid PIN: 0x%0h",
                                req.pin_code),
                      UVM_MEDIUM)

        end

        `uvm_info("PIN_FAILURE_SEQ",
                  "Completed three PIN attempts",
                  UVM_LOW)

    endtask

endclass