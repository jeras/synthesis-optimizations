module priority_encoder_wrap #(
    int unsigned WIDTH = 32,
    int unsigned SPLIT = 2,
    bit mode = 1'b1
)(
    // system signals
    input  logic             clk,    // clock
    input  logic             rst,    // reset
    // wrapped signals
    input  logic [       WIDTH -1:0] dec_vld,
    output logic [$clog2(WIDTH)-1:0] enc_idx,
    output logic                     enc_vld
);

    logic [       WIDTH -1:0] tmp_dec_vld;
    logic [$clog2(WIDTH)-1:0] tmp_enc_idx;
    logic                     tmp_enc_vld;

    // use synchronous reset
    always @(posedge clk)
    if (rst)  tmp_dec_vld <= '0;
    else      tmp_dec_vld <= dec_vld;

    priority_encoder #(
        .WIDTH (WIDTH),
        .SPLIT (SPLIT)
    ) priority_encoder (
        .dec_vld (tmp_dec_vld),
        .enc_idx (tmp_enc_idx),
        .enc_vld (tmp_enc_vld)
    );
    
    // use synchronous reset
    always @(posedge clk)
    if (rst) begin
        enc_idx <= '0;
        enc_vld <= '0;
    end else begin
        enc_idx <= tmp_enc_idx;
        enc_vld <= tmp_enc_vld;
    end

endmodule: priority_encoder_wrap
