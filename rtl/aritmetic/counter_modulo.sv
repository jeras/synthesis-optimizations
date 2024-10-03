///////////////////////////////////////////////////////////////////////////////
// counter (modulo),
// with parametrized implementation options
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module counter_modulo #(
    // size parameters
    parameter  int unsigned WIDTH = 32,
    // implementation
    parameter  int unsigned IMPLEMENTATION = 0
    // 0 - compare current
    // 1 - compare next
)(
    // system signals
    input  logic             clk,   // clock
    input  logic             rst,   // reset
    // counter
    input  logic             ena,   // enable
    input  logic [WIDTH-0:0] max,   // maximum value
    output logic [WIDTH-1:0] cnt,   // counter
    output logic             pls    // last pulse
);

    generate
    case (IMPLEMENTATION)
        1:  // compare current

            // local signals
            logic wrp;

            // wrap
            assign wrp = nxt == val-1;

            always_ff @(posedge clk, posedge rst)
            if (rst)  cnt <= '0;
            else if (ena) begin
                if (wrp)  cnt <= '0;
                else      cnt <= cnt + 1;
            end

        2:  // compare next

            // local signals
            logic [WIDTH-1:0] nxt;
            logic             wrp;

            // next
            assign nxt = cnt + 1;
            // wrap
            assign wrp = nxt == val;

            always_ff @(posedge clk, posedge rst)
            if (rst)  cnt <= '0;
            else if (ena) begin
                if (wrp)  cnt <= '0;
                else      cnt <= nxt;
            end

        default:  // parameter validation
            $fatal("Unsupported IMPLEMENTATION parameter value.");
    endcase
    endgenerate

    // pulse on wrap
    assign pls = ena & wrp;

endmodule: counter_modulo