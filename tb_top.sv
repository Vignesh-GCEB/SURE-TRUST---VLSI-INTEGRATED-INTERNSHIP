`timescale 1ns/1ps

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "ahb_if.sv"
`include "sensor_interface.sv"
`include "keypad_interface.sv"
`include "alarm_interface.sv"
`include "irq_interface.sv"

`include "ahb_seq_item.sv"
`include "sensor_seq_item.sv"
`include "keypad_seq_item.sv"
`include "alarm_seq_item.sv"
`include "irq_sequence_item.sv"

`include "ahb_sequencer.sv"
`include "sensor_sequencer.sv"
`include "keypad_sequencer.sv"

`include "ahb_driver.sv"
`include "sensor_driver.sv"
`include "keypad_driver.sv"

`include "ahb_monitor.sv"
`include "sensor_monitor.sv"
`include "keypad_monitor.sv"
`include "alarm_monitor.sv"
`include "irq_monitor.sv"

`include "ahb_agent.sv"
`include "sensor_agent.sv"
`include "keypad_agent.sv"
`include "alarm_agent.sv"
`include "irq_agent.sv"

`include "alarm_reference_model.sv"
`include "alarm_scoreboard.sv"

`include "virtual_sequencer.sv"
`include "smart_home_alarm_env.sv"

`include "ahb_base_seq.sv"
`include "sensor_base_seq.sv"
`include "keypad_base_seq.sv"


`include "smoke_ahb_seq.sv"
`include "perimeter_ahb_seq.sv"
`include "perimeter_sensor_seq.sv"
`include "ahb_status_read_seq.sv"
`include "ahb_exit_delay_read_seq.sv"
`include "motion_ahb_seq.sv"
`include "motion_sensor_seq.sv"
`include "contr_write_status_read_ahb_seq.sv"
`include "pin_failure_keypad_seq.sv"
`include "pin_status_ahb_seq.sv"
`include "pin_config_ahb_seq.sv"


`include "base_virtual_sequence.sv"

`include "smoke_virtual_sequence.sv"
`include "perimeter_alarm_vseq.sv"
`include "motion_alarm_vseq.sv"
`include "contr_write_status_read_vseq.sv"
`include "pin_failure_vseq.sv"


`include "alarm_base_test.sv"

`include "alarm_smoke_test.sv"
`include "perimeter_alarm_test.sv"
`include "motion_alarm_test.sv"
`include "contr_write_status_read_test.sv"
`include "pin_failure_test.sv"

module tb_top;

    //============================================================
    // Parameters
    //============================================================

    parameter int NUM_ZONES          = 8;
    parameter int PIN_WIDTH          = 16;
    parameter int TIMER_WIDTH        = 24;
    parameter int EVENT_WIDTH        = 32;
    parameter int EVENT_FIFO_DEPTH   = 8;
    parameter int SYNC_STAGES        = 2;
    parameter int DEBOUNCE_CYCLES    = 4;
    parameter int TICK_DIV           = 1;
    parameter int MAX_PIN_ATTEMPTS   = 3;
    parameter int TOGGLE_LIMIT       = 8;
    parameter int TOGGLE_WINDOW      = 1024;
    parameter bit SW_DISARM_TRUSTED  = 1'b1;


    //============================================================
    // Clock signals
    //============================================================

    logic sensor_clk;
    logic sys_clk;
    logic HCLK;


    //============================================================
    // Reset signals
    //============================================================

    logic sensor_reset_n;
    logic sys_reset_n;
    logic HRESETn;


    //============================================================
    // Interface instances
    //============================================================

    ahb_if ahb_vif();

    sensor_if #(NUM_ZONES) sensor_vif();

    keypad_if #(PIN_WIDTH) keypad_vif();

    alarm_if alarm_vif();

    irq_if irq_vif();


    //============================================================
    // Clock generation
    //============================================================

    // Sensor clock
    initial begin
        sensor_clk = 1'b0;

        forever begin
            #5;
            sensor_clk = ~sensor_clk;
        end
    end


    // System clock
    initial begin
        sys_clk = 1'b0;

        forever begin
            #10;
            sys_clk = ~sys_clk;
        end
    end


    // AHB clock
    initial begin
        HCLK = 1'b0;

        forever begin
            #5;
            HCLK = ~HCLK;
        end
    end


    //============================================================
    // Reset generation
    //============================================================

    initial begin

        sensor_reset_n = 1'b0;
        sys_reset_n    = 1'b0;
        HRESETn        = 1'b0;

        #100;

        sensor_reset_n = 1'b1;
        sys_reset_n    = 1'b1;
        HRESETn        = 1'b1;

    end


    //============================================================
    // Connect clocks to interfaces
    //============================================================

    assign sensor_vif.sensor_clk = sensor_clk;

    assign keypad_vif.sys_clk = sys_clk;
    assign alarm_vif.sys_clk  = sys_clk;
    assign irq_vif.sys_clk    = sys_clk;

    assign ahb_vif.HCLK = HCLK;


    //============================================================
    // Connect resets to interfaces
    //============================================================

    assign sensor_vif.sensor_reset_n = sensor_reset_n;

    assign keypad_vif.sys_reset_n = sys_reset_n;

    assign ahb_vif.HRESETn = HRESETn;


    //============================================================
    // Initial AHB values
    //============================================================

    initial begin

        ahb_vif.HSEL   = 1'b0;
        ahb_vif.HADDR  = '0;
        ahb_vif.HTRANS = 2'b00;
        ahb_vif.HWRITE = 1'b0;
        ahb_vif.HSIZE  = 3'b010;
        ahb_vif.HWDATA = '0;
      	

        // Initial standalone-slave condition
       // ahb_vif.HREADY = 1'b1;

    end
	
  	
  	assign ahb_vif.HREADY = ahb_vif.HREADYOUT;

    //============================================================
    // Initial sensor inputs
    //============================================================

    initial begin

        sensor_vif.sensor_in = '0;

    end


    //============================================================
    // Initial keypad inputs
    //============================================================

    initial begin

        keypad_vif.pin_valid = 1'b0;
        keypad_vif.pin_code  = '0;

    end


    //============================================================
    // DUT
    //============================================================

    smart_home_alarm_top #(

        .NUM_ZONES          (NUM_ZONES),
        .PIN_WIDTH          (PIN_WIDTH),
        .TIMER_WIDTH        (TIMER_WIDTH),
        .EVENT_WIDTH        (EVENT_WIDTH),
        .EVENT_FIFO_DEPTH   (EVENT_FIFO_DEPTH),
        .SYNC_STAGES        (SYNC_STAGES),
        .DEBOUNCE_CYCLES    (DEBOUNCE_CYCLES),
        .TICK_DIV           (TICK_DIV),
        .MAX_PIN_ATTEMPTS   (MAX_PIN_ATTEMPTS),
        .TOGGLE_LIMIT       (TOGGLE_LIMIT),
        .TOGGLE_WINDOW      (TOGGLE_WINDOW),
        .SW_DISARM_TRUSTED  (SW_DISARM_TRUSTED)

    ) dut (

        // Sensor domain
        .sensor_clk     (sensor_clk),
        .sensor_reset_n (sensor_reset_n),
        .sensor_in      (sensor_vif.sensor_in),

        // System domain
        .sys_clk        (sys_clk),
        .sys_reset_n    (sys_reset_n),
        .pin_valid      (keypad_vif.pin_valid),
        .pin_code       (keypad_vif.pin_code),

        // Alarm outputs
        .siren          (alarm_vif.siren),
        .strobe         (alarm_vif.strobe),
        .alarm_active   (alarm_vif.alarm_active),

        // AHB
        .HCLK           (HCLK),
        .HRESETn        (HRESETn),
        .HSEL           (ahb_vif.HSEL),
        .HADDR          (ahb_vif.HADDR),
        .HTRANS        (ahb_vif.HTRANS),
        .HWRITE        (ahb_vif.HWRITE),
        .HSIZE         (ahb_vif.HSIZE),
        .HWDATA        (ahb_vif.HWDATA),
        .HREADY        (ahb_vif.HREADY),

        .HRDATA        (ahb_vif.HRDATA),
        .HREADYOUT     (ahb_vif.HREADYOUT),
        .HRESP         (ahb_vif.HRESP),

        // Interrupt
        .irq           (irq_vif.irq)

    );


    //============================================================
    // UVM virtual interface configuration
    //============================================================

    initial begin

        // AHB
        uvm_config_db#(virtual ahb_if)::set(
            null,
            "uvm_test_top.env.ahb_ag.*",
            "vif",
            ahb_vif
        );


        // Sensor
        uvm_config_db#(
            virtual sensor_if #(NUM_ZONES)
        )::set(
            null,
            "uvm_test_top.env.sensor_ag.*",
            "vif",
            sensor_vif
        );


        // Keypad
        uvm_config_db#(
            virtual keypad_if #(PIN_WIDTH)
        )::set(
            null,
            "uvm_test_top.env.keypad_ag.*",
            "vif",
            keypad_vif
        );


        // Alarm
        uvm_config_db#(virtual alarm_if)::set(
            null,
            "uvm_test_top.env.alarm_ag.*",
            "vif",
            alarm_vif
        );


        // IRQ
        uvm_config_db#(virtual irq_if)::set(
            null,
            "uvm_test_top.env.irq_ag.*",
            "vif",
            irq_vif
        );

    end
	initial begin
      $dumpfile("tb_top.vcd");
      $dumpvars(0, tb_top);
      
    end

    //============================================================
    // Start UVM
    //============================================================

    initial begin

        run_test();

    end

endmodule