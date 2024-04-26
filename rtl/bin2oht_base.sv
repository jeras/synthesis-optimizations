///////////////////////////////////////////////////////////////////////////////
// binary to one-hot conversion (one-hot decoder),
// base with parametrized implementation options
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module bin2oht_base #(
    // size parameters
    parameter  int unsigned WIDTH = 32,
    // size local parameters
    localparam int unsigned WIDTH_LOG = $clog2(WIDTH),
    // implementation
    parameter  int unsigned IMPLEMENTATION = 0
    // 0 - loop
    // 1 - table
    // 2 - power
    // 3 - shift
)(
    input  logic [WIDTH_LOG-1:0] bin,
    output logic [WIDTH    -1:0] oht
);

    // table unpacked array type
    typedef bit [WIDTH_LOG-1:0] pow2_mask_t [WIDTH-1:0];

    // table function definition
    function automatic pow2_mask_t tbl_f();
        for (int unsigned i=0; i<WIDTH; i++) begin
            for (int unsigned j=0; j<WIDTH_LOG; j++) begin
                tbl_f[i][j] = i[j];
            end
        end
    endfunction: tbl_f

    // table constant
    localparam pow2_mask_t TBL = tbl_f;

    generate
    case (IMPLEMENTATION)
        0:  // table
            begin
                for (int unsigned i=0; i<WIDTH; i++) begin
                    oht[i] = (TBL[WIDTH_LOG-1:0] == bin);
                end
            end
        1:  // loop
            always_comb
            begin
                for (int unsigned i=0; i<WIDTH; i++) begin
                    oht[i] = (i[WIDTH_LOG-1:0] == bin);
                end
            end
        3:  // power
            begin
                assign oht = 2 ** bin;
            end
        3:  // shift
            begin
                assign oht = 1'b1 << bin;
            end
        default:  // parameter validation
            $fatal("Unsupported IMPLEMENTATION parameter value.");
    endcase
    endgenerate

endmodule: bin2oht_base
