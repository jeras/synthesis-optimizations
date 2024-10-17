///////////////////////////////////////////////////////////////////////////////
// counter wrapping (incrementer),
// with parametrized implementation options
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module counter_wrap #(
    // size parameters
    parameter  int unsigned WIDTH = 16,
    // implementation
    parameter  int unsigned IMPLEMENTATION = 0
    // 0 - carry in
    // 1 - multiplexer
)(
    // system signals
    input  logic             clk,  // clock
    input  logic             rst,  // reset
    // counter
    input  logic             ena,  // enable
    output logic [WIDTH-1:0] cnt   // counter
);

    generate
    case (IMPLEMENTATION)
        0:  // carry in
        begin
            always_ff @(posedge clk, posedge rst)
            if (rst)  cnt <= '0;
            else      cnt <= cnt + WIDTH'(ena);
        end
        1:  // multiplexer
        begin
            always_ff @(posedge clk, posedge rst)
            if (rst)       cnt <= '0;
            else if (ena)  cnt <= cnt + WIDTH'(1);
        end
        default:  // parameter validation
            $fatal("Unsupported IMPLEMENTATION parameter value.");
    endcase
    endgenerate

endmodule: counter_wrap