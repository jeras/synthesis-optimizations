module magnitude_comparator_tb #(
    // size parameters
    int unsigned WIDTH = 4,
    int unsigned SPLIT = 2
);

    // size local parameters
    localparam int unsigned WIDTH_LOG = $clog2(WIDTH);
    localparam int unsigned SPLIT_LOG = $clog2(SPLIT);

    // timing constant
    localparam time T = 10ns;

    localparam int unsigned IMPLEMENTATIONS = 1;

    // inputs
    logic [WIDTH-1:0] i_a;
    logic [WIDTH-1:0] i_b;
    // outputs
    logic             o_a[0:IMPLEMENTATIONS-1];
    logic             o_b[0:IMPLEMENTATIONS-1];
    // reference comparator
    logic         ref_o_a;
    logic         ref_o_b;

    logic         wrong;
    string        test;

    function [2-1:0][WIDTH_LOG-1:0] grt (
        logic [WIDTH-1:0] a,
        logic [WIDTH-1:0] b
    );
        return a > b;
    endfunction: grt

    // reference encoder
    always_comb
    begin
        ref_o_a = grt(i_a, i_b);
        ref_o_b = grt(i_b, i_a);    
    end

    // output checking task
    task check();
        for (int unsigned i=0; i<IMPLEMENTATIONS; i++) begin
            assert (o_a[i] == ref_o_a) else $error("IMPLEMENTATION[%d]:  o_a != 1'b%b", i, ref_o_a);
            assert (o_b[i] == ref_o_b) else $error("IMPLEMENTATION[%d]:  o_b != 1'b%b", i, ref_o_b);
        end
    endtask: check

    // test sequence
    initial
    begin
        // zero test
        test = "zero";
        i_a = 'd0;
        i_b = 'd0;
        #T;
        check;
        #T;

        // zero test
        test = "zero";
        i_a = 'd1;
        i_b = 'd0;
        #T;
        check;
        #T;

        // zero test
        test = "zero";
        i_a = 'd0;
        i_b = 'd1;
        #T;
        check;
        #T;

//        for (int unsigned pri=0; pri<WIDTH; pri++) begin: for_pri
//            enc_pri = WIDTH_LOG'(pri);
//
//            // one-hot encoder test
//            test = "one-hot";
//            for (int unsigned i=0; i<WIDTH; i++) begin: for_oht
//                logic [WIDTH-1:0] tmp_vld;
//                tmp_vld = '0;
//                tmp_vld[i] = 1'b1;
//                dec_vld = tmp_vld;
//                #T;
//                check;
//                #T;
//            end: for_oht
//
//        end: for_pri

        $finish;
    end

    generate
    for (genvar i=0; i<IMPLEMENTATIONS; i++) begin: imp

        // DUT RTL instance
        magnitude_comparator_tree #(
            .WIDTH (WIDTH),
            .SPLIT (SPLIT)
        ) dut (
            .i_a (i_a),
            .i_b (i_b),
            .o_a (o_a[i]),
            .o_b (o_b[i])
        );

    end: imp
    endgenerate

endmodule: magnitude_comparator_tb
