///////////////////////////////////////////////////////////////////////////////
// one-hot decoder
// implemented as a tree using recursion
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module onehot_decoder_tree #(
    // size parameters
    parameter  int unsigned WIDTH = 32,
    parameter  int unsigned SPLIT = 2,
    // size local parameters
    localparam int unsigned WIDTH_LOG = $clog2(WIDTH),
    localparam int unsigned SPLIT_LOG = $clog2(SPLIT),
    // implementation (see `onehot_decoder_base` for details)
    parameter  int unsigned IMPLEMENTATION = 0
)(
    input  logic [WIDTH_LOG-1:0] enc_idx,
    output logic [WIDTH    -1:0] dec_vld
);

    // SPLIT to the power of logarithm of WIDTH base SPLIT
    localparam int unsigned POWER_LOG = WIDTH_LOG/SPLIT_LOG;
    localparam int unsigned POWER     = SPLIT**POWER_LOG;

    generate
    // if SPLIT is not a power of 2
    if (SPLIT != (2**SPLIT_LOG)) begin: validation

        $error("Parameter SPLIT is not a power of 2.");

    end: validation
    // if WIDTH is not a power of SPLIT
    else if (WIDTH != POWER) begin: extend

        logic [POWER-1:0] tmp_vld;
        
        // zero extend the input vector
        assign tmp_vld = POWER'(dec_vld);

        // the synthesis tool is expected to optimize out the logic for constant inputs
        onehot_decoder_tree #(
            .WIDTH (POWER),
            .SPLIT (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) enc (
            .enc_idx (enc_idx),
            .dec_vld (tmp_vld)
        );

    end: extend
    // leafs at the end of tree branches
    else if (WIDTH == SPLIT) begin: leaf

        onehot_decoder_base #(
            .WIDTH (WIDTH),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) decoder (
            .dec_vld (dec_vld),
            .enc_idx (enc_idx),
            .enc_vld (enc_vld)
        );

    end: leaf
    // combining SPLIT sub-branches into a single branch closer to the tree trunk
    else begin: branch

        logic [SPLIT-1:0] [WIDTH_LOG-SPLIT_LOG-1:0] sub_idx;
        logic [SPLIT-1:0]                           sub_vld;
        logic                       [SPLIT_LOG-1:0] brn_idx;

        // sub-branches
        onehot_decoder_tree #(
            .WIDTH (WIDTH/SPLIT),
            .SPLIT (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) enc_sub [SPLIT-1:0] (
            .dec_vld (dec_vld),
            .enc_idx (sub_idx),
            .enc_vld (sub_vld)
        );

        // branch
        onehot_decoder_base #(
            .WIDTH (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) enc_brn (
            .dec_vld (sub_vld),
            .enc_idx (brn_idx),
            .enc_vld (enc_vld)
        );

        // multiplex sub-branches into branch
        assign enc_idx = {brn_idx, sub_idx[brn_idx]};

    end: branch
    endgenerate

endmodule: onehot_decoder_tree
