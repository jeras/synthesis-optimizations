///////////////////////////////////////////////////////////////////////////////
// equality comparator
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module eql_cmp #(
    // size parameters
    parameter  int unsigned WIDTH = 32,
    // implementation
    parameter  int unsigned IMPLEMENTATION = 0
    // 0 - equality operator
    // 1 - bitwise XOR and reduction NOR
    // 2 - bitwise XNOR and reduction AND
    // 3 - linear loop
    // 4 - linear vector
)(
    input  logic [WIDTH-1:0] val,
    input  logic [WIDTH-1:0] rfr,  // reference (rfr is a reserved keyword)
    output logic             eql
);

    generate
    case (IMPLEMENTATION)
        0:  // equality operator
            assign eql = val == rfr;
        1:  // bitwise XOR and reduction NOR
            assign eql = ~|(val ^ rfr);
        2:  // bitwise XNOR and reduction AND
            assign eql = &(val ~^ rfr);
        3:  // linear loop
            always_comb
            begin
                // initialization
                eql = 1'b1;
                // loop
                for (int unsigned i=0; i<WIDTH-1; i++) begin
                    eql &= val[i] ~^ rfr[i];
                end
            end
        4:  // linear vector
            always_comb
            begin
                // temporary vector
                logic [WIDTH:0] tmp;
                // vectorized loop, initialization is prepended to operand at LSB
                tmp &= {val ~^ rfr, 1'b0};
                // results are extracted from temporary vector MSB
                eql = tmp[WIDTH];
            end
        default:  // parameter validation
            $fatal("Unsupported IMPLEMENTATION parameter value.");
    endcase
    endgenerate

endmodule: eql_cmp
