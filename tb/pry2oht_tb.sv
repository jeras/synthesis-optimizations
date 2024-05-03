///////////////////////////////////////////////////////////////////////////////
// priority (rightmost) to one-hot conversion,
// testbench
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module pry2oht_tb #(
    // size parameters
    parameter  int unsigned WIDTH = 32,
    parameter  int unsigned SPLIT = 2,
    // size local parameters
    localparam int unsigned WIDTH_LOG = $clog2(WIDTH),
    localparam int unsigned SPLIT_LOG = $clog2(SPLIT),
    // direction: "LSB" - rightmost, "MSB" - leftmost
    parameter  string       DIRECTION = "LSB"
);

    // implementation (see `pry2oht_base` for details)
    localparam int unsigned IMPLEMENTATIONS = 3;

    // timing constant
    localparam time T = 10ns;

    // priority input
    logic [WIDTH-1:0] pry;
    // one-hot and valid outputs
    /* verilator lint_off ASCRANGE */
    logic [WIDTH-1:0] oht [0:IMPLEMENTATIONS-1];  // one-hot
    logic             vld [0:IMPLEMENTATIONS-1];  // valid
    /* verilator lint_on ASCRANGE */
    // reference signals
    logic [WIDTH-1:0] ref_oht;
    logic             ref_vld;

///////////////////////////////////////////////////////////////////////////////
// reference calculation and checking of DUT outputs against reference
///////////////////////////////////////////////////////////////////////////////

    function automatic [WIDTH-1:0] ref_pry2oht (
        logic [WIDTH-1:0] pry
    );
        automatic logic [WIDTH-1:0] oht;
        automatic logic             vld;
        vld = 1'b0;
        case (DIRECTION)
            "LSB":
                for (int i=0; i<WIDTH; i++) begin
                    oht[i] = pry[i] & ~vld;
                    vld    = pry[i] |  vld;
                end
            "MSB":
                for (int i=WIDTH-1; i<=0; i--) begin
                    oht[i] = pry[i] & ~vld;
                    vld    = pry[i] |  vld;
                end
        endcase
        return oht;
    endfunction: ref_pry2oht

    // reference
    always_comb
    begin
        ref_oht = ref_pry2oht(pry);
        ref_vld =           |(pry);    
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
                assert (oht[i] == ref_oht) else $error("IMPLEMENTATION[%0d]:  oht != %0d'b%b", i, WIDTH, ref_oht);
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
        check_enable = '{default: 1'b1};
        pry <= '0;
        check;

        // one-hot encoder test
        test_name = "one-hot";
        check_enable = '{default: 1'b1};
        for (int unsigned i=0; i<WIDTH; i++) begin
            logic [WIDTH-1:0] tmp_vld;
            tmp_vld = '0;
            tmp_vld[i] = 1'b1;
            pry <= tmp_vld;
            check;
        end

        // priority encoder test (with undefined inputs)
        test_name = "priority";
        check_enable = '{2: 1'b0, default: 1'b1};
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
        check_enable = '{default: 1'b1};
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
        pry2oht_tree #(
            .WIDTH (WIDTH),
            .SPLIT (SPLIT),
            .IMPLEMENTATION (i)
        ) dut (
            .pry (pry),
            .oht (oht[i]),
            .vld (vld[i])
        );

    end: imp
    endgenerate

endmodule: pry2oht_tb
