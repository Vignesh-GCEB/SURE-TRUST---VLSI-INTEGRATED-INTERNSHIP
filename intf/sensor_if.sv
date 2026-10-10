interface sensor_if #(parameter NUM_ZONES = 8);

    logic sensor_clk;
    logic sensor_reset_n;

    logic [NUM_ZONES-1:0] sensor_in;

endinterface