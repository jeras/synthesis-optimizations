///////////////////////////////////////////////////////////////////////////////
// multiplexer with binary select (priority multipleser),
// testbench
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module mux_bin_tb #(
    // data type
    parameter  type DAT_T = logic [8-1:0],
    // size parameters
    int unsigned WIDTH = 16,
    int unsigned SPLIT = 4,
    // size local parameters
    localparam int unsigned WIDTH_LOG = $clog2(WIDTH),
    localparam int unsigned SPLIT_LOG = $clog2(SPLIT)
);

    // implementation (see `mux_bin_base` for details)
    localparam int unsigned IMPLEMENTATIONS = 1;

    // check enable depending on test
    bit [0:IMPLEMENTATIONS-1] check_enable;

    // timing constant
    localparam time T = 10ns;

    // binary select and data array inputs
    logic [WIDTH_LOG-1:0] bin;
    DAT_T                 ary [WIDTH-1:0];
    // data and valid outputs
    /* verilator lint_off ASCRANGE */
    DAT_T                 dat [0:IMPLEMENTATIONS-1];
    /* verilator lint_on ASCRANGE */
    // reference signals
    DAT_T             ref_dat;

///////////////////////////////////////////////////////////////////////////////
// reference calculation and checking of DUT outputs against reference
///////////////////////////////////////////////////////////////////////////////

    function automatic DAT_T ref_mux_bin (
        logic [WIDTH_LOG-1:0] bin,
        DAT_T                 ary [WIDTH-1:0]
    );
        ref_mux_bin = ary[bin];
    endfunction: ref_mux_bin

    // reference
    always_comb
    begin
        ref_dat = ref_mux_bin(bin, ary);
    end

    // output checking task
    task check();
        #T;
        for (int unsigned i=0; i<IMPLEMENTATIONS; i++) begin
            if (check_enable[i]) begin
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
    /* verilator lint_off INITIALDLY */
    initial
    begin
        // initialize input array
        for (int unsigned i=0; i<WIDTH; i++) begin
            ary[i] = DAT_T'(i);
        end

        // test
        test_name = "binary";
        check_enable = IMPLEMENTATIONS'('1);
        for (int unsigned i=0; i<WIDTH; i++) begin
            bin <= i[WIDTH_LOG-1:0];
            check;
        end

        $finish;
    end
    /* verilator lint_on INITIALDLY */

///////////////////////////////////////////////////////////////////////////////
// DUT instance array (for each implementation)
///////////////////////////////////////////////////////////////////////////////

    generate
    for (genvar i=0; i<IMPLEMENTATIONS; i++) begin: imp

        // DUT RTL instance
        mux_bin #(
            .DAT_T (DAT_T),
            .WIDTH (WIDTH),
            .SPLIT (SPLIT),
            .IMPLEMENTATION (i)
        ) dut (
            .bin (bin),
            .ary (ary),
            .dat (dat[i])
        );

    end: imp
    endgenerate

///////////////////////////////////////////////////////////////////////////////
// waveforms
///////////////////////////////////////////////////////////////////////////////

    `ifdef VERILATOR
    initial
    begin
        $dumpfile("mux_bin_tb.fst");
        $dumpvars(0, mux_bin_tb);
    end
`endif

endmodule: mux_bin_tb
