interface keypad_if #(parameter PIN_WIDTH = 16);

    logic                 sys_clk;
    logic                 sys_reset_n;
    logic                 pin_valid;
    logic [PIN_WIDTH-1:0] pin_code;

endinterface