###################################
# Run the design through Innovus
# Modified for Innovus 16.1
###################################

# Setup design and create floorplan for the SoC/pin-only version
source init_pins.tcl

# Create Floorplan
#floorplan -r 1.0 0.6 5 10 5 10
#unfixAllIos
#legalizePin

# Actually Run the Layout Main Stages
source core_run.tcl
