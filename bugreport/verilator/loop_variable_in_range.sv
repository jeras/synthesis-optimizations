///////////////////////////////////////////////////////////////////////////////
// priority to thermometer conversion, testbench
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module loop_variable_in_range #(
    parameter  int unsigned WIDTH = 8
);

    localparam time T = 10ns;

    // priority
    logic [WIDTH-1:0] pry;
    // thermometer
    logic [WIDTH-1:0] thr_a;
    logic [WIDTH-1:0] thr_b;
    logic [WIDTH-1:0] thr_c;

///////////////////////////////////////////////////////////////////////////////
// reference calculation and checking of DUT outputs against reference
///////////////////////////////////////////////////////////////////////////////

    always_comb
    begin
        // method A (reference)
        thr_a[0] = pry[0];
        /* verilator lint_off ALWCOMBORDER */
        for (int i=1; i<WIDTH; i++) begin
            thr_a[i] = pry[i] | thr_a[i-1];
        end
        /* verilator lint_on ALWCOMBORDER */
        // method B
        for (int i=0; i<WIDTH; i++) begin
//            thr_b[i] = |pry[0+:i+1];
        end
        // method C
        for (int i=0; i<WIDTH; i++) begin
//            thr_c[i] = |pry[i:0];
        end
    end

    // output checking task
    task automatic check();
        #T;
        assert (thr_b == thr_a) else $error("thr != %0d'b%b", WIDTH, thr_a);
        assert (thr_c == thr_a) else $error("thr != %0d'b%b", WIDTH, thr_a);
        #T;
    endtask: check

///////////////////////////////////////////////////////////////////////////////
// test
///////////////////////////////////////////////////////////////////////////////

    // test sequence
    initial
    begin
        // idle test
        pry = '0;
        check;

        // thermometer encoder test
        for (int unsigned i=0; i<WIDTH; i++) begin
            logic [WIDTH-1:0] tmp_vld;
            tmp_vld = '0;
            tmp_vld[i] = 1'b1;
            pry = tmp_vld;
            check;
        end

        // priority encoder test (with undefined inputs)
        for (int unsigned i=0; i<WIDTH; i++) begin
            logic [WIDTH-1:0] tmp_vld;
            tmp_vld = 'X;
            for (int unsigned j=0; j<i; j++) begin
                tmp_vld[j] = 1'b0;
            end
            tmp_vld[i] = 1'b1;
            pry = tmp_vld;
            check;
        end
        $finish;
    end

///////////////////////////////////////////////////////////////////////////////
// waveforms
///////////////////////////////////////////////////////////////////////////////

    initial
    begin
        $dumpfile("loop_variable_in_range.fst");
        $dumpvars(0, loop_variable_in_range);
    end

endmodule: loop_variable_in_range
