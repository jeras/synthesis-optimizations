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
    input  logic [WIDTH-0:0] mod,   // modulo value
    output logic [WIDTH-1:0] cnt,   // counter
    output logic             wrp    // wrap status
);

generate
    case (IMPLEMENTATION)
        0:  // compare current
        begin
            // wrap
            assign wrp = {1'b0, cnt} == mod-1;

            always_ff @(posedge clk, posedge rst)
            if (rst)  cnt <= '0;
            else if (ena) begin
                if (wrp)  cnt <= '0;
                else      cnt <= cnt + 1;
            end
        end
        1:  // compare next
        begin
            // local signals
            logic [WIDTH-0:0] nxt;

            // next
            assign nxt = cnt + 1;
            // wrap
            assign wrp = nxt == mod;

            always_ff @(posedge clk, posedge rst)
            if (rst)  cnt <= '0;
            else if (ena) begin
                if (wrp)  cnt <= '0;
                else      cnt <= nxt;
            end
        end
        default:  // parameter validation
            $fatal("Unsupported IMPLEMENTATION parameter value.");
    endcase
    endgenerate

endmodule: counter_modulo