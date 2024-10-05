///////////////////////////////////////////////////////////////////////////////
// counter (fractional),
// with parametrized implementation options
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module counter_fractional #(
    // size parameters
    parameter  int unsigned WIDTH = 32,
    // implementation
    parameter  int unsigned IMPLEMENTATION = 0
    // 0 - carry in
    // 1 - multiplexer
)(
    // system signals
    input  logic             clk,   // clock
    input  logic             rst,   // reset
    // counter
    input  logic             ena,   // enable
    input  logic [WIDTH-1:0] add,   // addend value
    input  logic [WIDTH-1:0] max,   // maximum value
    output logic [WIDTH-1:0] cnt,   // counter
    output logic             pls    // output pulse
);

    generate
    case (IMPLEMENTATION)
        0:  // carry in
        begin
            // TODO
        end
        1:  // multiplexer
        begin
            // local signals
            logic unsigned [WIDTH-0:0] nxt;
            logic   signed [WIDTH-0:0] rem;
            logic                      wrp;

            // next
            assign nxt = cnt + add;
            // reminder
            assign rem = nxt - max;
            // wrap
            assign wrp = nxt >= max;
            assign wrp = rem >= 0;
            // reminder
            assign rem = nxt - max;

            always_ff @(posedge clk, posedge rst)
            if (rst)  cnt <= '0;
            else if (ena) begin
                if (wrp)  cnt <= rem;
                else      cnt <= nxt;
            end
        end
        default:  // parameter validation
            $fatal("Unsupported IMPLEMENTATION parameter value.");
    endcase
    endgenerate

endmodule: counter_fractional