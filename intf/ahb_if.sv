interface ahb_if;

    logic        HCLK;
    logic        HRESETn;

    logic        HSEL;
    logic [31:0] HADDR;
    logic [1:0]  HTRANS;
    logic        HWRITE;
    logic [2:0]  HSIZE;
    logic [31:0] HWDATA;
    logic        HREADY;

    logic [31:0] HRDATA;
    logic        HREADYOUT;
    logic        HRESP;

endinterface