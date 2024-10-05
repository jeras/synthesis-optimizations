module HA (
    input  logic A,   // data operand bit
    input  logic Ci,  // carry input
    output logic S,   // sum
    output logic Co   // carry output
);
    assign S = A ^ Ci;
    assign Co = A & Ci;
endmodule: HA