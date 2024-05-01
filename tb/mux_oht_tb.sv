///////////////////////////////////////////////////////////////////////////////
// multiplexer with one-hot select,
// testbench
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module mux_oht_tb #(
    // data type
    parameter  type DAT_T = logic [8-1:0],
    // size parameters
    int unsigned WIDTH = 16,
    int unsigned SPLIT = 4
);

    // size local parameters
    localparam int unsigned WIDTH_LOG = $clog2(WIDTH);
    localparam int unsigned SPLIT_LOG = $clog2(SPLIT);

    // timing constant
    localparam time T = 10ns;

    localparam int unsigned IMPLEMENTATIONS = 2;

    // one-hot select and data array inputs
    logic [WIDTH-1:0] oht;
    DAT_T             ary [WIDTH-1:0];
    // data and valid outputs
    logic             vld [0:IMPLEMENTATIONS-1];
    DAT_T             dat [0:IMPLEMENTATIONS-1];
    // reference signals
    logic         ref_vld;
    DAT_T         ref_dat;

///////////////////////////////////////////////////////////////////////////////
// reference calculation and checking of DUT outputs against reference
///////////////////////////////////////////////////////////////////////////////

    function automatic [WIDTH-1:0] ref_mux_oht (
        logic [WIDTH-1:0] oht,
        DAT_T             ary [WIDTH-1:0]
    );
        for (int i=0; i<WIDTH; i++) begin
            if (oht[i])  ref_mux_oht = ary[i];
        end
    endfunction: ref_mux_oht

    // reference
    always_comb
    begin
        ref_vld =           |(oht     );
        ref_dat = ref_mux_oht(oht, ary);
    end

    // check enable depending on test
    bit [0:IMPLEMENTATIONS-1] check_enable;

    // output checking task
    task check();
        #T;
        for (int unsigned i=0; i<IMPLEMENTATIONS; i++) begin
            if (check_enable[i]) begin
                assert (vld[i] ==  ref_vld) else $error("IMPLEMENTATION[%0d]:  vld != 1'b%b"  , i,            ref_vld);
                assert (dat[i] ==? ref_dat) else $error("IMPLEMENTATION[%0d]:  dat != %0d'b%b", i, WIDTH, ref_dat);
            end
        end
        #T;
    endtask: check

///////////////////////////////////////////////////////////////////////////////
// test
///////////////////////////////////////////////////////////////////////////////

    // test name
    string        test_name;

    // test sequence
    initial
    begin
        // initialize input array
        for (int unsigned i=0; i<WIDTH; i++) begin
            ary[i] = DAT_T'(i);
        end

        // idle test
        test_name = "idle";
        check_enable = IMPLEMENTATIONS'({1'b1, 1'b1});
        oht <= '0;
        check;

        // one-hot test
        test_name = "one-hot";
        check_enable = IMPLEMENTATIONS'({1'b1, 1'b1});
        for (int unsigned i=0; i<WIDTH; i++) begin
            logic [WIDTH-1:0] tmp_oht;
            tmp_oht = '0;
            tmp_oht[i] = 1'b1;
            oht <= tmp_oht;
            check;
        end

        $finish;
    end

///////////////////////////////////////////////////////////////////////////////
// DUT instance array (for each implementation)
///////////////////////////////////////////////////////////////////////////////

    generate
    for (genvar i=0; i<IMPLEMENTATIONS; i++) begin: imp

        // DUT RTL instance
        mux_oht #(
            .DAT_T (DAT_T),
            .WIDTH (WIDTH),
            .SPLIT (SPLIT),
            .IMPLEMENTATION (i)
        ) dut (
            .oht (oht),
            .ary (ary),
            .vld (vld[i]),
            .dat (dat[i])
        );

    end: imp
    endgenerate

endmodule: mux_oht_tb
