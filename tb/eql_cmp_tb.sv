///////////////////////////////////////////////////////////////////////////////
// equality comparator,
// testbench
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module eql_cmp_tb #(
    // size parameters
    int unsigned WIDTH = 4,
    // number of randomized tests
    int unsigned NUM_RND = 8
);

    // size local parameters
    localparam int unsigned WIDTH_LOG = $clog2(WIDTH);

    // timing constant
    localparam time T = 10ns;

    localparam int unsigned IMPLEMENTATIONS = 5;

    // value and reference inputs
    logic [WIDTH-1:0] val;
    logic [WIDTH-1:0] rfr;
    // equal outputs
    /* verilator lint_off ASCRANGE */
    logic             eql[0:IMPLEMENTATIONS-1];
    /* verilator lint_on ASCRANGE */
    // reference signals
    logic         ref_eql;

//    class rnd_class;
//        rand bit [WIDTH-1:0] val, rfr;
//    endclass: rnd_class
//
//    rnd_class rnd_obj;

///////////////////////////////////////////////////////////////////////////////
// reference calculation and checking of DUT outputs against reference
///////////////////////////////////////////////////////////////////////////////

    // reference encoder
    always_comb
    begin
        ref_eql = val == rfr;
    end

    // check enable depending on test
    /* verilator lint_off ASCRANGE */
    bit [0:IMPLEMENTATIONS-1] check_enable;
    /* verilator lint_on ASCRANGE */

    // output checking task
    task check();
        #T;
        for (int unsigned i=0; i<IMPLEMENTATIONS; i++) begin
            if (check_enable[i]) begin
                assert (eql[i] == ref_eql) else $error("IMPLEMENTATION[%0d]:  eql != 1'b%b", i, ref_eql);
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

//        // test randomize
//        test_name = "randomize";
//        check_enable = IMPLEMENTATIONS'('1);
//        rnd_obj = new();
//        for (int unsigned i=0; i<NUM_RND; i++) begin
//            rnd_obj.randomize();
//            val = rnd_obj.val;
//            rfr = rnd_obj.rfr;
//            check;
//        end

        $finish;
    end

///////////////////////////////////////////////////////////////////////////////
// DUT instance array (for each implementation)
///////////////////////////////////////////////////////////////////////////////

    generate
    for (genvar i=0; i<IMPLEMENTATIONS; i++) begin: imp

        // DUT RTL instance
        eql_cmp #(
            .WIDTH (WIDTH)
        ) dut (
            .val (val),
            .rfr (rfr),
            .eql (eql[i])
        );

    end: imp
    endgenerate

endmodule: eql_cmp_tb
