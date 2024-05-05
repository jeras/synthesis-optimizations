///////////////////////////////////////////////////////////////////////////////
// magnitude comparator (unsigned),
// base with parametrized implementation options
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module mag_cmp_base #(
    // size parameters
    parameter  int unsigned WIDTH = 32,
    // implementation
    parameter  int unsigned IMPLEMENTATION = 0
    // 0 - operator
    // 1 - loop
)(
    input  logic [WIDTH-1:0] val,  // value
    input  logic [WIDTH-1:0] rfr,  // reference
    output logic             grt,  // greater than
    output logic             lst   // less    than
);

    assign grt = val > rfr;
    assign lst = val < rfr;

endmodule: mag_cmp_base
