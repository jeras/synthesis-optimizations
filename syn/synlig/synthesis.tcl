yosys -import

set PRJROOT ../..

proc debug_show {filename} {
    show -format svg -colors 1 -width -prefix "$filename"
    write_json "$filename.json"
    exec netlistsvg "$filename.json" -o "$filename.netlist.svg"
    write_verilog "$filename.v"
}

set DESIGN counter_wrap

# read design
read_systemverilog $PRJROOT/rtl/arithmetic/$DESIGN.sv
hierarchy -check -top $DESIGN

# change top parameters
# TODO: this is not working
chparam -list $DESIGN
chparam -set WIDTH 8 $DESIGN

# the high-level stuff
# NOTE: `procs` is a TCL wrapper for yosys `proc`
procs; opt
memory; opt
fsm; opt

debug_show "proc"

# map to ripple carry adder
techmap -map $PRJROOT/techmap/rca_map.v

debug_show "techmap_rca"

# mapping to internal cell library
techmap; opt

debug_show "techmap"

# mapping logic to mycells.lib
dfflibmap -liberty $::env(HOME)/.volare/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
abc -liberty $::env(HOME)/.volare/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
clean

debug_show "map"

# final statistics
stat
