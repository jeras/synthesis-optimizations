///////////////////////////////////////////////////////////////////////////////
// magnitude comparator,
// testbench
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module mag_cmp_tb #(
    // size parameters
    int unsigned WIDTH = 4,
    int unsigned SPLIT = 2,
    // size local parameters
    localparam int unsigned WIDTH_LOG = $clog2(WIDTH),
    localparam int unsigned SPLIT_LOG = $clog2(SPLIT),
    // number of randomized tests
    int unsigned NUM_RND = 8
);

    // timing constant
    localparam time T = 10ns;

    localparam int unsigned IMPLEMENTATIONS = 1;

    // value and reference inputs
    logic [WIDTH-1:0] val;
    logic [WIDTH-1:0] rfr;
    // greater and less than outputs
    /* verilator lint_off ASCRANGE */
    logic             grt[0:IMPLEMENTATIONS-1];
    logic             lst[0:IMPLEMENTATIONS-1];
    /* verilator lint_on ASCRANGE */
    // reference signals
    logic         ref_grt;
    logic         ref_lst;

///////////////////////////////////////////////////////////////////////////////
// reference calculation and checking of DUT outputs against reference
///////////////////////////////////////////////////////////////////////////////

    // reference encoder
    always_comb
    begin
        ref_grt = val > rfr;
        ref_lst = val < rfr;    
    end

    // check enable depending on test
    bit [0:IMPLEMENTATIONS-1] check_enable;

    // output checking task
    task check();
        #T;
        for (int unsigned i=0; i<IMPLEMENTATIONS; i++) begin
            if (check_enable[i]) begin
                assert (grt[i] == ref_grt) else $error("IMPLEMENTATION[%0d]:  grt != 1'b%b", i, ref_grt);
                assert (lst[i] == ref_lst) else $error("IMPLEMENTATION[%0d]:  lst != 1'b%b", i, ref_lst);
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
        // zero test
        test_name = "zero";
        check_enable = IMPLEMENTATIONS'('1);
        val = 'd0;
        rfr = 'd0;
        check;

        // test equal (randomized)
        test_name = "equal";
        check_enable = IMPLEMENTATIONS'('1);
        for (int unsigned i=0; i<NUM_RND; i++) begin: equal
            int unsigned rnd;
            rnd = $urandom();
            rfr = rnd[WIDTH-1:0];
            val = rnd[WIDTH-1:0];
            check;
        end: equal

        // test not equal (randomized)
        test_name = "not equal";
        check_enable = IMPLEMENTATIONS'('1);
        for (int unsigned i=0; i<NUM_RND; i++) begin: not_equal
            int unsigned rnd;
            rnd = $urandom();
            rfr = rnd[WIDTH-1:0];
            rnd = $urandom();
            val = rnd[WIDTH-1:0];
            check;
        end: not_equal

        $finish;
    end

///////////////////////////////////////////////////////////////////////////////
// DUT instance array (for each implementation)
///////////////////////////////////////////////////////////////////////////////

    generate
    for (genvar i=0; i<IMPLEMENTATIONS; i++) begin: imp

        // DUT RTL instance
        mag_cmp #(
            .WIDTH (WIDTH),
            .SPLIT (SPLIT)
        ) dut (
            .val (val),
            .rfr (rfr),
            .grt (grt[i]),
            .lst (lst[i])
        );

    end: imp
    endgenerate

///////////////////////////////////////////////////////////////////////////////
// waveforms
///////////////////////////////////////////////////////////////////////////////

    `ifdef VERILATOR
    initial
    begin
        $dumpfile("mag_cmp_tb.fst");
        $dumpvars(0, mag_cmp_tb);
    end
`endif

endmodule: mag_cmp_tb
