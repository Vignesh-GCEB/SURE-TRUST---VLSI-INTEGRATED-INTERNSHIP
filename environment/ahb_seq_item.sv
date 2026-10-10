class ahb_seq_item extends uvm_sequence_item;

    typedef enum {AHB_READ, AHB_WRITE} ahb_cmd_e;

    rand bit [31:0] addr;
    rand bit [31:0] wdata;
    rand ahb_cmd_e  cmd;
    rand bit [2:0]  size;

         bit [31:0] rdata;
         bit        resp;

    constraint size_c {
        size == 3'b010;
    }

    `uvm_object_utils(ahb_seq_item)

    function new(string name = "ahb_seq_item");
        super.new(name);
    endfunction

endclass