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
    // implementation
    parameter  int unsigned IMPLEMENTATION = 0
    // 0 - reduction
    // 1 - linear
)(
    input  logic [WIDTH    -1:0] oht,  // one-hot
    output logic [WIDTH_LOG-1:0] bin,  // binary
    output logic                 vld   // valid
);

    // table unpacked array type
    typedef bit [WIDTH-1:0] tbl_t [WIDTH_LOG-1:0];

    // table function definition
    function automatic tbl_t tbl_f;
        for (int unsigned i=0; i<WIDTH_LOG; i++) begin
            for (int unsigned j=0; j<WIDTH; j++) begin
                tbl_f[i][j] = j[i];
            end
        end
    endfunction: tbl_f

    // table constant
    localparam tbl_t TBL = tbl_f();

    // logarithm
    function automatic logic [WIDTH_LOG-1:0] log_tbl_f (
        logic [WIDTH-1:0] value
    );
        for (int unsigned i=0; i<WIDTH_LOG; i++) begin
            log_tbl_f[i] = |(value & TBL[i]);
        end
    endfunction: log_tbl_f

    generate
    case (IMPLEMENTATION)
        0:  // reduction
            always_comb
            begin
                bin = log_tbl_f(oht);  // logarithm
                vld =          |oht;
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
            default:
                $fatal("Unsupported DIRECTION parameter value.");
            endcase
        default:  // parameter validation
            $fatal("Unsupported IMPLEMENTATION parameter value.");
    endcase
    endgenerate

endmodule: oht2bin_base
