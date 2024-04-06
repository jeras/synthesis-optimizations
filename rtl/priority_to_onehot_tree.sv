///////////////////////////////////////////////////////////////////////////////
// Conversion from a priority to one-hot encoding, implemented as a tree using recursion
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module priority_to_onehot_tree #(
    // size parameters
    parameter  int unsigned WIDTH = 32,
    parameter  int unsigned SPLIT = 2,
    // size local parameters
    localparam int unsigned WIDTH_LOG = $clog2(WIDTH),
    localparam int unsigned SPLIT_LOG = $clog2(SPLIT),
    // implementation (see `priority_to_onehot_base` for details)
    parameter  int unsigned IMPLEMENTATION = 0
)(
    input  logic [WIDTH-1:0] enc_pry,  // priority encoding
    output logic [WIDTH-1:0] enc_oht,  // one-hot encoding
    output logic             dec_vld   // cumulative valid
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

        logic [POWER-1:0] tmp_pry;
        logic [POWER-1:0] tmp_oht;
        
        // zero extend the input vector
        assign tmp_pry = POWER'(enc_pry);

        // the synthesis tool is expected to optimize out the logic for constant inputs
        priority_to_onehot_tree #(
            .WIDTH (POWER),
            .SPLIT (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) enc (
            .enc_pry (tmp_pry),
            .enc_oht (tmp_oht),
            .dec_vld (dec_vld)
        );

        // remove zero extension from output vector
        assign enc_oht = WIDTH'(tmp_oht);

    end: extend
    // leafs at the end of tree branches
    else if (WIDTH == SPLIT) begin: leaf

        priority_to_onehot_base #(
            .WIDTH (WIDTH),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) encoder (
            .enc_pry (dec_vld),
            .enc_oht (enc_idx),
            .dec_vld (enc_vld)
        );

    end: leaf
    // combining SPLIT sub-branches into a single branch closer to the tree trunk
    else begin: branch

        logic [SPLIT-1:0] [WIDTH/SPLIT-1:0] sub_oht;
        logic [SPLIT-1:0]                   sub_vld;
        logic [SPLIT-1:0]                   brn_oht;

        // sub-branches
        priority_to_onehot_tree #(
            .WIDTH (WIDTH/SPLIT),
            .SPLIT (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) enc_sub [SPLIT-1:0] (
            .enc_pry (enc_pry),
            .enc_oht (sub_oht),
            .dec_vld (sub_vld)
        );

        // branch
        priority_to_onehot_base #(
            .WIDTH (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) enc_brn (
            .enc_pry (sub_vld),
            .enc_oht (brn_oht),
            .dec_vld (dec_vld)
        );

        // multiplex sub-branches into branch
        for (genvar i=0; i<SPLIT; i++) begin: mask
            assign enc_oht[i*SPLIT+:SPLIT] = brn_oht[i] ? sub_oht[i] : '0;
        end: mask

    end: branch
    endgenerate

endmodule: priority_to_onehot_tree
