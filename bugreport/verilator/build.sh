#!/bin/sh

verilator --lint-only --timing --top loop_variable_in_range loop_variable_in_range.sv
#verilator --binary    --timing --top loop_variable_in_range loop_variable_in_range.sv -Wall
verilator --binary    --timing --top loop_variable_in_range loop_variable_in_range.sv --trace-fst
obj_dir/Vloop_variable_in_range
