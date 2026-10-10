class perimeter_alarm_vseq #(
    parameter int NUM_ZONES = 8,
    parameter int PIN_WIDTH = 16
) extends base_virtual_sequence #(NUM_ZONES, PIN_WIDTH);

    `uvm_object_param_utils(
        perimeter_alarm_vseq #(NUM_ZONES, PIN_WIDTH)
    )


    function new(string name = "perimeter_alarm_vseq");
        super.new(name);
    endfunction


    task body();

        perimeter_ahb_seq    ahb_seq;
       // perimeter_sensor_seq sensor_seq;
      	ahb_status_read_seq status_seq;
      ahb_exit_delay_read_seq exit_delay_read_seq;


        `uvm_info("PERIM_VSEQ",
                  "Perimeter alarm virtual sequence STARTED",
                  UVM_LOW)


        // ====================================================
        // Check virtual sequencer
        // ====================================================

        super.body();


        // ====================================================
        // 1. Start Perimeter AHB Sequence
        //    - Configure Zone 0 as PERIMETER
        //    - Enable Zone 0
        //    - ARM_AWAY
        // ====================================================

        ahb_seq =
            perimeter_ahb_seq::type_id::create("ahb_seq");

        `uvm_info("PERIM_VSEQ",
                  "Starting perimeter AHB sequence",
                  UVM_LOW)

        ahb_seq.start(vseqr.ahb_seqr);

        `uvm_info("PERIM_VSEQ",
                  "Perimeter AHB sequence COMPLETED",
                  UVM_LOW)


        // ====================================================
        // 2. Start Perimeter Sensor Sequence
        //    - Activate Zone 0
        // ====================================================

       /* sensor_seq =
            perimeter_sensor_seq::type_id::create("sensor_seq");

        `uvm_info("PERIM_VSEQ",
                  "Starting perimeter sensor sequence",
                  UVM_LOW)

        sensor_seq.start(vseqr.sensor_seqr);

        `uvm_info("PERIM_VSEQ",
                  "Perimeter sensor sequence COMPLETED",
                  UVM_LOW)*/

      #300ns;
      
      exit_delay_read_seq =
    ahb_exit_delay_read_seq::type_id::create("exit_delay_read_seq");

`uvm_info("PERIM_VSEQ",
          "Starting EXIT_DELAY read sequence",
          UVM_LOW)

exit_delay_read_seq.start(vseqr.ahb_seqr);

`uvm_info("PERIM_VSEQ",
          "EXIT_DELAY read sequence COMPLETED",
          UVM_LOW)
      
      	status_seq =
    ahb_status_read_seq::type_id::create("status_seq");

`uvm_info("PERIM_VSEQ",
          "Starting STATUS read sequence",
          UVM_LOW)

status_seq.start(vseqr.ahb_seqr);

`uvm_info("PERIM_VSEQ",
          "STATUS read sequence COMPLETED",
          UVM_LOW)

        // ====================================================
        // Sequence Complete
        // ====================================================

        `uvm_info("PERIM_VSEQ",
                  "Perimeter alarm virtual sequence COMPLETED",
                  UVM_LOW)

    endtask

endclass