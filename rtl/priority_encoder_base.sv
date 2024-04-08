///////////////////////////////////////////////////////////////////////////////
// Priority encoder, base with parametrized implementation options
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
    // 0 - loop
    // apart from loop, all options are just different SystemVerilog syntax implementing the same logic
    // 1 - casez (this is compatible with old Verilog)
    // 2 - unique   if
    // 3 - priority if
    // 4 - unique   case inside
    // 5 - priority case inside
)(
    input  logic [WIDTH    -1:0] dec_vld,
    output logic [WIDTH_LOG-1:0] enc_idx,
    output logic                 enc_vld
);

    generate
    case (IMPLEMENTATION)
        0:  // loop
            always_comb
            begin
                for (int unsigned i=0; i<WIDTH; i++) begin
                    if (dec_vld[i]) begin
                        enc_idx = i[WIDTH_LOG-1:0];
                        break;  // the break makes sure the first active input is indexed
                    end
                end
                assign enc_vld = |dec_vld;
            end
        default:  // non loop
        begin
            case (WIDTH)
                2:  // 2-bit input vector
                case (IMPLEMENTATION)
                    1:  // casez (this is compatible with old Verilog)
                    always_comb
                    casez (dec_vld)
                        2'b?1  : enc_idx = 1'd0;
                        2'b10  : enc_idx = 1'd1;
                        default: enc_idx = 1'd0;
                    endcase
                    2:  // unique   if
                    always_comb
                    unique   if (dec_vld ==? 2'b?1) enc_idx = 1'd0;
                    else     if (dec_vld ==? 2'b10) enc_idx = 1'd1;
                    else                            enc_idx = 1'dx;
                    3:  // priority if
                    always_comb
                    priority if (dec_vld ==? 2'b?1) enc_idx = 1'd0;
                    else     if (dec_vld ==? 2'b1?) enc_idx = 1'd1;
                    else                            enc_idx = 1'dx;
                    4:  // unique   case inside
                    always_comb
                    unique case (dec_vld) inside
                        2'b?1  : enc_idx = 1'd0;
                        2'b10  : enc_idx = 1'd1;
                        default: enc_idx = 1'dx;
                    endcase
                    5:  // priority case inside
                    always_comb
                    priority case (dec_vld) inside
                        2'b?1  : enc_idx = 1'd0;
                        2'b1?  : enc_idx = 1'd1;
                        default: enc_idx = 1'dx;
                    endcase
                endcase
                4:  // 4-bit input vector
                case (IMPLEMENTATION)
                    1:  // casez (this is compatible with old Verilog)
                    always_comb
                    casez (dec_vld)
                        4'b???1: enc_idx = 2'd0;
                        4'b??10: enc_idx = 2'd1;
                        4'b?100: enc_idx = 2'd2;
                        4'b1000: enc_idx = 2'd3;
                        default: enc_idx = 2'dx;
                    endcase
                    2:  // unique   if
                    always_comb
                    unique   if (dec_vld ==? 4'b???1) enc_idx = 2'd0;
                    else     if (dec_vld ==? 4'b??10) enc_idx = 2'd1;
                    else     if (dec_vld ==? 4'b?100) enc_idx = 2'd2;
                    else     if (dec_vld ==? 4'b1000) enc_idx = 2'd3;
                    else                              enc_idx = 2'dx;
                    3:  // priority if
                    always_comb
                    priority if (dec_vld ==? 4'b???1) enc_idx = 2'd0;
                    else     if (dec_vld ==? 4'b??1?) enc_idx = 2'd1;
                    else     if (dec_vld ==? 4'b?1??) enc_idx = 2'd2;
                    else     if (dec_vld ==? 4'b1???) enc_idx = 2'd3;
                    else                              enc_idx = 2'dx;
                    4:  // unique   case inside
                    always_comb
                    unique case (dec_vld) inside
                        4'b???1: enc_idx = 2'd0;
                        4'b??10: enc_idx = 2'd1;
                        4'b?100: enc_idx = 2'd2;
                        4'b1000: enc_idx = 2'd3;
                        default: enc_idx = 2'dx;
                    endcase
                    5:  // priority case inside
                    always_comb
                    priority case (dec_vld) inside
                        4'b???1: enc_idx = 2'd0;
                        4'b??1?: enc_idx = 2'd1;
                        4'b?1??: enc_idx = 2'd2;
                        4'b1???: enc_idx = 2'd3;
                        default: enc_idx = 2'dx;
                    endcase
                endcase
            endcase
            assign enc_vld = |dec_vld;
        end
    endcase
    endgenerate

endmodule: priority_encoder_base
