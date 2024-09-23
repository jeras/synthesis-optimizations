yosys -import

proc debug_show {filename} {
    show -format svg -colors 1 -width -prefix "$filename"
    write_json "$filename.json"
    exec netlistsvg "$filename.json" -o "$filename.netlist.svg"
    write_verilog "$filename.v"
}

# read design
read_systemverilog ../rtl/eql_cmp.sv
hierarchy -check -top eql_cmp

# the high-level stuff
# NOTE: `procs` is a TCL wrapper for yosys `proc`
procs; opt
memory; opt
fsm; opt

debug_show "proc"

# mapping to internal cell library
techmap; opt

debug_show "techmap"

# mapping logic to mycells.lib
dfflibmap -liberty /home/izi/.volare/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
abc -liberty /home/izi/.volare/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
clean

debug_show "map"
