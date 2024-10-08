///////////////////////////////////////////////////////////////////////////////
// counter (wrap on maximum),
// with parametrized implementation options
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module counter_maximum #(
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
    input  logic [WIDTH-1:0] max,   // maximum value
    output logic [WIDTH-1:0] cnt,   // counter
    output logic             pls    // last pulse
);

    // local signals
    logic wrp;  // wrap condition

    // wrap on reaching maximum
    assign wrp = cnt == max;

    generate
    case (IMPLEMENTATION)
        0:  // carry in
        begin
            always_ff @(posedge clk, posedge rst)
            if (rst)  cnt <= '0;
            else begin
                if (ena & wrp)  cnt <= '0;
                else            cnt <= cnt + WIDTH'(ena);
            end
        end
        1:  // multiplexer
        begin
            always_ff @(posedge clk, posedge rst)
            if (rst)  cnt <= '0;
            else if (ena) begin
                if (wrp)  cnt <= '0;
                else      cnt <= cnt + 1;
            end
        end
        default:  // parameter validation
            $fatal("Unsupported IMPLEMENTATION parameter value.");
    endcase
    endgenerate

    // pulse on wrap
    assign pls = ena & wrp;

endmodule: counter_maximum