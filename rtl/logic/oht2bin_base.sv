///////////////////////////////////////////////////////////////////////////////
// one-hot to binary conversion (one-hot encoder)
// base with parametrized implementation options
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module oht2bin_base #(
    // size parameters
    parameter  int unsigned WIDTH = 32,
    // size local parameters
    localparam int unsigned WIDTH_LOG = $clog2(WIDTH),
    // direction: "LSB" - rightmost first, "MSB" - leftmost first
    parameter  string       DIRECTION = "LSB",
    // polarity: "POS" - positive, "NEG" - negative
    parameter  string       POLARITY = "POS",
    // implementation
    parameter  int unsigned IMPLEMENTATION = 0
    // 0 - reduction
    // 1 - linear
)(
    input  logic [WIDTH    -1:0] oht,  // one-hot
    output logic [WIDTH_LOG-1:0] bin,  // binary
    output logic                 vld   // valid
);

    generate
    case (IMPLEMENTATION)
        0:  // reduction
            always_comb
            begin
                for (int unsigned i=0; i<WIDTH_LOG; i++) begin
                    logic [WIDTH-1:0] msk;
                    for (int unsigned j=0; j<WIDTH; j++) begin
                        msk[j] = j[i];
                    end
                    // use a mask pattern on one-hot input for each bit of the binary output
                    bin[i] = |(oht & msk);
                end
                vld = |oht;
            end
        1:  // linear
            case (DIRECTION)
            "LSB":
                always_comb
                begin
                    bin = WIDTH_LOG'('0);
                    vld = 1'b0;
                    for (int unsigned i=0; i<WIDTH; i++) begin
                        bin |= oht[i] ? i[WIDTH_LOG-1:0] : WIDTH_LOG'('0);
                        vld |= oht[i] ? 1'b1             : 1'b0          ;
                    end
                end
            "MSB":
                always_comb
                begin
                    bin = WIDTH_LOG'('0);
                    vld = 1'b0;
                    for (int i=WIDTH-1; i>0; i--) begin
                        bin |= oht[i] ? i[WIDTH_LOG-1:0] : WIDTH_LOG'('0);
                        vld |= oht[i] ? 1'b1             : 1'b0          ;
                    end
                end
            default:
                $fatal("Unsupported DIRECTION parameter value.");
            endcase
        default:  // parameter validation
            $fatal("Unsupported IMPLEMENTATION parameter value.");
    endcase
    endgenerate

endmodule: oht2bin_base
