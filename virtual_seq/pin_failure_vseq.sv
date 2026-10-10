class pin_failure_vseq #(
    parameter int NUM_ZONES = 8,
    parameter int PIN_WIDTH = 16
) extends base_virtual_sequence #(NUM_ZONES, PIN_WIDTH);

    `uvm_object_param_utils(
        pin_failure_vseq #(NUM_ZONES, PIN_WIDTH)
    )

    function new(string name = "pin_failure_vseq");
        super.new(name);
    endfunction

    task body();

        pin_config_ahb_seq              config_seq;
        pin_failure_keypad_seq #(PIN_WIDTH) keypad_seq;
        pin_status_ahb_seq               status_seq;

        super.body();

        `uvm_info("PIN_FAILURE_VSEQ",
                  "Starting PIN failure verification",
                  UVM_LOW)

        // Step 1: Configure the valid PIN through AHB.
        config_seq =
            pin_config_ahb_seq::type_id::create("config_seq");

        config_seq.start(vseqr.ahb_seqr);

        // Allow the configuration CDC handshake to complete.
        #200ns;

        // Step 2: Submit three invalid PIN attempts.
        keypad_seq =
            pin_failure_keypad_seq #(PIN_WIDTH)::type_id::create(
                "keypad_seq"
            );

        keypad_seq.start(vseqr.keypad_seqr);

        // Allow authentication and status CDC to settle.
        #200ns;

        // Step 3: Read STATUS through AHB.
        status_seq =
            pin_status_ahb_seq::type_id::create("status_seq");

        status_seq.start(vseqr.ahb_seqr);

        // Step 4: Check the keypad lockout status.
        if (status_seq.status_rdata[6] !== 1'b1) begin
            `uvm_error("PIN_FAILURE_CHECK",
                       $sformatf(
                           "Expected KEYPAD_LOCKED=1, STATUS=0x%08h",
                           status_seq.status_rdata
                       ))
        end
        else begin
            `uvm_info("PIN_FAILURE_CHECK",
                      "PASS: Keypad lockout asserted",
                      UVM_LOW)
        end

        `uvm_info("PIN_FAILURE_VSEQ",
                  "PIN failure verification completed",
                  UVM_LOW)

    endtask

endclass