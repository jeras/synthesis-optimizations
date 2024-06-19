///////////////////////////////////////////////////////////////////////////////
// Barrel shifter
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module barrel_shifter #(
    // size parameters
    parameter  int unsigned WIDTH = 32,
    // size local parameters
    localparam int unsigned WIDTH_LOG = $clog2(WIDTH)
)(
    // input signals
    input  logic [WIDTH-1:0] xi,  // input data vector
    // control signals
    input  logic [WIDTH_LOG-1:0] shift,  // shift amount
    // output vector
    output logic [WIDTH-1:0] xo   // rotate right
);

    assign xo = WIDTH'({2{xi}} >> shift);

endmodule: barrel_shifter
