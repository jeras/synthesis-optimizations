# Library of combinational components

This library focuses on basic combinational components
described in every digital design book.

- decoder
- one-hot encoder
- priority encoder
- equivalence/magnitude comparator,
- thermometer encoder,
- multiplexer,
- shifter.

The library uses adders in some cases,
but adders are not the fucus of this library.

Implemented components are fully parameterized/generalized,
and provided with different size/timing/power optimizations.

The focus of the library is on experimenting with
the following coding techniques:

- iterative algorithms,
- tree structures,
- recursion,
- loop unwinding and vectorization.

Components are provided with a simulation,
some with formal verification (TODO).

Components are synthesized on devices from various FPGA vendors,
and on an ASIC standard cell library (TODO).
Synthesis is done with the aim to observe:

- inference of multiplexers for FPGA and ASIC,
- inference of fast carry chains for FPGA and ASIC,
- mapping to various FPGA LUT sizes,
- mapping onto FPGA configurable logic blocks,
- mapping onto FPGA routing hierarchy.

## Components

### Multiplexer

### Barrel/funnel shifter

https://pages.hmc.edu/harris/cmosvlsi/4e/lect/lect18.pdf

### One-hot decoder and encoder

### Priority encoder

### Priority to one-hot conversion

I checked the book, the formula for _a word with a single 1-bit at the position of the rightmost 0-bit in x_ would be:
```Verilog
onehot = ~x & (x+1);
```

```Verilog
x_rev = ~bitreverse(x);
onehot = bitreverse(~(x_rev & (x_rev+1));
```
This operation is explicitely using addition.

A for loop formula would be (I did not run it, so it might be wrong):
```SystemVerilog
function [XLEN-1:0] onehot (
  input [XLEN-1:0] x
);
  for (int i=XLEN; i>0; i++) begin
  end
endfunction: onehot
```

I was wandering how different synthesis tools would handle this equation in comparison to a for loop formula.

A FPGA tool could do a better job with the addition formula

TODO:

- test -x and observe schematic
- test adder and mux primitives

### Equivalence and magnitude comparators

### Population counter

https://fpga.org/2014/09/05/quick-fpga-hacks-population-count/
https://www.researchgate.net/publication/266262724_Pipelined_Compressor_Tree_Optimization_using_Integer_Linear_Programming

### Programmable priority encoder

### Arbiter

## References

- [Priority encoder](https://en.wikipedia.org/wiki/Priority_encoder)
- [Binary Golay code](https://en.wikipedia.org/wiki/Binary_Golay_code)
- [Hamming code](https://en.wikipedia.org/wiki/Hamming_code#Hamming_codes_with_additional_parity_(SECDED))

- http://www-graphics.stanford.edu/~seander/bithacks.html
- https://www.beyond-circuits.com/wordpress/2009/01/recursive-modules/
- https://books.google.si/books/about/Hacker_s_Delight.html?id=VicPJYM0I5QC
- https://www.edaboard.com/threads/verilog-bit-mask-to-index-converter.274344/
- http://fpgacpu.ca/fpga/index.html
- https://pages.hmc.edu/harris/cmosvlsi/4e/lect/lect18.pdf
- https://github.com/riscv/riscv-bitmanip/releases/download/v0.93/bitmanip-0.93.pdf