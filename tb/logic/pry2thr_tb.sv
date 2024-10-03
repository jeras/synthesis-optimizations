///////////////////////////////////////////////////////////////////////////////
// priority to thermometer conversion,
// testbench
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module pry2thr_tb #(
    // size parameters
    parameter  int unsigned WIDTH = 9,
    parameter  int unsigned SPLIT = 3,
    // direction: "LSB" - rightmost, "MSB" - leftmost
    parameter  string       DIRECTION = "LSB"
);

    // implementation (see `pry2thr_base` for details)
    localparam int unsigned IMPLEMENTATIONS = 3;

    // check enable depending on test
    struct packed {
        bit adder ;  // 2
        bit vector;  // 1
        bit loop  ;  // 0
    } check_enable;

    // timing constant
    localparam time T = 10ns;

    // priority input
    logic [WIDTH-1:0] pry;
    // thermometer and valid outputs
    /* verilator lint_off ASCRANGE */
    logic [WIDTH-1:0] thr [0:IMPLEMENTATIONS-1];
    logic             vld [0:IMPLEMENTATIONS-1];
    /* verilator lint_on ASCRANGE */
    // reference signals
    logic [WIDTH-1:0] ref_thr;
    logic             ref_vld;

///////////////////////////////////////////////////////////////////////////////
// reference calculation and checking of DUT outputs against reference
///////////////////////////////////////////////////////////////////////////////

    function automatic [WIDTH-1:0] ref_pry2thr (
        logic [WIDTH-1:0] pry
    );
        automatic logic [WIDTH-1:0] thr;
        unique case (DIRECTION)
            "LSB":
                for (int i=0; i<WIDTH; i++) begin
                    thr[i] = |pry[0+:i+1];
                end
            "MSB":
                for (int i=0; i<WIDTH; i--) begin
                    thr[WIDTH-1-i] = |pry[WIDTH-1:i+1];
                end
        endcase
        return thr;
    endfunction: ref_pry2thr

    // reference
    always_comb
    begin
        ref_thr = ref_pry2thr(pry);
        ref_vld =           |(pry);
    end

    // output checking task
    task automatic check();
        #T;
        for (int unsigned i=0; i<IMPLEMENTATIONS; i++) begin
            if (check_enable[i]) begin
                assert (thr[i] == ref_thr) else $error("IMPLEMENTATION[%0d]:  thr != %0d'b%b", i, WIDTH, ref_thr);
                assert (vld[i] == ref_vld) else $error("IMPLEMENTATION[%0d]:  vld != 1'b%b"  , i,        ref_vld);
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
        // idle test
        test_name = "idle";
        check_enable = '{loop: 1'b1, vector: 1'b0, adder: 1'b1};
        pry <= '0;
        check;

        // thermometer encoder test
        test_name = "thermometer";
        check_enable = '{loop: 1'b1, vector: 1'b0, adder: 1'b1};
        for (int unsigned i=0; i<WIDTH; i++) begin
            logic [WIDTH-1:0] tmp_vld;
            tmp_vld = '0;
            tmp_vld[i] = 1'b1;
            pry <= tmp_vld;
            check;
        end

        // priority encoder test (with undefined inputs)
        test_name = "priority";
        check_enable = '{loop: 1'b1, vector: 1'b0, adder: 1'b0};
        for (int unsigned i=0; i<WIDTH; i++) begin
            logic [WIDTH-1:0] tmp_vld;
            tmp_vld = 'X;
            for (int unsigned j=0; j<i; j++) begin
                tmp_vld[j] = 1'b0;
            end
            tmp_vld[i] = 1'b1;
            pry <= tmp_vld;
            check;
        end
//        $finish;

        // priority encoder test (going through all input combinations)
        test_name = "exhaustive";
        check_enable = '{loop: 1'b1, vector: 1'b0, adder: 1'b1};
        for (logic unsigned [WIDTH-1:0] tmp_vld='1; tmp_vld>0; tmp_vld--) begin
            pry <= {<<{tmp_vld}};
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
        pry2thr #(
            .WIDTH (WIDTH),
            .SPLIT (SPLIT),
            .DIRECTION (DIRECTION),
            .IMPLEMENTATION (i)
        ) dut (
            .pry (pry),
            .thr (thr[i]),
            .vld (vld[i])
        );

    end: imp
    endgenerate

///////////////////////////////////////////////////////////////////////////////
// waveforms
///////////////////////////////////////////////////////////////////////////////

    `ifdef VERILATOR
    initial
    begin
        $dumpfile("pry2thr_tb.fst");
        $dumpvars(0, pry2thr_tb);
    end
`endif

endmodule: pry2thr_tb
