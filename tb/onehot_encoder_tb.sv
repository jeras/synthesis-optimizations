module onehot_encoder_tb #(
    // size parameters
    int unsigned WIDTH = 16,
    int unsigned SPLIT = 4
);

    // size local parameters
    localparam int unsigned WIDTH_LOG = $clog2(WIDTH);
    localparam int unsigned SPLIT_LOG = $clog2(SPLIT);

    // timing constant
    localparam time T = 10ns;

    localparam int unsigned IMPLEMENTATIONS = 5;

    // input
    logic [WIDTH    -1:0] dec_vld;
    // one-hot encoder
    logic [WIDTH_LOG-1:0] enc_idx [0:IMPLEMENTATIONS-1];
    logic                 enc_vld [0:IMPLEMENTATIONS-1];
    // reference encoder
    logic [WIDTH_LOG-1:0] ref_enc_idx;
    logic                 ref_enc_vld;

    function  [WIDTH_LOG-1:0] encoder (
        logic [WIDTH    -1:0] dec_vld
    );
        for (int unsigned i=0; i<WIDTH; i++) begin
            if (dec_vld[i] == 1'b1)  return WIDTH_LOG'(i);
        end
        return 'x;
    endfunction: encoder

    // reference encoder
    always_comb
    begin
        ref_enc_idx = encoder(dec_vld);
        ref_enc_vld =       |(dec_vld);    
    end

    // output checking task
    task check();
        for (int unsigned i=0; i<IMPLEMENTATIONS; i++) begin
            assert (enc_vld[i] == ref_enc_vld) else $error("IMPLEMENTATION[%d]:  enc_vld != 1'b%b" , i,            ref_enc_vld);
            if (enc_vld[i]) begin  // do not check the encoded output, if it is not supposed to be valid
            assert (enc_idx[i] == ref_enc_idx) else $error("IMPLEMENTATION[%d]:  enc_idx != %d'd%d", i, WIDTH_LOG, ref_enc_idx);
            end
        end
    endtask: check

    // test sequence
    initial
    begin
        // idle test
        dec_vld <= '0;
        #T;
        check;
        #T;

        // one-hot encoder test
        for (int unsigned i=0; i<WIDTH; i++) begin
            logic [WIDTH-1:0] tmp_vld;
            tmp_vld = '0;
            tmp_vld[i] = 1'b1;
            dec_vld <= tmp_vld;
            #T;
            check;
            #T;
        end
        $finish;
    end

    generate
    for (genvar i=0; i<IMPLEMENTATIONS; i++) begin: imp

        onehot_encoder_tree #(
            .WIDTH (WIDTH),
            .SPLIT (SPLIT),
            .IMPLEMENTATION (i)
        ) dut (
            .dec_vld (dec_vld),
            .enc_idx (enc_idx[i]),
            .enc_vld (enc_vld[i])
        );

    end: imp
    endgenerate

endmodule: onehot_encoder_tb