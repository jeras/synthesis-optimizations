module RCA #(
    int WIDTH = 32
)(
    input  logic [WIDTH-1:0] A,   // data operand A vector
    input  logic [WIDTH-1:0] B,   // data operand B vector
    input  logic             Ci,  // carry input
    output logic [WIDTH-1:0] S,   // sum vector
    output logic             Co   // carry output
);
    // local signals
    logic [WIDTH-1:-1] C;  // carry chain
    // instantiation loop
    generate
    for (genvar int i=0; i<WIDTH; i++) begin:loop
        FA add (
            .A   (A[i]),
            .B   (B[i]),
            .Ci  (C[i-1]),
            .S   (S[i]),
            .Co  (C[i])
        );
    end: loop
    endgenerate
    // output carry
    assign Co = C[WIDTH-1];
endmodule: RCA