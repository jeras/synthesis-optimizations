///////////////////////////////////////////////////////////////////////////////
// adder,
// base with parametrized implementation options
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module add_base #(
    // size parameters
    parameter  int unsigned WIDTH = 32,
    // implementation
    parameter  int unsigned IMPLEMENTATION = 0
    // 0 - operator
    // 1 - loop
)(
    input  logic             ci ,  // carry in
    input  logic [WIDTH-1:0] opa,  // operand a
    input  logic [WIDTH-1:0] opb,  // operand b
    output logic [WIDTH-1:0] sum,  // sum
    output logic             co    // carry out
);

    generate
    case (IMPLEMENTATION)
        0:  // index
        begin
            assign {co, sum} = opa + opb + ci;
        end
        default:  // parameter validation
            $fatal("Unsupported IMPLEMENTATION parameter value.");
    endcase
    endgenerate

endmodule: add_base
