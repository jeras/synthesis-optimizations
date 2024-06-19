#!/usr/bin/python3

import openlane
from openlane.config import Config
from openlane.steps import Step
from openlane.state import State

print(openlane.__version__)

Config.load("config.json")

Synthesis = Step.factory.get("Yosys.Synthesis")

synthesis = Synthesis(
    VERILOG_FILES=["./spm.v"],
    state_in=State(),
)
synthesis.start()

display(synthesis)

