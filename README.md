# Library of combinational components

A quick link table for those who are looking for something specific instead of reading it all.

| SystemVerilog | VHDL | Description (link to documentation) |
|---------------|------|-------------------------------------|
| [`bin2oht.sv`](rtl/bin2oht.sv) | [`bin2oht.vhd`](rtl/bin2oht.vhd) | [binary to one-hot conversion (decoder)]() |
| [`oht2bin.sv`](rtl/oht2bin.sv) | [`oht2bin.vhd`](rtl/oht2bin.vhd) | [one-hot to binary conversion (simple encoder)]() |
| [`.sv`](rtl/.sv) | [`.vhd`](rtl/.vhd) | []() |
| [`.sv`](rtl/.sv) | [`.vhd`](rtl/.vhd) | []() |
| [`.sv`](rtl/.sv) | [`.vhd`](rtl/.vhd) | []() |
| [`.sv`](rtl/.sv) | [`.vhd`](rtl/.vhd) | []() |
| [`.sv`](rtl/.sv) | [`.vhd`](rtl/.vhd) | []() |

## Introduction

### Overview

This library focuses on basic combinational components
described in every digital design book.

- multiplexer,
- decoder
- one-hot encoder
- priority encoder
- thermometer encoder,
- equivalence/magnitude comparator,
- shifter,
- population count,
- arbitration.

The library uses arithmetic logic (adders) in some cases,
but different adder architectures are not the fucus of this library.

The focus of the library is on experimenting with
the following coding techniques:

- iterative algorithms,
- regular tree structures,
- recursion,
- loop unwinding and vectorization,
- HDL coding techniques.

Specific mapping of the RTL onto ASIC standard libraries and FPGA architectures during synthesis,
is discussed only in the context of how different coding styles and parameters
affect inference of dedicated structures:
- adders (fast carry chain),
- LUT (asynchronous read ROM).

Implemented components are parameterized/generalized,
and provided with different size/timing/power optimizations.

Components are provided with a simulation,
some with formal verification (TODO).

Components are synthesized on devices from various FPGA vendors,
and on an ASIC standard cell library (TODO).
Synthesis is done with the aim to observe:

- inference of multiplexers for FPGA and ASIC,
- inference of fast carry chains for FPGA and ASIC (half, full adders),
- mapping to various FPGA LUT sizes (LUT4, LUT5, LUT6),
- mapping onto FPGA CLB (configurable logic blocks),
- mapping onto FPGA routing hierarchy.

### Nomenclature

The nomenclature in literature is somehow confusing,
the same words are often used for different things depending on context,
which is not a problem when a single component is discussed,
but this library attempts to discuss many related components.

For example the word encoder is used as the opposite of decoder.
It can be used specifically for the relation between one-hot and binary coding,
or more generally for the transformation between any two codes.

Another example would be the distinction between one-hot and priority multiplexer,
the one-hot multiplexer uses a one-hot select signal,
but the priority multiplexer uses a weighted binary select signal.

There is also a lot of nomenclature overlap with coding theory,
which covers data compression, cryptography, error detection and correction, data transmission and data storage,
but is outside the scope of this library.

The words code and encoding are used interchangeably,
which is not great, a future version of this document might attempt to fix this.

The following codes/encodings are defined.

- `bin` - BINary ([weighted binary encoding](https://en.wikipedia.org/wiki/Binary_number)),
- `oht` - One-HoT ([one-hot encoding](https://en.wikipedia.org/wiki/One-hot)),
- `thr` - THeRmometer (thermometer encoding)
- `pry` - PRioritY (priority encoding)

Verilog/SystemVerilog syntax is used predominantly,
except when explicitly discussing VHDL implementations.
SystemVerilog is also used instead of mathematical notation,
since it is easier to interpret in the given context (RTL library).

The same number can be represented by different encodings.
The binary encoding is compact, it requires `$clog2(N)` bits to represent numbers in the range `0:N-1`.
One-hot, thermometer and priority encodings are verbose, they require `N` bits for the same range.

The following table shows the decimal number `a=3` coded in different formats,
all sized to allow the representation of numbers in the range `0:N-1` where `N=8`.
In binary, the number is represented with a `$clog2(N)=3` long vector,
while other encodings use a `N=8` long vector.

| encoding     | example literal | comment |
|--------------|-----------------|---------|
| `bin[3-1:0]` | `3'b011`/`3'd3` |         |
| `oht[8-1:0]` | `8'b00001000`   | the `a`-th bit is set `oth[a]=1'b1` the others are cleared |
| `thr[8-1:0]` | `8'b11111000`   | the `a`-th bit is set `oth[a]=1'b1` the bits below are cleared and bits above are set |
| `pry[8-1:0]` | `8'bXXXX1000`   | the `a`-th bit is set `oth[a]=1'b1` the bits below are cleared are undefined (can have any value) |

The one-hot and thermometer encodings are a subset of the priority encoding.

### Parameterization/generalization

The library is fully parameterized/generalized in terms of vector width,
but the vectors are always in descending range order with the rightmost LSB bit having the highest priority.
This order restriction is chosen so that the carry in linear implementations (see code examples)
propagates from right to left allowing inference of adders by synthesis tools.
This order is also the most common in modern research papers and implementations.

For use cases where the opposite priority order is desired (not common in modern designs),
the user can reorder the input/output vectors, but handling the binary encoding would take more effort.

TODO: unpacked array range order.

The diagrams also try to match the same orientation and order as bit vectors.

## Components

### Equivalence comparator

TODO: Equivalence/equality

The equivalence comparator compares an input vector `bin` against another input or constant vector `ref`.
Corresponding bits (vector bits with the same index) are compared individually
and the results are combined into a single bit (scalar) result `eqi`.

In an ASIC, the comparison is done with one of the following:

1. Using _bitwise binary exclusive OR operator_ `^` on `bin`, `ref`
   creates a vector with bits set where there is a difference,
   this vector is reduced using _unary OR operator_ `|` into a scalar
   indicating there was a difference,
   which is further negated with `~` to get equivalence `eqi`.

   ```SystemVerilog
   eqi = ~|(bin ^ ref);
   ```
2. Using _bitwise binary exclusive NOR operator_ `~^` on `bin`, `ref`
   creates a vector with bits set where there is a match,
   this vector is reduced using _unary AND operator_ `|` into a scalar
   indicating all bits are equal `eqi`.

   ```SystemVerilog
   eqi = &(bin ~^ ref);
   ```

In practice (ASIC and FPGA) it is best to use the _equality operator_ `==`,
and let the synthesis tool create the optimal implementation.

```SystemVerilog
eqi = (bin == ref);
```

If the reference vector `ref` is a constant, the XOR/XNOR operations
are reduced into a passthrough or negator.

### Address decoder (power of 2 aligned and sized ranges)

An address decoder 

### Binary to one-hot conversion

Tabular solution for `N=8` (`$clog2(N)=3`) uses a constant table with one entry for each binary value.
The `i`-th bit of `oth` output is set if the `bin` input matches the `i`-th element of the table.
The RTL library implementation contains a table generator.

```SystemVerilog
// table
localparam [3-1:0] TBL [8-1:0] = '{
    3'b000,
    3'b001,
    3'b010,
    3'b011,
    3'b100,
    3'b101,
    3'b110,
    3'b111
};
// conversion
for (int unsigned i=0; i<8; i++) begin
    oht[i] = (bin == TBL(bin)) ? 1'b1 : 1'b0;
end
```

The implementation is an equality comparator for each `oht` output bit.
This is how a decoder is usually implemented in an ASIC.

In a FPGA, if the `bin` input width is the same or less than the number of LUT inputs,
each `oht` output bit will consume a single LUT
(`bin[4-1:0]` fits into LUT4, `bin[6-1:0]` fits into LUT6, ...),
if the `bin` input width is larger multiple LUTs will be used.

The same approach can be implemented in a single loop,
creating table entries (`i[3-1:0]`) within the loop.

```SystemVerilog
for (int unsigned i=0; i<8; i++) begin
    oht[i] = (bin == i[3-1:0]) ? 1'b1 : 1'b0;
end
```

Alternative approaches use a power operator:

```SystemVerilog
oht = 2**bin;
```

or an equivalent shift operator:

```SystemVerilog
oht = 8'd1 << bin;
```

Most synthesis tools will implement both alternative solutions the same as the tabular solution.

### One-hot to binary conversion

Tabular solution for `N=8` uses a constant table with one entry for each binary value.
The library implementation contains a table generator.

```SystemVerilog
// table
localparam [N-1:0] PWR [3-1:0] = '{
    8'b01010101,
    8'b11001100,
    8'b11110000
};
// conversion
oht = PWR(bin);
```



### Multiplexer

### Barrel/funnel shifter

https://pages.hmc.edu/harris/cmosvlsi/4e/lect/lect18.pdf

### Priority encoder

### Priority to one-hot conversion

I checked the book, the formula for _a word with a single 1-bit at the position of the rightmost 0-bit in x_ would be:
```SystemVerilog
onehot = ~x & (x+1);
```

```SystemVerilog
x_rev = ~bitreverse(x);
onehot = bitreverse(~(x_rev & (x_rev+1));
```
This operation is explicitly using addition.

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

### Magnitude comparator

### Population counter

https://fpga.org/2014/09/05/quick-fpga-hacks-population-count/
https://www.researchgate.net/publication/266262724_Pipelined_Compressor_Tree_Optimization_using_Integer_Linear_Programming

### Programmable priority encoder

### Arbiter

TODO: arbiter with combinational loop.
related OpenSTA options:
-  set_logic_dc, set_logic_one, set_logic_zero
- conditional set_case_analysis, sta_cond_default_arcs_enabled, sta_dynamic_loop_breaking
- report issue: unset_data_check

https://www.edaboard.com/threads/moved-combinational-loop-synthesis.372034/
ones-complement adder

https://docs.amd.com/r/en-US/ug949-vivado-design-methodology/Case-Analysis

https://yosyshq.readthedocs.io/projects/yosys/en/latest/cmd/scc.html
https://stackoverflow.com/questions/44828776/yosys-logic-loop-falsely-detected



## References

### CPU

- https://books.google.si/books/about/Hacker_s_Delight.html?id=VicPJYM0I5QC
- http://www-graphics.stanford.edu/~seander/bithacks.html
- https://github.com/riscv/riscv-bitmanip/releases/download/v0.93/bitmanip-0.93.pdf

### Digital design

- http://fpgacpu.ca/fpga/index.html

### One-hot encoder/decoder

- https://en.wikipedia.org/wiki/One-hot
- https://en.wikipedia.org/wiki/Binary_decoder
- https://en.wikipedia.org/wiki/Encoder_(digital)
- https://www.edaboard.com/threads/priority-encoder-for-one-hot-to-binary.366915/

### Priority encoder

- [Priority encoder](https://en.wikipedia.org/wiki/Priority_encoder)
- https://www.edaboard.com/threads/verilog-bit-mask-to-index-converter.274344/
- https://www.beyond-circuits.com/wordpress/2009/01/recursive-modules/

### ECC

- [Hamming code](https://en.wikipedia.org/wiki/Hamming_code#Hamming_codes_with_additional_parity_(SECDED))
- [Binary Golay code](https://en.wikipedia.org/wiki/Binary_Golay_code)

- https://pages.hmc.edu/harris/cmosvlsi/4e/lect/lect18.pdf
