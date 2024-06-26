#!/usr/bin/env python3

import os
import itertools
from jinja2 import Environment, FileSystemLoader

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

width_range = [4, 6, 8, 12, 16, 24, 32, 48, 64]
width_range = [8, 12, 16]

designs=[
    {'top': "bin2oht_base", 'parameters': {"IMPLEMENTATION": [0, 1, 2, 3], "WIDTH": width_range}},
#    "oht2bin_base",
#    "eql_cmp",
#    "mag_cmp_base",
#    "mux_bin_base",
#    "mux_oht_base",
]

report_environment = Environment(loader=FileSystemLoader("."))
report_template = report_environment.get_template("report.md.jinja")

for design in designs:
    top = design['top']
    # iterate over all parameter combinations (cartesian product)
    combinations = [dict(zip(design['parameters'], x)) for x in itertools.product(*design['parameters'].values())]
    report_context = {'parameters': list(design['parameters'].keys()), 'combinations': []}
    for combination in combinations:
        combination_parameters = [f"{parameter}={value}" for parameter, value in combination.items()]
        combination_name = '_'.join([f"{parameter}_{value}" for parameter, value in combination.items()])
        flow = MyFlow(
            {
                "PDK": "sky130A",
                "DESIGN_NAME": top,
                "USE_SYNLIG": True,
                "SYNTH_PARAMETERS": combination_parameters,
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
        flow.start(tag=top+'_'+combination_name)

        report_context['combinations'].append({
            'parameters': list(combination.values())
            # hierarchy.dot.svg 
            # techmap.dot.svg
        })

    print(report_context)
    report_filename = "report.md"
    with open(report_filename, mode="w", encoding="utf-8") as report:
        report.write(report_template.render(report_context))
        print(f"... wrote {report_filename}")