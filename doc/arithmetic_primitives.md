# Arithmetic primitives

## Introduction

### Overview

### Nomenclature

### Half/Full adder

Half and full adder are single bit primitives used to primarily construct ripple-carry adders (RCA).

A _half adder_ takes one data bit `A` from one operand and a cary bit `Ci` as inputs and
outputs a sum `S` and a cary output `Co`.

```SystemVerilog
module HA (
    input  logic A,   // data operand bit
    input  logic Ci,  // carry input
    output logic S,   // sum
    output logic Co   // carry output
);
    assign S = A ^ Ci;
    assign Co = A & Ci;
endmodule: HA
```

A _full adder_ takes two data bits `A`, `B` from two operands and a cary bit `Ci` as inputs and
outputs a sum `S` and a cary output `Co`.

```SystemVerilog
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
```

If one of the input operand is a constant (`B` for example),
a full adder can be replaced with a half adder with inverted outputs.

When `B=0`:

```SystemVerilog
    S = A ^ B ^ Ci = A ^ 1'b0 ^ Ci = A ^ Ci
    Co = (A & B) | (Ci & (A ^ B)) = (A & 1'b0) | (Ci & (A ^ 1'b0)) = Ci & A;
```

When `B=1`:

```SystemVerilog
    S = A ^ B ^ Ci = A ^ 1'b1 ^ Ci = ~(A ^ Ci)
    Co = (A & B) | (Ci & (A ^ B)) = (A & 1'b1) | (Ci & (A ^ 1'b1)) = A | (Ci & ~A) = (A | Ci) & (A | ~A) = A | Ci = ~(A & Ci);
```

## Components

### Ripple-carry adder (RCA)

A `ripple-carry adder` is a chain of _full adder_ cells.

```SystemVerilog
module RCA #(
    int WIDTH = 32
)(
    input  logic [WIDTH-1:0] A,   // data operand A vector
    input  logic [WIDTH-1:0] B,   // data operand B vector
    input  logic             Ci,  // carry input
    output logic             S,   // sum
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
    end
endmodule: RCA
```

In Verilog the same can be done with a vector instance.

```SystemVerilog
module RCA #(
    int WIDTH = 32
)(
    input  logic [WIDTH-1:0] A,   // data operand A vector
    input  logic [WIDTH-1:0] B,   // data operand B vector
    input  logic             Ci,  // carry input
    output logic             S,   // sum
    output logic             Co   // carry output
);
    // local signals
    logic [WIDTH-1:-1] Ct;  // carry chain    
    // vector instance
    FA add [WIDTH-1:0] (
        .A   (A),
        .B   (B),
        .Ci  (C[WIDTH-2:-1]),
        .S   (S),
        .Co  (C[WIDTH-1:0])
    );
    // output carry
    assign Co = C[WIDTH-1];
endmodule: RCA
```

A Ripple-carry adder with constant operand (for example incrementer/decrementer),
can be constructed with half adders and negators instead of full adders.

```SystemVerilog
module RCA #(
    int WIDTH = 32,
    logic [WIDTH-1:0] B,   // data operand B vector constant
)(
    input  logic [WIDTH-1:0] A,   // data operand A vector
    input  logic             Ci,  // carry input
    output logic             S,   // sum
    output logic             Co   // carry output
);
    // local signals
    logic [WIDTH-1:-1] Ct;  // carry chain
    logic [WIDTH-1:-1] St;  // temporary sum
    // half adder vector instance
    HA add [WIDTH-1:0] (
        .A   (A ),
        .Ci  (C [WIDTH-2:-1]),
        .S   (St),
        .Co  (Ct[WIDTH-1:0])
    );
    // local signals
    assign S = St[WIDTH-1:0] ^ B;
    assign C = Ct[WIDTH-1:0] ^ B;
    // output carry
    assign Co = C[WIDTH-1];
    end
endmodule: RCA
```

### Multiplier

### Multiply accumulate

### Divider

## References

