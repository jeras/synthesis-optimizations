#!/usr/bin/env python3

import openlane
import os

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

tops=[
    "eql_cmp",
    "mux_bin_base",
    "mux_oht_base"
]

for top in tops:
    flow = MyFlow(
        {
            "PDK": "sky130A",
            "DESIGN_NAME": top,
            "USE_SYNLIG": True,
            "VERILOG_FILES": [
                "../rtl/eql_cmp.sv",
                "../rtl/mux_bin_base.sv",
                "../rtl/mux_oht_base.sv"
            ],
            "CLOCK_PORT": None,
        },
        design_dir=".",
    )
    flow.start(tag=top)
