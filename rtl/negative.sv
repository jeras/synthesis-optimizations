module negative #(
    int unsigned WIDTH = 32
)(
    // data signals
    input  logic [WIDTH-1:0] xi,
    output logic [WIDTH-1:0] xo
);

    assign xo = -xi;

endmodule: negative