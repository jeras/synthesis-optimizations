///////////////////////////////////////////////////////////////////////////////
// counter (wrap on maximum),
// testbench
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module counter_last_tb #(
    // size parameters
    int unsigned WIDTH = 4
);

    // timing constant
    localparam time T = 10ns;

    localparam int unsigned IMPLEMENTATIONS = 2;

    // system signals
    logic             clk;  // clock
    logic             rst;  // reset
    // control input
    logic             ena;
    logic [WIDTH-1:0] max;
    // counter outputs
    /* verilator lint_off ASCRANGE */
    logic [WIDTH-1:0] cnt[0:IMPLEMENTATIONS-1];
    logic             pls[0:IMPLEMENTATIONS-1];
    /* verilator lint_on ASCRANGE */
    // reference signals
    integer       ref_cnt;
    logic         ref_pls;

    // control counter
    integer       ctl_cnt;

    // testcases
    localparam logic [WIDTH-1:0] max_lst [3] = '{0, 1, 2**WIDTH-1};

///////////////////////////////////////////////////////////////////////////////
// reference calculation and checking of DUT outputs against reference
///////////////////////////////////////////////////////////////////////////////

    // reference counter
    always_ff @(posedge clk, posedge rst)
    begin
        if (rst) begin
            ref_cnt <= '0;
        end else begin
            if (ena) begin
                if (ref_pls) begin
                    ref_cnt <= '0;
                end else begin
                    ref_cnt <= ref_cnt + 1;
                end
            end
        end
    end

    // reference pulse
    assign ref_pls = ref_cnt[WIDTH-1:0] == max;

    // check enable depending on test
    /* verilator lint_off ASCRANGE */
    bit [0:IMPLEMENTATIONS-1] check_enable = '1;
    /* verilator lint_on ASCRANGE */

    // output checking task
    task check();
        for (int unsigned i=0; i<IMPLEMENTATIONS; i++) begin
            if (check_enable[i]) begin
                assert (cnt[i] == ref_cnt[WIDTH-1:0]) else $error("IMPLEMENTATION[%0d]:  cnt != %d'b%x", i, WIDTH, ref_cnt[WIDTH-1:0]);
                assert (pls[i] == ref_pls           ) else $error("IMPLEMENTATION[%0d]:  pls != 1'b%x" , i,        ref_pls           );
            end
        end
    endtask: check

///////////////////////////////////////////////////////////////////////////////
// test
///////////////////////////////////////////////////////////////////////////////

    // clock source
    initial clk = 1'b1;
    always #T clk = ~clk;

    // test name
    string test_name;

    // test sequence
    initial
    begin
        // loop over max value choices
        foreach(max_lst[i])
        begin: testcase
            // reset sequence (asynchronous set, synchronous release)
            rst = 1'b1;
            repeat(4) @(posedge clk);
            rst <= 1'b0;
    
            // set the conter wrap limit
            @(posedge clk);
            max <= max_lst[i];
            // randomized enable
            test_name = "randomized_enable";
            ctl_cnt = 0;
            do
            begin: random
                int unsigned rnd;
                rnd = $urandom();
                @(posedge clk);
                ena <= rnd[0];
                check;
                if (rnd[0]) ctl_cnt++;
            end: random
            while (ctl_cnt < (2**WIDTH)+2);
        end: testcase

        repeat(4) @(posedge clk);
        $finish;
    end

///////////////////////////////////////////////////////////////////////////////
// DUT instance array (for each implementation)
///////////////////////////////////////////////////////////////////////////////

    generate
    for (genvar i=0; i<IMPLEMENTATIONS; i++) begin: imp

        // DUT RTL instance
        counter_last #(
            .WIDTH (WIDTH)
        ) dut (
            // system signals
            .clk (clk),
            .rst (rst),
            // counter
            .ena (ena),
            .max (max),
            .cnt (cnt[i]),
            .pls (pls[i])
        );

    end: imp
    endgenerate

///////////////////////////////////////////////////////////////////////////////
// waveforms
///////////////////////////////////////////////////////////////////////////////

`ifdef VERILATOR
    initial
    begin
        $dumpfile("counter_last_tb.fst");
        $dumpvars(0, counter_last_tb);
    end
`endif

endmodule: counter_last_tb
