///////////////////////////////////////////////////////////////////////////////
// conversion from a priority to one-hot,
// testbench
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module priority_to_onehot_tb #(
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

    // input priority encoding
    logic [WIDTH-1:0] dec_vld;
    // priority encoder
    logic [WIDTH-1:0] dec_oht [0:IMPLEMENTATIONS-1];  // one-hot encoding
    logic             enc_vld [0:IMPLEMENTATIONS-1];  // cumulative valid
    // reference encoder
    logic [WIDTH-1:0] ref_dec_oht;
    logic             ref_enc_vld;

///////////////////////////////////////////////////////////////////////////////
// reference calculation and checking of DUT outputs against reference
///////////////////////////////////////////////////////////////////////////////

    function automatic [WIDTH-1:0] onehot (
        logic [WIDTH-1:0] valid
    );
        automatic logic carry = 1'b0;
        for (int i=0; i<WIDTH; i++) begin
            if (carry) begin
                onehot[i] = 1'b0;
            end else begin
                onehot[i] = valid[i];
                if (valid[i]) begin
                    carry = 1'b1;
                end
            end
        end
    endfunction: onehot

    // reference
    always_comb
    begin
        ref_dec_oht = onehot(dec_vld);
        ref_enc_vld =      |(dec_vld);    
    end

    // check enable depending on test
    bit [0:IMPLEMENTATIONS-1] check_enable;

    // output checking task
    task check();
        for (int unsigned i=0; i<IMPLEMENTATIONS; i++) begin
            if (check_enable[i]) begin
                assert (dec_oht[i] == ref_dec_oht) else $error("IMPLEMENTATION[%0d]:  dec_oht != %0d'b%b", i, WIDTH, ref_dec_oht);
                assert (enc_vld[i] == ref_enc_vld) else $error("IMPLEMENTATION[%0d]:  enc_vld != 1'b%b"  , i,        ref_enc_vld);
            end
        end
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
        check_enable = IMPLEMENTATIONS'({1'b1, 1'b1});
        dec_vld <= '0;
        #T;
        check;
        #T;

        // one-hot encoder test
        test_name = "one-hot";
        check_enable = IMPLEMENTATIONS'({1'b1, 1'b1});
        for (int unsigned i=0; i<WIDTH; i++) begin
            logic [WIDTH-1:0] tmp_vld;
            tmp_vld = '0;
            tmp_vld[i] = 1'b1;
            dec_vld <= tmp_vld;
            #T;
            check;
            #T;
        end

        // priority encoder test (with undefined inputs)
        test_name = "priority";
        check_enable = IMPLEMENTATIONS'({1'b0, 1'b1});
        for (int unsigned i=0; i<WIDTH; i++) begin
            logic [WIDTH-1:0] tmp_vld;
            tmp_vld = 'X;
            for (int unsigned j=0; j<i; j++) begin
                tmp_vld[j] = 1'b0;
            end
            tmp_vld[i] = 1'b1;
            dec_vld <= tmp_vld;
            #T;
            check;
            #T;
        end
//        $finish;

        // priority encoder test (going through all input combinations)
        test_name = "exhaustive";
        check_enable = IMPLEMENTATIONS'({1'b1, 1'b1});
        for (logic unsigned [WIDTH-1:0] tmp_vld='1; tmp_vld>0; tmp_vld--) begin
            dec_vld <= {<<{tmp_vld}};
            #T;
            check;
            #T;
        end
        $finish;
    end

///////////////////////////////////////////////////////////////////////////////
// DUT instance array (for each implementation)
///////////////////////////////////////////////////////////////////////////////

    generate
    for (genvar i=0; i<IMPLEMENTATIONS; i++) begin: imp

        // DUT RTL instance
        priority_to_onehot_tree #(
            .WIDTH (WIDTH),
            .SPLIT (SPLIT),
            .IMPLEMENTATION (i)
        ) dut (
            .dec_vld (dec_vld),
            .dec_oht (dec_oht[i]),
            .enc_vld (enc_vld[i])
        );

    end: imp
    endgenerate

endmodule: priority_to_onehot_tb
