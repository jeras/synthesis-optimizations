# Logic primitives

A quick link table for those who are looking for something specific instead of reading it all.

| SystemVerilog | VHDL | Description (link to documentation) |
|---------------|------|-------------------------------------|
| [`cmp_eql.sv`](rtl/cmp_eql.sv) | [`cmp_eql.vhd`](rtl/cmp_eql.vhd) | [Equality comparator]() |
| [`bin2oht.sv`](rtl/bin2oht.sv) | [`bin2oht.vhd`](rtl/bin2oht.vhd) | [binary to one-hot conversion (decoder)]() |
| [`oht2bin.sv`](rtl/oht2bin.sv) | [`oht2bin.vhd`](rtl/oht2bin.vhd) | [one-hot to binary conversion (simple encoder)]() |
| [`oht2thr.sv`](rtl/oht2thr.sv) | [`oht2thr.vhd`](rtl/oht2thr.vhd) | []() |
| [`.sv`](rtl/.sv) | [`.vhd`](rtl/.vhd) | []() |
| [`.sv`](rtl/.sv) | [`.vhd`](rtl/.vhd) | []() |
| [`.sv`](rtl/.sv) | [`.vhd`](rtl/.vhd) | []() |

## Introduction

### Overview

This library focuses on basic combinational components
described in every digital design book.

- multiplexer,
- decoder,
- one-hot encoder,
- priority encoder,
- thermometer encoder,
- equivalence/magnitude comparator,
- mask/range address decoder,
- Gray encoder/decoder,
- shifter,
- population count,
- arbitration,
- [sorting/routing network](https://en.wikipedia.org/wiki/Sorting_network).

The library uses arithmetic logic (adders) in some cases,
but different adder architectures are not the fucus of this library.

The focus of the library is on experimenting with
the following coding techniques:

- iterative algorithms,
- loop unwinding and vectorization,
- parallel prefix network structures,
- recursion,
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
which covers data compression, cryptography, error detection and correction,
data transmission and data storage,
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
The binary encoding is compact, it requires `$clog2(WIDTH)` bits to represent numbers in the range `0:WIDTH-1`.
One-hot, thermometer and priority encodings are verbose, they require `WIDTH` bits for the same range.

The following table shows the decimal number `i=3` coded in different formats,
all sized to allow the representation of numbers in the range `0:WIDTH-1` where `WIDTH=8`.
In binary, the number is represented with a `$clog2(WIDTH)=3` long vector,
while other encodings use a `WIDTH=8` long vector.

| encoding     | example literal | comment |
|--------------|-----------------|---------|
| `bin[3-1:0]` | `3'b011`/`3'd3` |         |
| `oht[8-1:0]` | `8'b00001000`   | the `i`-th bit is set `oth[i]=1'b1` the others are cleared |
| `thr[8-1:0]` | `8'b11111000`   | the `i`-th bit is set `oth[i]=1'b1` the bits below are cleared and bits above are set |
| `pry[8-1:0]` | `8'bXXXX1000`   | the `i`-th bit is set `oth[i]=1'b1` the bits below are cleared are undefined (can have any value) |

The one-hot and thermometer encodings are a subset of the priority encoding.

### Parameterization/generalization

The library is fully parameterized/generalized in terms of vector width,
but the vectors are always in descending range order with the rightmost LSB bit having the highest priority.
This order restriction is chosen so that the carry in linear implementations (see code examples)
propagates from right to left allowing inference of adders by synthesis tools.
This order is also the most common in modern research papers and implementations.

For use cases where the opposite priority order is desired (not common in modern designs),
the user can reorder the input/output vectors, but handling the binary encoding would take more effort.

TODO: think through the best unpacked array range order, for memories it is usually ascending.

The diagrams also try to match the same orientation and order as bit vectors.

### Complexity

| problem (solution)      | size   | timing    |
|-------------------------|--------|-----------|
| bitwise                 | O(n)   | O(C)      |
| reduction (chain)       | O(n)   | O(n)      |
| reduction (tree)        | O(n)   | O(log(n)) |
| parallel prefix (chain) | O(n)   | O(n)      |
| parallel prefix (tree)  | O(n)   | O(log(n)) |
| non associative (chain) | O(n)   | O(n)      |

#### Linear versus tree structure

One of the aims of this document is to showcase the difference
between implementing a combinational logic problem as
a linear structure (carry chain) or tree structure (hierarchy).

Logic blocks will be drawn horizontally, the way adders are usually drawn.
The blocks are a rectangle `WIDHT` wide and either `WIDTH_LOG=$clog2(WIDTH)` or `1` deep,
depending on the reduction operation performed by the block.

Just for this chapter, the signals connected to the block will be named as:

- perpendicular (`per_i/o`) vector of `WIDTH` bits and
- lateral (`lat_i/o`) vector of `WIDTH_LOG` bits or scalar.

![Block with logarithmic reduction.](doc/block_reduction_log.svg)

![Block with reduction to scalar.](doc/block_reduction_one.svg)

Basic building blocks are simple and only handle short vectors.
ASIC examples would be 2/3/4-input AND/OR gates, ...
FPGA examples would be LUT4/5/6 and CLBs.

The following two chapters provide a general overview of the two structures,
explaining some advantages and disadvantages.

| property          | linear   | tree          |
|-------------------|----------|---------------|
| logic area        | O(WIDTH) | O(WIDTH)      |
| routing length    | O(1)     | O(WIDTH)      |
| propagation delay | O(WIDTH) | O(log(WIDTH)) |
| power consumption | TBD      | TBD           |

##### Linear structure

A **linear structure** can also be called a **chain** or a **cascade**.

A linear structure is a concatenation of simple building blocks.
A partial result propagates through the structure,
in this document the preferred direction is from right (LSB) to left (MSB).
The final output of the linear structure is the partial result of the last block in the chain.

![Linear structure.](doc/structure_linear.svg)

The logic area is equal to `WIDTH` copies of some basic building block.
The routing is local and short.

The asymptotical propagation delay has a linear O(WIDTH) dependency on problem size.
The lateral signal `lat` propagates from block to block (as in an ripple carry adder).
This means output vector `per_o` delay increases from index `0` to `WIDTH-1`.
The propagation delay is the sum of (`_i` to `ctl_o`) delays of all building blocks.

In general the linear delay dependency to data vector width is undesirable,
but it is not always an issue,
if a linear structure is combinationaly preceded by another linear structure
(for example a ripple carry adder),
than the signals can move along the line in tandem,
so the delay of the two combined is not the sum of the delay of each,
but instead the second operation adds just a single element delay to the delay of the first operation.
See the timing annotated simulations for a better explanation.

TODO: another name "parallel prefix tree".

##### Tree structure

The problem is subdivided into smaller problems
which are then organized into a hierarchical tree,
so that the results from multiple branches are combined
using the same base building block,
as it is used to calculate the results from the branches themselves.

This approach requires the design of building blocks where
the encoding of combined outputs from multiple blocks
matches the encoding used at the input into each block.

Another restriction is that the tree structure must be regular,
each node connects to a `SPLIT` number of sub-nodes.
`SPLIT` can be any integer in case the node performs a reduction to a scalar
and it can have other inputs/outputs of the same `WIDTH`.
In case the node performs a reduction to a logarithm of 2,
only power of 2 `SPLIT` values are possible.
For now this document only discusses this two reduction options.

The main advantage of tree structures is improved asymptotical propagation delay
with a logarithmic O(log(WIDTH)) dependency on problem size.

In this document tree structures are mainly implemented using **recursion**.

![Tree structure.](doc/structure_tree.svg)

## Components

### Bitwise AND/OR/XOR/NOT operation

Verilog/SystemVerilog bitwise operators can be used to implement
this operations on a pair of vectors `a_i` and `b_i`:

```SystemVerilog
// input vector operands
logic [WIDTH-1:0] a_i;
logic [WIDTH-1:0] b_i;
// output vector results
logic [WIDTH-1:0] and_o;
logic [WIDTH-1:0] or_o;
logic [WIDTH-1:0] xor_o;

assign and_o = a_i & b_i;
assign or_o  = a_i | b_i;
assign xor_o = a_i ^ b_i;
```

To negate only selected bits the operand `a_i` is bitwise XOR-ed with the control signal `b_i`.
The effect on each bit is defined as `xor_o[i] = b_i[i] ? ~a_i[i] : a_i[i];`.

Bitwise negation uses a single input vector `op_i`:

```SystemVerilog
// input vector operand
logic [WIDTH-1:0] op_i;
// output vector result
logic [WIDTH-1:0] not_o;

assign not_o = ~a_i;
```

Bitwise vector operations are broken into scalar operations
on individual bits in the vector.
They do not form a linear or tree structure,
there are no long timing paths and all routing is local and short.

### Reduction unary AND/OR/XOR operation

Verilog/SystemVerilog reduction unary operators can be used to implement this operations:

```SystemVerilog
// input vector operand
logic [WIDTH-1:0] op_i;
// output scalar results
logic and_o;
logic or_o;
logic xor_o;

assign and_o = & op_i;
assign or_o  = | op_i;
assign xor_o = ^ op_i;
```

FPGA/ASIC synthesis tools are expected to create a tree of primitives.
LUTs for FPGA and AND/OR/XOR standard cells for ASIC.

Reduction unary operations can be written explicitly as a linear structure
using a loop over vector indices.

```SystemVerilog
always_comb
begin
    // initialization
    and_o = 1'b1;
    or_o  = 1'b0;
    xor_o = 1'b0;
    // loop
    for (unsigned int i=0; i<WIDTH-1; i++) begin
        and_o &= op_i[i];
        or_o  |= op_i[i];
        xor_o ^= op_i[i];
    end
end
```

The same can be done without a loop, using vectors:

```SystemVerilog
always_comb
begin
    // temporary vectors
    logic [WIDTH:0] and_t;
    logic [WIDTH:0] or_t ;
    logic [WIDTH:0] xor_t;
    // vectorized loop, initialization is prepended to operand at LSB
    and_t &= {op_i, 1'b1};
    or_t  |= {op_i, 1'b0};
    xor_t ^= {op_i, 1'b0};
    // results are extracted from temporary vector MSB
    and_o = and_t[WIDTH];
    or_o  = or_t [WIDTH];
    xor_o = xor_t[WIDTH];
end
```

Some simulation/synthesis tools might have issues with this code.
Since the same vector is used on both sides of a combinational assignment,
tools might see this as a false combinational loop.

It is not obvious whether synthesis tools would interpret the linear RTL
as a linear structure and implement it as such,
or they would just optimize the code into a tree.

TODO: Yosys does have an option for the conversion from chain to tree.

### Parallel prefix AND/OR/XOR operation

Parallel prefix AND/OR/XOR operations differ from regression
in that thay produce an output for each input and it also depends on the previous output.
Inputs and outputs have a defined priority order.

Parallel prefix AND/OR can be used to convert
priority vectors into thermometer vectors,
which is usefull for priority encoders.

Parallel prefix XOR is used in Gray to binary encoding conversion.

```SystemVerilog
always_comb
begin
    // loop
    for (unsigned int i=0; i<WIDTH-1; i++) begin
        and_o[i] = op_i[i] & (i>0 ? and_o[i-1] : 1'b1;
        or_o [i] = op_i[i] | (i>0 ? or_o [i-1] : 1'b0;
        xor_o[i] = op_i[i] ^ (i>0 ? xor_o[i-1] : POLARITY;
    end
end
```

### Equality comparator

The equality comparator compares an input vector `bin` against another input or constant vector `ref`.
Input vectors are first compared bitwise and the resulting vector is reduced to a scalar result `eql`.

```SystemVerilog
// binary and reference input vectors
logic [WIDTH:0] bin;
logic [WIDTH:0] ref;
// result scalar
logic eql
```

In an ASIC, the comparison is done with one of the following:

1. Using _bitwise binary exclusive OR operator_ `^` on `bin`, `ref`
   creates a vector with bits set where there is a difference,
   this vector is reduced using _unary OR operator_ `|` into a scalar
   indicating there was a difference,
   which is further negated with `~` to get equality `eql`.

   ```SystemVerilog
   eql = ~|(bin ^ ref);
   ```

2. Using _bitwise binary exclusive NOR operator_ `~^` on `bin`, `ref`
   creates a vector with bits set where there is a match,
   this vector is reduced using _unary AND operator_ `&` into a scalar
   indicating all bits are equal `eql`.

   ```SystemVerilog
   eql = &(bin ~^ ref);
   ```

In practice (ASIC and FPGA) it is best to use the _equality operator_ `==`,
and let the synthesis tool create the optimal implementation.

```SystemVerilog
eql = (bin == ref);
```

If the reference vector `ref` is a constant, the XOR/XNOR operations
are reduced into a passthrough or negator.

If the reference vector is `0` (all bits are zero).

```SystemVerilog
eql = (bin == '0);
eql = ~(|bin);
```

If the reference vector is `-1` (all bits are one).

```SystemVerilog
eql = (bin == '1);
eql = &bin;
```

Synthesis tools would implement the above code with a tree structure.

In ASIC a tree of AND/OR/XOR logic cells
with two or more inputs will be used to construct the tree.
TODO: add link to Yosys option regarding reduction.

In a FPGA, if the `bin`/`ref` input width is the same or less than the number of LUT inputs,
the operation will consume a single LUT.
(`bin[4-1:0]` fits into LUT4, `bin[6-1:0]` fits into LUT6, ...),
if the `bin` input width is larger a tree of multiple LUTs will be used.

It is possible to implement the equality comparator using explicitly linear code
described in the _Reduction unary AND/OR/XOR operation_ section.

```SystemVerilog
always_comb
begin
    // initialization
    eql = 1'b1;
    // loop
    for (unsigned int i=0; i<WIDTH-1; i++) begin
        eql &= bin[i] ~^ ref[i];
    end
end
```

The same can be done without a loop, using vectors:

```SystemVerilog
always_comb
begin
    // temporary vector
    logic [WIDTH:0] tmp;
    // vectorized loop, initialization is prepended to operand at LSB
    tmp &= {bin ~^ ref, 1'b0};
    // results are extracted from temporary vector MSB
    eql = tmp[WIDTH];
end
```

The equal to zero comparator can also be written using arithmetic addition/subtraction.
The two's complement of a nonzero unsigned integer is negative.
So a number is equal to zero if its two's complement is not negative.

```SystemVerilog
logic [WIDTH:0] tmp;
tmp = -bin;
eql = ~tmp[WIDTH];
```

The arithmetic negation is achieved by bitwise negating the binary input vector,
and adding 1 to is, this can be done using a half adder chain.

```SystemVerilog
logic [WIDTH:0] tmp;
tmp = (~bin) + 1;
eql = ~tmp[WIDTH];
```

### Address mask decoder

(power of 2 aligned and sized ranges)

### Address range decoder

TODO

### Binary to one-hot conversion

A common name for this is just _decoder_.

A tabular solution for `WIDTH=8` (`WIDTH_LOG=$clog2(WIDTH)=3`) uses a constant table with one entry for each binary value.
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
creating table entries (`i[WIDTH_LOG-1:0]`) within the loop.

```SystemVerilog
for (int unsigned i=0; i<WIDTH; i++) begin
    oht[i] = (bin == i[WIDTH_LOG-1:0]) ? 1'b1 : 1'b0;
end
```

Alternative approaches use a power operator:

```SystemVerilog
oht = 2**bin;
```

Or an equivalent shift operator:

```SystemVerilog
oht = 8'd1 << bin;
```

Most synthesis tools will implement both alternative solutions the same as the tabular solution.

### One-hot to binary conversion

Tabular solution for `WIDTH=8` uses a constant table with one entry for each binary value index.
The library implementation contains a table generator.
The `j`-th column in the table (from right to left)
is binary representation of the number `j`.
The `i`-th bit of `bin` is the AND reduction of the `oht` vector
bitwise OR-ed with the `i`-th row in the table.

```SystemVerilog
// table
localparam [8-1:0] TBL [3-1:0] = '{
    8'b01010101,
    8'b11001100,
    8'b11110000
};
// conversion
for (int unsigned i=0; i<3; i++) begin
    bit[i] = |(oht & TBL[i]);
end
```

The transposed table is my attempt to convey the idea
of using logarithm of 2, the opposite operation to power of 2.
HDL languages Verilog/SystemVerilog and VHDL do not provide a synthesizable logarithm operator.
A similar approach is often used to implement this conversion in software,
on RISC-V the `WIDTH` would be `XLEN` (GPR register width, 32-bit on RV32 and 64-bit on RV64).

An explicitly linear implementation of the operation can be written with slightly more compact code.

```SystemVerilog
always_comb
begin
    bin = '0;
    for (int unsigned i=0; i<WIDTH; i++) begin
        bin |= oht[i] ? i[WIDTH_LOG-1:0] : WIDTH_LOG'('0);
    end
end
```

In case this would provide some kind of advantage (shared logic),
the operation could also be implemented using `WIDTH_LOG` adders.

### Multiplexer

A multiplexers extracts one of the elements of an array
based on a control signal which is usually either one-hot or binary encoded.

The data array `ary` of elements of `DAT_T` type (SystemVerilog type generic)
would be defined as (the unpacked dimension can have ascending or descending order):

```SystemVerilog
DAT_T ary [0:WIDTH-1];
```

The one-hot select multiplexer would mask each array element
with the corresponding bit in the one-hot select vector `oht[WIDTH-1:0]`,
and than apply OR reduction to combine all those masked values into the output `dat`.

TODO: wire down an explicit unary regression.

The one-hot select multiplexer can also be written as an explicit linear structure.

```SystemVerilog
dat = '0;
for (int unsigned i=0; i<WIDTH; i++) begin
    dat |= oht[i] ? ary[i] : '0;
end
```

The synthesis tool will construct a tree from the OR reduction.
TODO: Yosys has

The priority select multiplexer is similar to the one-hot version,
but more than one select input can be active, and the one with the highest priority
defines which array input maps to the data output.

The order in which the priority vector bits are processed defines the priority order.
In the given example the priority vector is precessedfrom right to left
giving the rightmost `pry` bit the highest priority.

```SystemVerilog
dat = '0;
for (int unsigned i=0; i<WIDTH; i++) begin
    dat = oht[i] ? ary[i] : dat;
end
```

The binary select multiplexer (also called priority multiplexer),
can be implemented using HDL array indexing syntax
with a binary select signal `bin[WIDTH_LOG-1:0]`.

```SystemVerilog
    dat = ary[bin];
```

Synthesis tools construct a tree of multiplexers
with a slice of the select signal at each layer.

This architecture can be a good fit for FPGA tools.
A LUT6 can implement a 4 to 1 multiplexer with a 2 bit binary select.

One-hot multiplexer is the preferred solution for ASIC designs,
since it can be constructed from the simplest/fastest logic cells.
TODO: there is no clear cut, each has its advantages.

### Barrel/funnel shifter

https://pages.hmc.edu/harris/cmosvlsi/4e/lect/lect18.pdf

### Priority to thermometer conversion

Since the one-hot encoding is an edge case of the priority encoding
(as is thermometer encoding itself) this conversion results in
thermometer encoding regardless whether the input is
priority, one-hot or thermometer encoded.

```SystemVerilog
always_comb
begin
    logic [WIDTH-1:-1] tmp
    tmp[-1] = 1'b0;
    for (int i=0; i<WIDTH; i++) begin
        tmp[i] = pry[i] | tmp[i-1];
    end
    thr = tmp[WIDTH-1:0];
end
```

### Priority to one-hot conversion

A priority vector has more than one active (hot) bit.
The priority of active bits is usually defined as
the LSB (rightmost) bit in a vector with descending range `pry[WIDTH-1:0]`.

An explicit linear implementation uses the `vld` signal
to distinguish between between indexes before and after an active priority bit.

```SystemVerilog
always_comb
begin
    vld = 1'b0;
    oht = '0;
    for (int i=0; i<WIDTH; i++) begin
        oht[i] = pry[i] & ~vhd;
        vld    = pry[i] |  vhd;
    end
end
```

The same code can be written using vectors instead of a loop.

```SystemVerilog
always_comb
begin
    // temporary vector is a thermometer version of the priority vector
    logic [WIDTH-1:-1] tmp = '0;
    tmp[WIDTH-1:0] = tmp[WIDTH-2:-1] | pry;
    oht = ~tmp[WIDTH-2:-1] & pry;
    vld =  tmp[WIDTH-1];
end
```

For the opposite priority order, with MSB (leftmost) having the highest priority,
the linear implementations using a loop and vectors are:

```SystemVerilog
always_comb
begin
    vld = 1'b0;
    oht = '0;
    for (int i=WIDTH-1; i<=0; i--) begin
        oht[i] = pry[i] & ~vhd;
        vld    = pry[i] |  vhd;
    end
end
```




I checked the book, the formula for _a word with a single 1-bit at the position of the rightmost 0-bit in x_ would be:

```SystemVerilog
onehot = ~x & (x+1);
```

```SystemVerilog
x_rev = ~bitreverse(x);
onehot = bitreverse(~(x_rev & (x_rev+1));
```

This operation is explicitly using addition.

### Priority to binary conversion

priority encoder

### Magnitude comparator

### Population counter

https://fpga.org/2014/09/05/quick-fpga-hacks-population-count/
https://www.researchgate.net/publication/266262724_Pipelined_Compressor_Tree_Optimization_using_Integer_Linear_Programming

### Programmable priority encoder

### Arbiter

TODO: arbiter with combinational loop.
Related OpenSTA options:

-  `set_logic_dc`, `set_logic_one`, `set_logic_zero`
- conditional set_case_analysis, `sta_cond_default_arcs_enabled`, `sta_dynamic_loop_breaking`
- report issue: `unset_data_check`

https://www.edaboard.com/threads/moved-combinational-loop-synthesis.372034/
ones-complement adder

https://docs.amd.com/r/en-US/ug949-vivado-design-methodology/Case-Analysis

https://yosyshq.readthedocs.io/projects/yosys/en/latest/cmd/scc.html
https://stackoverflow.com/questions/44828776/yosys-logic-loop-falsely-detected

## Plans

### Combined arbiter and multiplexer implementations

This implementations provide significant timing and power consumption advantages.
The multiplexer select signals are generated at each tree node,
thus arriving early (better propagation delay),
the distribution reduces fan-out thus improving timing and power,
Since the select signals are derived from local arbitration,
they toggle less (no toggling caused by combining with other nodes),
and thus provide significant power reduction.

The simple priority arbiter can be modified almost trivially.

For a round robin arbiter I have a reference implementation (actually just a book documenting it, not the actual code),
but I think I should be able to further improve and generalize it.

I observed the AXI multiplexer from the Pulp Platform and think I can do better.
Their current implementation is using the established approach
with a pair of priority arbiters and thermometer encoding mask for one of them.
This approach is not compatible with combining multiplexers.
They might provide me with researches willing to test my implementations
on professional ASIC tools.

### FPGA synthesis

Synthesis of linear and tree structures on popular families of FPGA devices from major vendors.

A synthesis script would go through different implementations of each component with a range of WIDTH values.

The scripts would create tables and graphs for each component and implementation
providing the measured logic consumption and propagation delays.
I also wish to provide vector diagrams (pdf, svg) of each implementation,
to be able to check whether the desired structure (linear versus tree is achieved),
I would also like to see if the fast carry chain logic is inferred when it is expected to provide an advantage.

### ASIC synthesis

Similar to FPGA synthesis, using open source ASIC PDK and standard cell libraries (Sky130, ...)
with the addition of P&R and static/dynamic power measurements using OpenSTA.
The dynamic power measurements would be done using VCD files from timing annotated simulation.

I would also like to see whether an adder followed by a linear zero comparator
provides better timing compared to a tree implementation.
For this I would show the waveforms from timing annotated simulation,
overlayed waveforms from simulation with multiple random or exhaustive input values.

https://yosyshq.readthedocs.io/projects/yosys/en/latest/cmd/demuxmap.html

https://yosyshq.readthedocs.io/projects/yosys/en/latest/cmd/extract_reduce.html

## References

### FPGA mapping

https://idus.us.es/bitstream/handle/11441/134956/1/electronics-11-00027-v2.pdf?sequence=1
https://ieeexplore.ieee.org/document/831434
https://ieeexplore.ieee.org/document/5272382

### Yosys techmap

https://tomverbeure.github.io/2022/11/18/Primitive-Transformations-with-Yosys-Techmap.html
https://github.com/YosysHQ/yosys/blob/main/docs/source/yosys_internals/formats/cell_library.rst

### CPU

- https://books.google.si/books/about/Hacker_s_Delight.html?id=VicPJYM0I5QC
- http://www-graphics.stanford.edu/~seander/bithacks.html
- https://github.com/riscv/riscv-bitmanip/releases/download/v0.93/bitmanip-0.93.pdf

### Design synthesis optimization in practice

Basilisk: Achieving Competitive Performance with
Open EDA Tools on an Open-Source
Linux-Capable RISC-V SoC
https://arxiv.org/pdf/2405.03523


### Bitwise

Similar to [`map` higher-order function](https://en.wikipedia.org/wiki/Map_(higher-order_function)).

### General encoder decoder

Synthesising Heterogeneously Encoded Systems
https://apt.cs.manchester.ac.uk/ftp/pub/apt/papers/WT_Async06.pdf

### Reduction and commutativity

Here assuming commutativity is required and enough to define a reduction operation (did not see a proof yet).
I did not find a good generic definition of boolean reduction.
There is the [`reduce`/`fold` higher order functions](https://en.wikipedia.org/wiki/Fold_(higher-order_function))
from the parallel processing field and [Lambda calculus](https://en.wikipedia.org/wiki/Lambda_calculus).

Of special interest are operations which are commutative but not associative,
see [Commutative magma](https://en.wikipedia.org/wiki/Commutative_magma).

Yosys `extract_reduce`
https://yosyshq.readthedocs.io/projects/yosys/en/latest/cmd/extract_reduce.html

### Parallel prefix and associativity

Wikipedia provides an overview of the [Prefix sum](https://en.wikipedia.org/wiki/Prefix_sum) operation,
and a definition of [associative property](https://en.wikipedia.org/wiki/Associative_property),
which can be used to construct a test using an equality checker
(the two sides of the associativity operation are equal).
A more efficient test would be [Light's associativity test](https://en.wikipedia.org/wiki/Light%27s_associativity_test).
The Bednarek’s extension to this test is also mentioned.

This article provides some interesting transformations from
recurrence relations (https://en.wikipedia.org/wiki/Recurrence_relation) to prefix sum:
https://www.cs.cmu.edu/afs/cs/academic/class/15750-s11/www/handouts/PrefixSumBlelloch.pdf
This article provides some interesting transformations from
recurrence relations (https://en.wikipedia.org/wiki/Recurrence_relation) to prefix sum:
https://www.cs.cmu.edu/afs/cs/academic/class/15750-s11/www/handouts/PrefixSumBlelloch.pdf

https://courses.csail.mit.edu/18.337/2004/book/Lecture_03-Parallel_Prefix.pdf

https://www.cs.cmu.edu/~guyb/papers/Ble93.pdf

A Taxonomy of Parallel Prefix Networks
David Harris
https://pages.hmc.edu/harris/research/taxonomy.pdf
Article focuses on adders, but it is otherwise about generalization.

Design of high-performance CMOS priority encoders and incrementer/decrementers using multilevel lookahead and multilevel folding techniques
https://ieeexplore.ieee.org/document/974546

Reddit discussions:
https://www.reddit.com/r/Verilog/comments/1apw1tr/_/

Pulp Platform LZC
https://github.com/pulp-platform/common_cells/blob/69d40a536665ab9c8f0066ee48b139579df7fccd/src/lzc.sv

### Digital design

- http://fpgacpu.ca/fpga/index.html

### One-hot encoder/decoder

- https://en.wikipedia.org/wiki/One-hot
- https://en.wikipedia.org/wiki/Binary_decoder
- https://en.wikipedia.org/wiki/Encoder_(digital)
- https://www.edaboard.com/threads/priority-encoder-for-one-hot-to-binary.366915/

https://en.wikipedia.org/wiki/Sum-addressed_decoder

### Multiplexer

One hot multiplexer synthesis using Xilinx Vivado for the Ultrascale family.

https://andy-knowles.github.io/one-hot-mux/


http://fpgacpu.ca/fpga/Multiplexer_One_Hot.html

### Arbiter

Algorithm-Hardware Codesign of Fast Parallel Round-Robin Arbiters
Si Qing Zheng, Senior Member, IEEE, and Mei Yang, Member, IEEE
https://ieeexplore.ieee.org/abstract/document/4020514

A Low-Latency Fair-Arbiter Architecture for Network-on-Chip Switches
https://www.mdpi.com/2076-3417/12/23/12458#B23-applsci-12-12458
example of unfair arbiter

Fast arbiters for on-chip network switches
https://ieeexplore.ieee.org/document/4751932
Also discusses cyclic implementation.

Engineering Issues, Arbiters and Allocators
http://cva.stanford.edu/classes/ee382c/ee482b/scribes01/lect11/lect11.pdf
Discusses fairness

A fair arbitration for Network-on-Chip routing with odd-even turn model
Lu Liu, Zhangming Zhu, Duan Zhou, Yintang Yang

Fast Fair Arbiter Design in Packet Switches
Feng Wang and Mounir Hamdi

A FAST ARBITRATION SCHEME FOR TERABIT PACKET SWITCHES
H. Jonathan Chao, Cheuk H. Lam, and Xiaolei Guo 
https://ieeexplore.ieee.org/document/829968

#### Arbiter fairness

Statistial Fairness of Ordered Arbiters
A. Madalinski, A. Bystrov, A. Yakovlev
https://www.researchgate.net/publication/2321410_Statistical_Fairness_of_Ordered_Arbiters

### Arithmetic operations

#### Adder

https://en.wikipedia.org/wiki/Adder_(electronics)
https://cseweb.ucsd.edu/classes/fa06/cse246/lingadder.pdf
http://www.rjsweb.net/publications/asilomar_conference_38_paper_2004.pdf

https://github.com/mattvenn/instrumented_adder/tree/177d358d927fc541a00551a8c82ca78676e935e4
https://github.com/tdene/synth_opt_adders
https://github.com/lnis-uofu/yosys_prefix_trees/tree/main

#### Incrementer/Decrementer

Highly parallel increment/decrement using CMOS technology
R. Hashemian
https://ieeexplore.ieee.org/document/140858

### FIR/IIR filters

https://en.wikipedia.org/wiki/Finite_impulse_response
https://en.wikipedia.org/wiki/Infinite_impulse_response

file:///home/izi/VLSI/doc/potsangbam2019.pdf

### CIC

This is a bit outside from the overall theme.

https://tomverbeure.github.io/2020/09/30/Moving-Average-and-CIC-Filters.html

https://tomverbeure.github.io/2020/12/20/Design-of-a-Multi-Stage-PDM-to-PCM-Decimation-Pipeline.html

#### Vocoder

https://web.archive.org/web/20040617224423/http://www.ircam.fr/equipes/analyse-synthese/roebel/paper/dafx2003.pdf
https://github.com/haoyu987/phasevocoder

A Review of Time-Scale Modification of Music Signals
https://www.mdpi.com/2076-3417/6/2/57

https://www.youtube.com/watch?v=7Ci55e4GcdE&ab_channel=ELENE4896

https://www.youtube.com/watch?v=pi-VvW4SX7w&ab_channel=LippoldHaken

https://www.youtube.com/watch?v=Tmx-v4FiP6I&ab_channel=AnotherRoof



### inverse polarity

https://ieeexplore.ieee.org/document/799453

### Reverse carry propagate

https://www.researchgate.net/publication/346412576_DESIGN_AND_IMPLEMENTATION_OF_REVERSE_CARRY_PROPAGATE_ADDER_RCPA_ON_FPGA
https://www.sciencedirect.com/science/article/abs/pii/S0141933119305976#:~:text=The%20reverse%20carry%20propagate%20adder,delay%20variations%20increases%20the%20stability.
https://ieeexplore.ieee.org/document/9002494


### Network switch

Hipernetch: High-Performance FPGA Network Switch
https://dl.acm.org/doi/10.1145/3477054

### Arbiter

https://dl.acm.org/doi/10.5555/1364486.1364503


### Priority encoder

- [Priority encoder](https://en.wikipedia.org/wiki/Priority_encoder)
- https://www.edaboard.com/threads/verilog-bit-mask-to-index-converter.274344/
- https://www.beyond-circuits.com/wordpress/2009/01/recursive-modules/

### CRC

A Systematic Approach for Parallel CRC Computations
https://caslab.ee.ncku.edu.tw/dokuwiki/_media/research:caslab_2001_jnl_01.pdf

Parallel CRC Logic Optimization Algorithm for High Speed Communication Systems
https://ieeexplore.ieee.org/document/4085745

Generalized Parallel CRC Computation
https://www.ijmtst.com/documents/13.IJMTST020407.pdf

A Practical Parallel CRC Generation Method
http://outputlogic.com/my-stuff/parallel_crc_generator_whitepaper.pdf

### ECC

- https://pages.hmc.edu/harris/cmosvlsi/4e/lect/lect18.pdf

Pragmatic Formal Verification of Sequential Error Detection and Correction Codes (ECCs) used in Safety-Critical Design
https://vimeo.com/827700226

## Hamming

- [Hamming code](https://en.wikipedia.org/wiki/Hamming_code#Hamming_codes_with_additional_parity_(SECDED))

#### Golay

- [Binary Golay code](https://en.wikipedia.org/wiki/Binary_Golay_code)
- [The Hidden Geometry of Error-Free Communication](https://www.youtube.com/watch?v=Tmx-v4FiP6I&ab_channel=AnotherRoof)
- [Design and implementation of reconfigurable coders for communication systems](https://ieeexplore.ieee.org/document/7593063)
- [Extended (24, 12) Binary Golay Code: Encoding and Decoding Procedures](https://www.maplesoft.com/applications/Preview.aspx?id=1757)

### Networks

### Sorting and switching networks

This wikipedia article introduces [sorting networks](https://en.wikipedia.org/wiki/Sorting_network).
There are several methods to construct such networks,

- [bitonic sorter](https://en.wikipedia.org/wiki/Bitonic_sorter),
- [pairwise sorting network](https://en.wikipedia.org/wiki/Pairwise_sorting_network),
- [some know optimal networks](https://bertdobbelaere.github.io/sorting_networks.html),
- ...

Sorting networks and their applications
by K. E. BATCHER
https://www.cs.kent.edu/~batcher/sort.pdf

#### Crossbar

https://en.wikipedia.org/wiki/Butterfly_network
https://en.wikipedia.org/wiki/Banyan_switch
https://en.wikipedia.org/wiki/Nonblocking_minimal_spanning_switch

### Handshake protocols and pipelines

MICROPIPELINES
IVAN E. SUTHERLAND
https://dl.acm.org/doi/pdf/10.1145/63526.63532

The Theory of Latency Insensitive Design
Luca P. Carloni
https://ptolemy.berkeley.edu/projects/embedded/asves/dsm/lid/papers/lipTransactions.pdf
