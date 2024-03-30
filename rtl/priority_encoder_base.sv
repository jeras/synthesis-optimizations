///////////////////////////////////////////////////////////////////////////////
// Priority encoder base with parametrized implementation options
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module priority_encoder_base #(
    // size parameters
    parameter  int unsigned WIDTH = 32,
    // size local parameters
    localparam int unsigned WIDTH_LOG = $clog2(WIDTH),
    // implementation
    parameter  int unsigned IMPLEMENTATION = 0
    // 0 - casez
    // 1 - unique   if
    // 2 - priority if
    // 3 - unique   case inside
    // 4 - priority case inside
)(
    input  logic [WIDTH    -1:0] dec_vld,
    output logic [WIDTH_LOG-1:0] enc_idx,
    output logic                 enc_vld
);

        always_comb
        begin
            case (WIDTH)
                2:
                unique case (dec_vld) inside
                    2'b?1  : enc_idx = 1'd0;
                    2'b10  : enc_idx = 1'd1;
                    default: enc_idx = 1'd0;
                endcase

                4: case (IMPLEMENTATION)
                    0:  // casez
                    casez (dec_vld)
                        4'b???1: enc_idx = 2'd0;
                        4'b??10: enc_idx = 2'd1;
                        4'b?100: enc_idx = 2'd2;
                        4'b1000: enc_idx = 2'd3;
                        default: enc_idx = 2'dx;
                    endcase
                    1:  // unique   if
                    unique   if (dec_vld ==? 4'b???1) enc_idx = 2'd0;
                    else     if (dec_vld ==? 4'b??10) enc_idx = 2'd1;
                    else     if (dec_vld ==? 4'b?100) enc_idx = 2'd2;
                    else     if (dec_vld ==? 4'b1000) enc_idx = 2'd3;
                    else                              enc_idx = 2'dx;
                    2:  // priority if
                    priority if (dec_vld ==? 4'b???1) enc_idx = 2'd0;
                    else     if (dec_vld ==? 4'b??1?) enc_idx = 2'd1;
                    else     if (dec_vld ==? 4'b?1??) enc_idx = 2'd2;
                    else     if (dec_vld ==? 4'b1???) enc_idx = 2'd3;
                    else                              enc_idx = 2'dx;
                    3:  // unique   case inside
                    unique case (dec_vld) inside
                        4'b???1: enc_idx = 2'd0;
                        4'b??10: enc_idx = 2'd1;
                        4'b?100: enc_idx = 2'd2;
                        4'b1000: enc_idx = 2'd3;
                        default: enc_idx = 2'dx;
                    endcase
                    4:  // priority case inside
                    priority case (dec_vld) inside
                        4'b???1: enc_idx = 2'd0;
                        4'b??1?: enc_idx = 2'd1;
                        4'b?1??: enc_idx = 2'd2;
                        4'b1???: enc_idx = 2'd3;
                        default: enc_idx = 2'dx;
                    endcase
                endcase
            endcase
        end
    assign enc_vld = |dec_vld;

endmodule: priority_encoder_base
