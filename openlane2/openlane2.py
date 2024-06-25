#!/usr/bin/env python3

import os

import itertools

import openlane
from openlane.flows import SequentialFlow
from openlane.steps import Yosys, Misc, OpenROAD, Magic, Netgen

class MyFlow(SequentialFlow):
    Steps = [
        Yosys.Synthesis,
#        OpenROAD.CheckSDCFiles,
#        OpenROAD.Floorplan,
#        OpenROAD.TapEndcapInsertion,
#        OpenROAD.GeneratePDN,
#        OpenROAD.IOPlacement,
#        OpenROAD.GlobalPlacement,
#        OpenROAD.DetailedPlacement,
#        OpenROAD.GlobalRouting,
#        OpenROAD.DetailedRouting,
#        OpenROAD.FillInsertion,
#        Magic.StreamOut,
#        Magic.DRC,
#        Magic.SpiceExtraction,
#        Netgen.LVS
    ]

print(openlane.__version__)

designs=[
    {'top': "bin2oht_base", 'parameters': {"IMPLEMENTATION": [0, 1, 2, 3], "WIDTH": [4,6,8,12,16,24,32,48,64]}},
#    "oht2bin_base",
#    "eql_cmp",
#    "mag_cmp_base",
#    "mux_bin_base",
#    "mux_oht_base",
]

for design in designs:
    top = design['top']
    # iterate over all parameter combinations
    combinations = [dict(zip(design['parameters'], x)) for x in itertools.product(*design['parameters'].values())]
    for combination in combinations:
        parameters = [f"{parameter}={value}" for parameter, value in combination.items()]
        combination_name = '_'.join([f"{parameter}_{value}" for parameter, value in combination.items()])
        flow = MyFlow(
            {
                "PDK": "sky130A",
                "DESIGN_NAME": top,
                "USE_SYNLIG": True,
                "SYNTH_PARAMETERS": parameters,
                "VERILOG_FILES": [
                    "../rtl/bin2oht_base.sv",
                    "../rtl/bin2oht_tree.sv",
                    "../rtl/bin2oht.sv",
                    "../rtl/oht2bin_base.sv",
                    "../rtl/oht2bin_tree.sv",
                    "../rtl/oht2bin.sv",
                    "../rtl/eql_cmp.sv",
                    "../rtl/mag_cmp_base.sv",
                    "../rtl/mag_cmp_tree.sv",
                    "../rtl/mag_cmp.sv",
                    "../rtl/mux_bin_base.sv",
                    "../rtl/mux_bin_tree.sv",
                    "../rtl/mux_bin.sv",
                    "../rtl/mux_oht_base.sv",
                    "../rtl/mux_oht_tree.sv",
                    "../rtl/mux_oht.sv",
                ],
                "CLOCK_PORT": None,
            },
            design_dir=".",
        )
        flow.start(tag=top+combination_name)
