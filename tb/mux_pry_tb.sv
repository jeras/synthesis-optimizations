///////////////////////////////////////////////////////////////////////////////
// multiplexer with priority select,
// testbench
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module mux_pry_tb #(
    // data type
    parameter  type DAT_T = logic [8-1:0],
    // size parameters
    int unsigned WIDTH = 9,
    int unsigned SPLIT = 3
);

    // timing constant
    localparam time T = 10ns;

    localparam int unsigned IMPLEMENTATIONS = 2;

    // priority select and data array inputs
    logic [WIDTH-1:0] pry;
    DAT_T             ary [WIDTH-1:0];
    // data and valid outputs
    /* verilator lint_off ASCRANGE */
    logic             vld [0:IMPLEMENTATIONS-1];
    DAT_T             dat [0:IMPLEMENTATIONS-1];
    /* verilator lint_on ASCRANGE */
    // reference signals
    logic         ref_vld;
    DAT_T         ref_dat;

///////////////////////////////////////////////////////////////////////////////
// reference calculation and checking of DUT outputs against reference
///////////////////////////////////////////////////////////////////////////////

    function automatic DAT_T ref_mux_pry (
        logic [WIDTH-1:0] pry,
        DAT_T             ary [WIDTH-1:0]
    );
        for (int i=0; i<WIDTH; i++) begin
            if (pry[i])  ref_mux_pry = ary[i];
        end
    endfunction: ref_mux_pry

    // reference
    always_comb
    begin
        ref_vld =           |(pry     );
        ref_dat = ref_mux_pry(pry, ary);
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
        pry <= '0;
        check;

        // priority test
        test_name = "priority";
        check_enable = IMPLEMENTATIONS'({1'b1, 1'b1});
        for (int unsigned i=0; i<WIDTH; i++) begin
            logic [WIDTH-1:0] tmp_pry;
            tmp_pry = '0;
            tmp_pry[i] = 1'b1;
            pry <= tmp_pry;
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
        mux_pry #(
            .DAT_T (DAT_T),
            .WIDTH (WIDTH),
            .SPLIT (SPLIT),
            .IMPLEMENTATION (i)
        ) dut (
            .pry (pry),
            .ary (ary),
            .vld (vld[i]),
            .dat (dat[i])
        );

    end: imp
    endgenerate

endmodule: mux_pry_tb
