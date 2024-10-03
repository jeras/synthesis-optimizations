///////////////////////////////////////////////////////////////////////////////
// multiplexer with one-hot select,
// base with parametrized implementation options
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module mux_oht #(
    // data type
    parameter  type DAT_T = logic [4-1:0],
    // size parameters
    parameter  int unsigned WIDTH = 32,
    // implementation
    parameter  int unsigned IMPLEMENTATION = 0
    // 0 - reduction
    // 1 - linear
)(
    input  logic [WIDTH-1:0] oht,              // one-hot select
    input  DAT_T             ary [WIDTH-1:0],  // data array
    output logic             vld,              // valid (OR reduced one-hot)
    output DAT_T             dat               // data selected
);

    generate
    case (IMPLEMENTATION)
        0:  // reduction
            always_comb
            begin: reduction
                for (int unsigned b=0; b<$bits(DAT_T); b++) begin: data_loop
                    logic [WIDTH-1:0] tmp;
                    for (int unsigned i=0; i<WIDTH; i++) begin: control_loop
                        tmp[i] = ary[i][b];
                    end: control_loop
                    dat[b] = |(tmp & oht);
                end: data_loop
                vld = |oht;
            end: reduction
        1:  // chain
            always_comb
            begin: chain
                dat = '0;
                vld = 1'b0;
                for (int unsigned i=0; i<WIDTH; i++) begin
                    dat |= oht[i] ? ary[i] : '0;
                    vld |= oht[i];
                end
            end: chain
        default:  // parameter validation
            $fatal("Unsupported IMPLEMENTATION parameter value.");
    endcase
    endgenerate

endmodule: mux_oht
