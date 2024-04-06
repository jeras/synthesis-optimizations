///////////////////////////////////////////////////////////////////////////////
// Equivalence comparator
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module equivalence_comparator_base #(
    // size parameters
    parameter  int unsigned WIDTH = 32
)(
    input  logic [WIDTH-1:0] i_a,
    input  logic [WIDTH-1:0] i_b,
    output logic             eq
);

    assign eq = i_a == i_b;

endmodule: equivalence_comparator_base
