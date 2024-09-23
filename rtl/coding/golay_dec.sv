///////////////////////////////////////////////////////////////////////////////
// Extended Golay decoder
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

import golay_pkg::*;

module golay_dec (
    input  logic [0:12-1] data,
    output logic [0:24-1] code
);

    always_comb
    begin
        // start from zero
        code = 24'b000000000000_000000000000;
        // sum (XOR) (TODO: find correct word) vectors
        for (int unsigned i=0; i<12; i++) begin
            if (data[i])  code ^= golay_matrix[i];
        end
    end

endmodule: golay_dec
