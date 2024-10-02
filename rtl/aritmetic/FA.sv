module FA (
    input  logic A,   // data operand A bit
    input  logic B,   // data operand B bit
    input  logic Ci,  // carry input
    output logic S,   // sum
    output logic Co   // carry output
);
    assign S = A ^ B ^ Ci;
    assign Co = (A & B) | (Ci & (A ^ B));
endmodule: FA